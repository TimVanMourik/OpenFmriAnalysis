function tvm_transFormStackToFieldmap(configuration)
%
%
%   Copyright (C) 2015, Tim van Mourik, DCCN

%% Parse configuration
subjectDirectory =      	tvm_getOption(configuration, 'i_SubjectDirectory');
    %no default
referenceFile =            	fullfile(subjectDirectory, tvm_getOption(configuration, 'i_ReferenceVolume'));
    %no default
transformFile =            	fullfile(subjectDirectory, tvm_getOption(configuration, 'i_TransformStack'));
    %no default
displacementMapFile =            	fullfile(subjectDirectory, tvm_getOption(configuration, 'o_DisplacementMap'));
    %no default
    
definitions = tvm_definitions();
%%
load(transformFile, definitions.WhiteMatterSurface, definitions.PialSurface, definitions.TransformStack);
wSurface        = eval(definitions.WhiteMatterSurface);
pSurface        = eval(definitions.PialSurface);
transformStack  = eval(definitions.TransformStack);

referenceVolume = spm_vol(referenceFile);
numberOfVertices = prod(referenceVolume.dim);
[x, y, z] = ndgrid(1:referenceVolume.dim(1), 1:referenceVolume.dim(2), 1:referenceVolume.dim(3)); 
indices = [x(:), y(:), z(:)];

displacementMap = cell(1, length(wSurface)); 
maskVolume = cell(1, length(wSurface)); 

for hemisphere = 1:length(wSurface)
    fieldMaps = zeros([referenceVolume.dim, 3, size(transformStack{hemisphere}, 1)]); 
    for iteration = 1:size(transformStack{hemisphere}, 1) 
        coordinates = [indices, ones(numberOfVertices, 1)];
        coordinates = readTransformStack(coordinates, transformStack{hemisphere}{iteration});
        fieldMaps(:, :, :, :, iteration) = reshape(coordinates(:, 1:3), [referenceVolume.dim, 3]) - reshape(indices, [referenceVolume.dim, 3]);
    end
    
    dilation = 5;
    maskVolume{hemisphere} = makeMaskVolume([wSurface{hemisphere}; pSurface{hemisphere}], referenceVolume.dim, dilation); 
    displacementMap{hemisphere} = bsxfun(@times, median(fieldMaps, 5), maskVolume{hemisphere});
end
displacementMap = plus(displacementMap{:}) ./ repmat(plus(maskVolume{:}), [1, 1, 1, 3]);

voxelSize = sqrt(sum(referenceVolume.mat(1:3, 1:3) .^ 2));
filterWidth = [6, 6, 6];
for i = 1:size(displacementMap, 4)
    displacementMap(:, :, :, i) = smoothVolume(displacementMap(:, :, :, i), voxelSize, filterWidth);
end
referenceVolume.pinfo = [1, 0, 352]';
referenceVolume.dt = [16, 0];
tvm_write4D(referenceVolume, displacementMap, displacementMapFile);

end %end function


function coordinates = readTransformStack(coordinates, transformStack)
% this code transforms the original mesh in the transformed mesh #check
% done
    if isempty(transformStack)
        return;
    end
    coordinates = coordinates * transformStack.mat;
    cut = transformStack.cut;
    dimension = transformStack.dimension;
    cutIndices = coordinates(:, dimension) < cut;
       
    coordinates( cutIndices, :) = readTransformStack(coordinates( cutIndices, :), transformStack.smaller);
    coordinates(~cutIndices, :) = readTransformStack(coordinates(~cutIndices, :), transformStack.bigger);
end %end function


function maskVolume = makeMaskVolume(vertices, dimensions, dilationRadius)
      
    vertices = unique(round(vertices(:, 1:3)), 'rows');
    vertices(any(vertices < 1, 2), :) = [];
    vertices(any(bsxfun(@gt, vertices, dimensions), 2), :) = [];
        
    maskVolume = false(dimensions);
    maskVolume(sub2ind(dimensions, vertices(:, 1), vertices(:, 2), vertices(:, 3))) = true;
    maskVolume = tvm_dilate3D(maskVolume, dilationRadius);
    
end %end function


function volume = smoothVolume(volume, voxelSizes, filterWidth)

filterWidth  = filterWidth ./ voxelSizes;     % voxel anisotropy
filter = filterWidth / sqrt(8*log(2));        % FWHM -> Gaussian parameter

x  = round(6*filter(1)); x = -x:x; 
y  = round(6*filter(2)); y = -y:y;
z  = round(6*filter(3)); z = -z:z; 

x = spm_smoothkern(filterWidth(1), x, 1);
y = spm_smoothkern(filterWidth(2), y, 1);
z = spm_smoothkern(filterWidth(3), z, 1);

x  = x / sum(x); 
y  = y / sum(y);
z  = z / sum(z);


i  = (length(x) - 1) / 2;
j  = (length(y) - 1) / 2;
k  = (length(z) - 1) / 2;

spm_conv_vol(volume, volume, x, y, z, -[i,j,k]);

end %end function





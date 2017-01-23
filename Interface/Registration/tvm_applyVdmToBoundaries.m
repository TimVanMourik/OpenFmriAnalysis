function tvm_applyVdmToBoundaries(configuration)
% TVM_
%   TVM_(configuration)
%   
%
%   Copyright (C) Tim van Mourik, 2015, DCCN
%

%% Parse configuration
subjectDirectory =      tvm_getOption(configuration, 'i_SubjectDirectory', pwd());
    %no default
boundariesFiles =       fullfile(subjectDirectory, tvm_getOption(configuration, 'i_Boundaries'));
    %no default
voxelDisplacementFile = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_VoxelDisplacementMap'));
    %no default
transformfunction =        tvm_getOption(configuration, 'i_TransformationFunction', @(x)plus(0, x));
    % @todo find a more elegant null function
distortionDimension =        tvm_getOption(configuration, 'i_DistortionDimenions');
    %no default
boundariesFilesOutput = fullfile(subjectDirectory, tvm_getOption(configuration, 'o_Boundaries'));
    %no default
    
%%
voxelDisplacement           = spm_vol(voxelDisplacementFile);
voxelDisplacement.volume    = spm_read_vols(voxelDisplacement);
load(boundariesFiles, 'wSurface', 'pSurface', 'faceData');

displacement = cell(size(wSurface));
for i = 1:length(wSurface)
    volumeSize = voxelDisplacement.dim;
    integerParts = floor(wSurface{i}(:, 1:3));
    insideVolume = ~any(integerParts < 1 | bsxfun(@gt, integerParts, volumeSize(1:3) - 1) | isnan(integerParts), 2);
    displacement{i} = zeros(size(wSurface{i}));
    displacement{i}(~insideVolume, :) = NaN;
    shift = cumsum(~insideVolume);
    wSurface{i} = wSurface{i}(insideVolume, :);
    pSurface{i} = pSurface{i}(insideVolume, :);
    displacement{i}(insideVolume, distortionDimension) = transformfunction(tvm_sampleVoxels(voxelDisplacement.volume, wSurface{i}(:, 1:3)));
    map = [1:length(shift)]';
    wSurface{i} = wSurface{i} + displacement{i}(insideVolume, :);
    pSurface{i} = pSurface{i} + displacement{i}(insideVolume, :);
    faceData{i} = faceData{i}(all(ismember(faceData{i}, find(insideVolume)), 2), :);
    [~, index] = ismember(faceData{i}, map); 
    map = map - shift;
    faceData{i} = map(index);
end
save(boundariesFilesOutput, 'wSurface', 'pSurface', 'faceData', 'displacement');

end %end function










function output = tvm_labelLayers(configuration)
memtic

subjectDirectory = configuration.SubjectDirectory;
bok = configuration.Bok;
load([subjectDirectory configuration.Boundaries], 'wSurface', 'pSurface');

numberOfLabels = length(configuration.InterestLabels);
%If configuration.Hemisphere is one string, all labels are located on that
%hemisphere. If it is a cell, consider all labels to be located on the
%hemisphere as indicated. 
if iscell(configuration.Hemisphere)
    hemisphere = cell(size(configuration.Hemisphere));
    for h = 1:length(configuration.Hemisphere)
        switch configuration.Hemisphere{h}
            case 'Right'
                hemisphere{h} = 1;
            case 'Left'
                hemisphere{h} = 2;
        end
    end
else
    switch configuration.Hemisphere
        case 'Right'
            hemisphere = num2cell(ones(numberOfLabels, 1));
        case 'Left'
            hemisphere = num2cell(2 * ones(numberOfLabels, 1));
    end
end

if bok
    curvatureFile = [subjectDirectory configuration.Curvature];
    leftCurvature = strrep(curvatureFile, '?', 'l');
    whiteMatterSurface = [subjectDirectory 'FreeSurfer/surf/?h.white'];
    if ~exist([leftCurvature '.asc'], 'file')
        unix(['mris_convert -c ' leftCurvature ' ' strrep(whiteMatterSurface, '?', 'l') ' ' leftCurvature '.asc']);
    end
    rightCurvature = strrep(curvatureFile, '?', 'r');
    if ~exist([rightCurvature '.asc'], 'file')
        unix(['mris_convert -c ' rightCurvature ' ' strrep(whiteMatterSurface, '?', 'r') ' ' rightCurvature '.asc']);
    end
    leftCurvature = importdata([leftCurvature '.asc']);
    leftCurvature = leftCurvature(:, 5);
    rightCurvature = importdata([rightCurvature '.asc']);
    rightCurvature = rightCurvature(:, 5);
    
    curvature = {leftCurvature, rightCurvature};
else
    curvature = {zeros(size(wSurface{1}, 1), 1), zeros(size(wSurface{2}, 1), 1)};
end

if ~exist([subjectDirectory configuration.Atlas(1:(end-4)) '.nii'], 'file')
    unix(['mri_convert ' subjectDirectory configuration.Atlas ' ' subjectDirectory configuration.Atlas(1:(end-4)) '.nii']);
end

labelledVolume = spm_vol([subjectDirectory configuration.Atlas(1:(end-4)) '.nii']);
labelledVolume.volume = spm_read_vols(labelledVolume);

functionalScan          = spm_vol([subjectDirectory configuration.MeanFunctional]);

load([subjectDirectory configuration.CoregistrationMatrix], 'coregistrationMatrix')
transformation = coregistrationMatrix * functionalScan.mat \ labelledVolume.mat;
transformation = transformation';

selectionGrid = false(functionalScan.dim);
% 2 because there are two hemispheres
verticesOfInterest = cell(numberOfLabels, 2);
%Loops over all Labels{:}
for label = 1:numberOfLabels
    indices = cell(length(configuration.InterestLabels{label}), 2);
    %Loops over all Labels{label}(:)
    for l = 1:length(configuration.InterestLabels{label})
        selectionGrid(:) = false;
        labelled = find(ismember(labelledVolume.volume, configuration.InterestLabels{label}(l)));

        [x, y, z] = ind2sub(labelledVolume.dim, labelled);
        coordinates = [x, y, z, ones(size(x))];
        %remove duplicates
        coordinates = unique(round(coordinates * transformation), 'rows');
        %remove coordinates outside the volume
        coordinates = coordinates(all(~bsxfun(@gt, coordinates(:, 1:3), functionalScan.dim), 2), :);
        coordinates = coordinates(all(bsxfun(@gt, coordinates(:, 1:3), [0, 0, 0]), 2), :);

        selectionGrid(sub2ind(functionalScan.dim, coordinates(:, 1), coordinates(:, 2), coordinates(:, 3))) = true;
        %Dilate by 4 voxels
        selectionGrid = dilate3D(selectionGrid, 4);
        [~, indices{l, hemisphere{label}}] = selectVertices(wSurface{hemisphere{label}}, selectionGrid); %#ok<USENS>
    end
    verticesOfInterest{label, hemisphere{label}} = unique(vertcat(indices{:, hemisphere{label}}));

end

coordinates = cell(size(verticesOfInterest));

for label = 1:numberOfLabels
    arrayW = wSurface{hemisphere{label}}(verticesOfInterest{label, hemisphere{label}}, :);
    arrayP = pSurface{hemisphere{label}}(verticesOfInterest{label, hemisphere{label}}, :);
    curv = curvature{hemisphere{label}}(verticesOfInterest{label, hemisphere{label}});
    numberOfSteps = configuration.ProfileLength;
    extraSampling = configuration.OutsideGreyMatter;
    c = round(getBokCoordinates(arrayW, arrayP, curv, numberOfSteps, extraSampling));

    c(mod(find(c(:, :, 1) > functionalScan.dim(1)), size(c, 1)), :, :) = [];
    c(mod(find(c(:, :, 2) > functionalScan.dim(2)), size(c, 1)), :, :) = [];
    c(mod(find(c(:, :, 3) > functionalScan.dim(3)), size(c, 1)), :, :) = [];
    c(mod(find(c(:, :, 1) < 1), size(c, 1)), :, :) = [];
    c(mod(find(c(:, :, 2) < 1), size(c, 1)), :, :) = [];
    c(mod(find(c(:, :, 3) < 1), size(c, 1)), :, :) = [];
    %coordinates as indices in the same space as the functional volume
    coordinates{label, hemisphere{label}} = sub2ind(functionalScan.dim, c(:, :, 1), c(:, :, 2), c(:, :, 3));
end
coordinates = cat(1, coordinates{:});

uniqueVoxels = unique(coordinates(:));
%make sure they're within the ROI:
%uniqueVoxels = intersect(labelled, uniqueVoxels);

v = cell(length(uniqueVoxels), 1);
for i = 1:length(uniqueVoxels)
    v{i} = mod(find(uniqueVoxels(i) == coordinates), configuration.ProfileLength);
end

bins = configuration.Bins;
layerColumns = zeros(length(uniqueVoxels), length(bins));
for i = 1:length(uniqueVoxels)
    for j = 1:length(bins)
        layerColumns(i, j) = length(intersect(v{i}, bins{j}));
    end
    if length(v{i}) > 4
        layerColumns(i, :) = layerColumns(i, :) / length(v{i});
    else
        layerColumns(i, :) = 0;
    end
end

newVolume = functionalScan;
for i = 1:length(bins)
    newVolume.volume = zeros(newVolume.dim);
    newVolume.dt = [16, 0];
    newVolume.volume(uniqueVoxels) = layerColumns(:, i);
    newVolume.volume(~uniqueVoxels) = 0;
    newVolume.fname = sprintf('%s%s%d.nii',subjectDirectory, 'roi', i);
    spm_write_vol(newVolume, newVolume.volume);
end

roi = uniqueVoxels;
%save(, 'roi', 'layerColumns');

output = memtoc;

end %end function







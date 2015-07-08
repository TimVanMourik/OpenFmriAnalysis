function output = tvm_labelToVertex(configuration)

memtic
subjectDirectory    = configuration.SubjectDirectory;
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

load([subjectDirectory configuration.Boundaries], 'wSurface', 'pSurface');

if ~exist([subjectDirectory 'FreeSurfer/mri/' configuration.Atlas(1:(end-4)) '.nii'], 'file')
    unix(['mri_convert ' subjectDirectory 'FreeSurfer/mri/' configuration.Atlas ' ' subjectDirectory 'FreeSurfer/mri/' configuration.Atlas(1:(end-4)) '.nii']);
end

labelledVolume = spm_vol([subjectDirectory 'FreeSurfer/mri/' configuration.Atlas(1:(end-4)) '.nii']);
labelledVolume.volume = spm_read_vols(labelledVolume);

functionalScan = spm_vol([subjectDirectory configuration.MeanFolder configuration.MeanName]);
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
        selectionGrid = dilate3D(selectionGrid, 2);
        [~, indices{l, hemisphere{label}}] = selectVertices(wSurface{hemisphere{label}}, selectionGrid); %#ok<USENS>
    end
    verticesOfInterest{label, hemisphere{label}} = unique(vertcat(indices{:, hemisphere{label}}));

end
clear x y z selectionGrid

save([subjectDirectory configuration.VerticesOfInterest], 'verticesOfInterest');

output = memtoc;

end %end function







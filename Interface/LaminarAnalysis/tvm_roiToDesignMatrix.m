function tvm_roiToDesignMatrix(configuration)
% TVM_ROITODESIGNMATRIX 
%   TVM_ROITODESIGNMATRIX(configuration)
%   
%
%   Copyright (C) Tim van Mourik, 2014, DCCN
%
%   configuration.SubjectDirectory
%   configuration.ROI
%   configuration.DesignMatrix
%   configuration.Layers

%% Parse configuration
subjectDirectory =      tvm_getOption(configuration, 'i_SubjectDirectory', pwd());
    %no default
regionsOfInterest   = tvm_getOption(configuration, 'i_ROI');
    %no default
layerFile           = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_Layers'));
    %no default
designMatrices      = tvm_getOption(configuration, 'o_DesignMatrix');
    %no default
    
definitions = tvm_definitions();
%%
%load in layers
layers = spm_vol(layerFile);

numberOfLayers = length(layers);
for i = 1:length(regionsOfInterest)
    %load in ROI
    roi = spm_vol(fullfile(subjectDirectory, regionsOfInterest{i}));
    roi.volume = spm_read_vols(roi);

    labels = setxor(unique(roi.volume), 0)';
    design = cell(size(labels));
    for j = 1:length(labels)
        %match ROI with layers
        %make design matrix [Vox X Layers]
        indices = find(roi.volume == labels(j));

        designMatrix = zeros(length(indices), numberOfLayers);
        for k = 1:numberOfLayers
            layerI = spm_read_vols(layers(k));
            designMatrix(:, k) = layerI(indices);
        end
        missingValues = any(isnan(designMatrix), 2);
        designMatrix(missingValues, :) = [];
        indices(missingValues) = [];
        % @todo if the ROI is not a binary mask, the weights should be adapted accordingly
        % designMatrix = bsxfun(@times, designMatrix, roi.volume(indices));

        design{j} = [];
        design{j}.Indices = indices;
        [x, y, z] = ind2sub(roi.dim, indices);
        design{j}.Locations = [x, y, z];
        design{j}.DesignMatrix = designMatrix;
        nonZeroColumns = ~all(designMatrix == 0);
        design{j}.NonZerosColumns = find(nonZeroColumns);
        %The covariance matrix is undefined when there is a column of zeros
        %involved, so these are taken out of the equation. @todo write proper
        %warning message
        design{j}.CovarianceMatrix = zeros(numberOfLayers);
        design{j}.CovarianceMatrix(nonZeroColumns, nonZeroColumns) = inv(designMatrix(:, nonZeroColumns)' * designMatrix(:, nonZeroColumns));
    end
    if length(design) == 1
        design = design{1};
    end
    %@todo, check out why the following line crashes
    %save design matrix
%     eval(tvm_changeVariableNames(definitions.GlmDesign, design));
    save(fullfile(subjectDirectory, designMatrices{i}), definitions.GlmDesign);
end

end %end function






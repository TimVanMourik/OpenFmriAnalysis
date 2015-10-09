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
subjectDirectory 	= tvm_getOption(configuration, 'i_SubjectDirectory', '.');
    %no default
regionsOfInterest   = tvm_getOption(configuration, 'i_ROI');
    %no default
layerFile           = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_Layers', 'LevelSets/brain.layers.nii'));
    %'LevelSets/brain.layers.nii'
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

    %match ROI with layers
    %make design matrix [Vox X Layers]
    indices = find(roi.volume ~= 0);
    designMatrix = zeros(length(indices), numberOfLayers);

    for j = 1:numberOfLayers
        layerI = spm_read_vols(layers(j));
        designMatrix(:, j) = layerI(indices);
    end
    % @todo
    %if the ROI is not a binary mask, the weights should be adapted accordingly
    % designMatrix = bsxfun(@times, designMatrix, roi.volume(indices));

    design = [];
    design.Indices = indices;
    design.DesignMatrix = designMatrix;
    nonZeroColumns = ~all(designMatrix == 0);
    design.NonZerosColumns = find(nonZeroColumns);
    %The covariance matrix is undefined when there is a column of zeros
    %involved, so these are taken out of the equation
    design.CovarianceMatrix = zeros(numberOfLayers);
    design.CovarianceMatrix(nonZeroColumns, nonZeroColumns) = inv(designMatrix(:, nonZeroColumns)' * designMatrix(:, nonZeroColumns));

    %save design matrix
    eval(tvm_changeVariableNames(definitions.GlmDesign, design));
    save(fullfile(subjectDirectory, designMatrices{i}), definitions.GlmDesign);
end

end %end function






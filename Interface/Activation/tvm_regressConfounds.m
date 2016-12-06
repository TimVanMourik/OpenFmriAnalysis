function tvm_regressConfounds(configuration)
% TVM_REGRESSCONFOUNDS
%   TVM_REGRESSCONFOUNDS(configuration)
%   
%
%   Copyright (C) Tim van Mourik, 2016, DCCN
%
%   configuration.SubjectDirectory
%   configuration.Design
%   configuration.ReferenceVolume
%   configuration.FunctionalFolder
%   configuration.Mask
%   configuration.GlmOutput
%   configuration.ResidualSumOfSquares


%% Parse configuration
subjectDirectory    = tvm_getOption(configuration, 'i_SubjectDirectory', pwd());
    %no default
designFile          = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_DesignMatrix'));
    %no default
functionalFolder    = tvm_getOption(configuration, 'i_FunctionalFolder', '');
    %no default
functionalFiles     = tvm_getOption(configuration, 'i_FunctionalFiles', '');
    %no default
confounds           = tvm_getOption(configuration, 'i_Confounds');
    %no default
filteredFolder      = fullfile(subjectDirectory, tvm_getOption(configuration, 'o_FilteredFolder'));
    %no default

definitions = tvm_definitions();  
    
%%
load(designFile, definitions.GlmDesign);
design = eval(definitions.GlmDesign);

contrast = tvm_getContrastVector(confounds, design.DesignMatrix, design.RegressorLabel);

if ~isempty(functionalFolder)
    functionalFolder = fullfile(subjectDirectory, functionalFolder);
    if functionalFolder(end) ~= filesep()
        functionalFolder = fullfile(functionalFolder, filesep());
    end

    allVolumes = dir(fullfile(functionalFolder, '*.nii'));
    allVolumes = {allVolumes.name};

    for i = 1:length(allVolumes)
        volumeFiles = spm_vol(fullfile(functionalFolder, allVolumes{i}));
        numberOfVolumes = length(volumeFiles);
        volumeData = spm_read_vols(volumeFiles);
        volumeData = reshape(volumeData, [prod(volumeFiles(1).dim(1:3)), numberOfVolumes])';

        designMatrix = design.DesignMatrix(design.Partitions{i}, :);
        pseudoInverse = pinv(designMatrix);
        betas = pseudoInverse * volumeData;
        volumeData = volumeData - designMatrix(:, contrast == true) * betas(contrast == true, :);

        volumeData = reshape(volumeData', [volumeFiles(1).dim(1:3), numberOfVolumes]);
        tvm_write4D(volumeFiles(1), volumeData, fullfile(filteredFolder, allVolumes{i}));
    end
elseif ~isempty(functionalFiles)
    allVolumes = dir(fullfile(subjectDirectory, functionalFiles));
    allVolumes = {allVolumes.name};
    [path, ~, ~] = fileparts(functionalFiles);

    volumeFiles = spm_vol(fullfile(functionalFolder, fullfile(subjectDirectory, path, allVolumes')));
    numberOfVolumes = length(volumeFiles);
    volumeData = spm_read_vols([volumeFiles{:}]);
    volumeData = reshape(volumeData, [prod(volumeFiles{1}.dim(1:3)), numberOfVolumes])';

    designMatrix = design.DesignMatrix(design.Partitions{1}, :);
    pseudoInverse = pinv(designMatrix);
    betas = pseudoInverse * volumeData;
    volumeData = volumeData - designMatrix(:, contrast == true) * betas(contrast == true, :);

    volumeData = reshape(volumeData', [volumeFiles{1}.dim(1:3), numberOfVolumes]);
    for i = 1:length(allVolumes)
        tvm_write4D(volumeFiles{i}, volumeData(:, :, :, i), fullfile(filteredFolder, allVolumes{i}));
    end
end
    
end %end function








function tvm_regressConfounds(configuration)
% TVM_REGRESSCONFOUNDS
%   TVM_REGRESSCONFOUNDS(configuration)
%   @todo Add description
%
% Input:
%   i_SubjectDirectory
%   i_DesignMatrix
%   i_SourceDirectory
%   i_Confounds
%   o_OutputDirectory
% Output:
%   o_FilteredFolder

%   Copyright (C) Tim van Mourik, 2016, DCCN
%
% This file is part of the fmri analysis toolbox, see 
% https://github.com/TimVanMourik/FmriAnalysis for the documentation and 
% details.
%
%    This toolbox is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    This toolbox is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with the fmri analysis toolbox. If not, see 
%    <http://www.gnu.org/licenses/>.

%% Parse configuration
subjectDirectory    = tvm_getOption(configuration, 'i_SubjectDirectory', pwd());
    % default: current working directory
designFile          = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_DesignMatrix'));
    %no default
functionalFolder    = tvm_getOption(configuration, 'i_SourceDirectory', '');
    % default: empty
functionalFiles     = tvm_getOption(configuration, 'i_FunctionalFiles', '');
    % default: empty
confounds           = tvm_getOption(configuration, 'i_Confounds');
    %no default
filteredFolder      = fullfile(subjectDirectory, tvm_getOption(configuration, 'o_OutputDirectory'));
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








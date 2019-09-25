function tvm_averageSignal(configuration)
% TVM_GLM
%   TVM_GLM(configuration)
%   
%
%   Copyright (C) Tim van Mourik, 2014, DCCN
%

%% Parse configuration
subjectDirectory        = tvm_getOption(configuration, 'i_SubjectDirectory', pwd());
    %no default
functionalFolder        = tvm_getOption(configuration, 'i_FunctionalFolder', '');
    %no default
functionalFiles         = tvm_getOption(configuration, 'i_FunctionalFiles', '');
    % default: empty
roiMask                 = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_Mask'));
    %default: empty
timeCourseFile          = fullfile(subjectDirectory, tvm_getOption(configuration, 'o_TimeCourse'));
    %no default

    
%%
if ~isempty(functionalFolder)
    functionalFolder = fullfile(subjectDirectory, functionFolder);
    allVolumes = dir(fullfile(functionalFolder, '*.nii'));
    allVolumes = fullfile(functionalFolder, {allVolumes.name});
elseif ~isempty(functionalFiles)
    allVolumes = dir(fullfile(subjectDirectory, functionalFiles));
    [path, ~, ~] = fileparts(functionalFiles);
    allVolumes = {allVolumes(:).name};
    allVolumes = fullfile(subjectDirectory, path, allVolumes);
end

%double negation to make sure the mask is binary.
masks = ~~spm_read_vols(cellfun(@spm_vol, roiMask));

% sum(mask(:))

allVolumes = spm_vol(allVolumes);
allVolumes = vertcat(allVolumes{:});
numberOfVolumes = length(allVolumes);
alltimeCourses{1} = zeros(length(roiMask), numberOfVolumes);
maskSum = squeeze(sum(masks, [1, 2, 3]));
for i = 1:numberOfVolumes
    volume = spm_read_vols(allVolumes(i));
    volume = bsxfun(@times, volume, masks);
    alltimeCourses{1}(:, i) = squeeze(sum(volume, [1, 2, 3]))./ sum(masks(:));
end

timeCourses = cell(1);
for i = 1:length(timeCourseFile)
    timeCourses{1} = alltimeCourses{1}(i, :);
    save(timeCourseFile{i}, 'timeCourses');
end
    
end %end function








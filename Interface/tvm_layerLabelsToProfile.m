function tvm_layerLabelsToProfile(configuration)
% TVM_LAYERLABELSTOPROFILE 
%   TVM_LAYERLABELSTOPROFILE(configuration)
%   
%
%   Copyright (C) Tim van Mourik, 2014, DCCN
%
%   configuration.SubjectDirectory
%

%% Parse configuration
subjectDirectory        = tvm_getOption(configuration, 'i_SubjectDirectory');
    %no default
labelFile               = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_LabelFile'));
    %no default
roiFile                 = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_ROI'));
    %no default
functionalFiles         = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_FunctionalFiles'));
    %no default
timeCourseFile            = fullfile(subjectDirectory, tvm_getOption(configuration, 'o_TimeCourse'));
    %no default
    
definitions = tvm_definitions();

%%
allVolumes = spm_vol(functionalFiles{1});
allVolumes.volume = spm_read_vols(allVolumes);
for i = 1:length(roiFile)
    roi = spm_vol(roiFile{i});
    roi.volume = ~~spm_read_vols(roi);

    labels = spm_vol(labelFile);
    labelVolume = spm_read_vols(labels);
    
    design = zeros(sum(roi.volume(:)), length(labels));
    for j = 1:length(labels)
        temp = labelVolume(:, :, :, j);
        design(:, j) = temp(roi.volume == true);
    end
    m = max(design, [], 2);
    design(bsxfun(@ne, design, m)) = 0;
    design(bsxfun(@eq, design, m)) = 1;
    
    
    timeCourses{1} = allVolumes.volume(roi.volume == true)' * design ./ sum(design);
    
    save(timeCourseFile{i}, 'timeCourses');
end










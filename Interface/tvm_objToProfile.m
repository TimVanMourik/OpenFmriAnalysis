function tvm_objToProfile(configuration)
% TVM_LEVELSETTOOBJ 
%   TVM_LEVELSETTOOBJ(configuration)
%   
%
%   Copyright (C) Tim van Mourik, 2014, DCCN
%
%   configuration.SubjectDirectory
%

%% Parse configuration
subjectDirectory        = tvm_getOption(configuration, 'i_SubjectDirectory');
    %no default
objectFile              = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_ObjFile'));
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
    roi.volume = spm_read_vols(roi);

    [root, ~, ~] = fileparts(objectFile);
    objFiles = dir(objectFile);
    objFiles = fullfile(root, {objFiles(:).name});
    timeCourses = cell(1);
    timeCourses{1} = zeros(length(objFiles), size(allVolumes, 1));
    for j = 1:length(objFiles)
        [v, ~] = tvm_importObjFile(objFiles{j});
        v = round(v);
        intersection = intersect(find(~~roi.volume(:) == 1), sub2ind(roi.dim, v(:, 1), v(:, 2), v(:, 3)));

        timeCourses{1}(j) = mean(allVolumes.volume(intersection));
    end
    save(timeCourseFile{i}, 'timeCourses');
end










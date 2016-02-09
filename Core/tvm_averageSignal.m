function tvm_averageSignal(configuration)
% TVM_GLM
%   TVM_GLM(configuration)
%   
%
%   Copyright (C) Tim van Mourik, 2014, DCCN
%

%% Parse configuration
subjectDirectory =      tvm_getOption(configuration, 'i_SubjectDirectory', pwd());
    %no default
functionalFolder =      fullfile(subjectDirectory, tvm_getOption(configuration, 'i_FunctionalFolder'));
    %no default
roiMask =               fullfile(subjectDirectory, tvm_getOption(configuration, 'i_Mask'));
    %default: empty
timeCourseFile =        fullfile(subjectDirectory, tvm_getOption(configuration, 'o_TimeCourse'));
    %no default

    
%%
allVolumes = dir(fullfile(functionalFolder, '*.nii'));
allVolumes = fullfile(functionalFolder, {allVolumes.name});

%double negation to make sure the mask is binary.
mask = ~~spm_read_vols(spm_vol(roiMask));

% sum(mask(:))

allVolumes = spm_vol(allVolumes);
allVolumes = vertcat(allVolumes{:});
numberOfVolumes = length(allVolumes);
timeCourses{1} = zeros(1, numberOfVolumes);
for i = 1:numberOfVolumes
    volume = spm_read_vols(allVolumes(i));
    volume = volume .* mask;
    timeCourses{1}(i) = sum(volume(:)) / sum(mask(:));
end

save(timeCourseFile, 'timeCourses');

end %end function








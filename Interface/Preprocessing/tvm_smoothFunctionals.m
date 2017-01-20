function tvm_smoothFunctionals(configuration)
% TVM_SMOOTHFUNCTIONALS 
%   TVM_SMOOTHFUNCTIONALS(configuration)
%   
%
%   Copyright (C) Tim van Mourik, 2014, DCCN
%
%   configuration.SubjectDirectory
%   configuration.FunctionalDirectory
%   configuration.SmoothingDirectory
%   configuration.SmoothingKernel

%% Parse configuration
subjectDirectory =      tvm_getOption(configuration, 'i_SubjectDirectory', pwd());
    %no default
functionalDirectory =   fullfile(subjectDirectory, tvm_getOption(configuration, 'i_SourceDirectory'));
    %no default
smoothingKernel =       tvm_getOption(configuration, 'i_SmoothingKernel', [4, 4, 4]);
    %'[4, 4, 4]
useQsub =               tvm_getOption(configuration, 'i_Qsub', false);
    % false
smoothingDirectory =    fullfile(subjectDirectory, tvm_getOption(configuration, 'o_OutputDirectory'));
    %no default
    
%%
volumeNames = dir(fullfile(functionalDirectory, '*.nii'));
volumeNames = {volumeNames.name};
allVolumes = fullfile(functionalDirectory, volumeNames);
newVolumes = fullfile(smoothingDirectory, strcat('s', volumeNames));

if useQsub
    compilation = 'no';
    memoryRequirement = 2 * 1024 ^ 3;
    timeRequirement = 10 * 60;
    for i = 1:length(allVolumes)
        qsubfeval(@spm_smooth, allVolumes{i}, newVolumes{i}, smoothingKernel, 'memreq', memoryRequirement, 'timreq', timeRequirement, 'compile', compilation);
    end
else
    cellfun(@spm_smooth, allVolumes, newVolumes, repmat({smoothingKernel}, 1, length(allVolumes)));
end

end %end function






function tvm_filterFunctionals(configuration)
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
subjectDirectory =      tvm_getOption(configuration, 'i_SubjectDirectory');
    %no default
functionalDirectory =   fullfile(subjectDirectory, tvm_getOption(configuration, 'i_FunctionalDirectory'));
    %no default
lowerCutOff =           tvm_getOption(configuration, 'i_LowPass', []);
    %no default
higherCutOff =          tvm_getOption(configuration, 'i_HighPass', []);
    % []
tr =                    tvm_getOption(configuration, 'i_TR', 1);
    % []
useQsub =               tvm_getOption(configuration, 'i_Qsub', true);
    % []
smoothingDirectory =    fullfile(subjectDirectory, tvm_getOption(configuration, 'o_FilterDirectory'));
    % []
    
%%
if isempty(lowerCutOff)
    lowerCutOff = -1;
else
    lowerCutOff = 1 / lowerCutOff / tr;   %Lower cut-off measured in volumes
end

if isempty(higherCutOff)
    higherCutOff = -1;
else
    higherCutOff = 1 / higherCutOff / tr; %Upper cut-off measured in volumes
end

volumeNames = dir(fullfile(functionalDirectory, '*.nii'));
volumeNames = {volumeNames.name};
allVolumes = fullfile(functionalDirectory, volumeNames);
newVolumes = fullfile(smoothingDirectory, strcat('f', volumeNames));
zipVolumes = fullfile(smoothingDirectory, strcat('f', volumeNames, '.gz'));
numberOfSessions = length(volumeNames);

%@todo rewrite to (qsub)cellfun
for i = 1:numberOfSessions
    filterCommand = sprintf('source ~/.bashrc; fslmaths -odt float %s -bptf %f %f %s; gunzip -f %s', allVolumes{i}, higherCutOff, lowerCutOff, newVolumes{i}, zipVolumes{i});
    bandPassSession(filterCommand, useQsub);
end

end %end function

function bandPassSession(filterCommand, useQsub)
    
if useQsub
    compilation = 'no';
    memoryRequirement = 2 * 1024 ^ 3;
    timeRequirement = 10 * 60;
    qsubfeval(@unix, filterCommand, 'memreq', memoryRequirement, 'timreq', timeRequirement, 'compile', compilation);
else
    feval(@unix, filterCommand);
end
    
end %end function




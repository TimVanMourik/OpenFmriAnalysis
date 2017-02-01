function tvm_filterFunctionals(configuration)
% TVM_FILTERFUNCTIONALS
%   TVM_FILTERFUNCTIONALS(configuration)
%   @todo Add description
%   
%
%   Copyright (C) Tim van Mourik, 2014-2015, DCCN
%
% Input:
%   i_SubjectDirectory
%   i_SourceDirectory
%   i_LowPass
%   i_HighPass
%   i_TR
%   i_Qsub
% Output:
%   o_OutputDirectory
%

%% Parse configuration
subjectDirectory =      tvm_getOption(configuration, 'i_SubjectDirectory', pwd());
    % default: current working directory
functionalDirectory =   fullfile(subjectDirectory, tvm_getOption(configuration, 'i_SourceDirectory'));
    %no default
lowerCutOff =           tvm_getOption(configuration, 'i_LowPass', []);
    % default: empty
higherCutOff =          tvm_getOption(configuration, 'i_HighPass', []);
    % default: empty
tr =                    tvm_getOption(configuration, 'i_TR', 1);
    % default: 1 second
useQsub =               tvm_getOption(configuration, 'i_Qsub', true);
    % default: no parallellisation
smoothingDirectory =    fullfile(subjectDirectory, tvm_getOption(configuration, 'o_OutputDirectory'));
    %no default
    
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
    filterCommand = sprintf('source ~/.bashrc; fslmaths %s -bptf %f %f %s -odt float; gunzip -f %s', allVolumes{i}, higherCutOff, lowerCutOff, newVolumes{i}, zipVolumes{i});
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




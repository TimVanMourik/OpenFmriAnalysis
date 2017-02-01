function tvm_mergeVolumes(configuration)
% TVM_MERGEVOLUMES
%   TVM_MERGEVOLUMES(configuration)
%   @todo Add description
%   
%
%   Copyright (C) Tim van Mourik, 2014, DCCN
%
% Input:
%   i_SubjectDirectory
%   i_InputVolumes
% Output:
%   o_OutputVolume
%

%% Parse configuration
subjectDirectory =      tvm_getOption(configuration, 'i_SubjectDirectory', pwd());
    % default: current working directory
inputVolumes        = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_InputVolumes'));
    %no default
outputVolume        = fullfile(subjectDirectory, tvm_getOption(configuration, 'o_OutputVolume'));
    %no default
    
% definitions = tvm_definitions();

%%
unix(sprintf('fslmerge -t %s %s', outputVolume, inputVolumes));
unix(sprintf('gunzip %s', outputVolume));

end %end function






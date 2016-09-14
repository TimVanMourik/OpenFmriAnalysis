function tvm_mergeVolumes(configuration)
% TVM_MERGEVOLUMES 
%   TVM_MERGEVOLUMES(configuration)
%   
%
%   Copyright (C) Tim van Mourik, 2014, DCCN
%
%   configuration.SubjectDirectory
%   configuration.i_InputVolumes
%   configuration.o_OutputVolumes

%% Parse configuration
subjectDirectory    = tvm_getOption(configuration, 'i_SubjectDirectory', pwd());
    %no default
inputVolumes        = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_InputVolumes'));
    %no default
outputVolume        = fullfile(subjectDirectory, tvm_getOption(configuration, 'o_OutputVolume'));
    %no default
    
definitions = tvm_definitions();

%%
unix(sprintf('fslmerge -t %s %s', outputVolume, inputVolumes));
unix(sprintf('gunzip %s', outputVolume));

end %end function






function tvm_extractBrain(configuration)
% TVM_COMPUTETSNR
%   TVM_COMPUTETSNR(configuration)
%   
%
%   Copyright (C) Tim van Mourik, 2014, DCCN
%
%   configuration.SubjectDirectory
%   configuration.FunctionalDirectory

%% Parse configuration
subjectDirectory =      tvm_getOption(configuration, 'SubjectDirectory');
    %no default
brainFile =             fullfile(subjectDirectory, tvm_getOption(configuration, 'ReferenceVolume'));
    %no default
maskFile =              fullfile(subjectDirectory, tvm_getOption(configuration, 'GreyMatterMask'));
    %no default

%%
unix(sprintf('bet %s %s', brainFile, maskFile));
unix(sprintf('gunzip %s', [maskFile '.gz']));

end %end function






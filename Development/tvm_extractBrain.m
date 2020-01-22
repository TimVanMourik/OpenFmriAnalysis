function tvm_extractBrain(configuration)
% TVM_EXTRACTBRAIN
%   TVM_EXTRACTBRAIN(configuration)
%   
%
%   Copyright (C) Tim van Mourik, 2014, DCCN
%
%   configuration.SubjectDirectory
%   configuration.FunctionalDirectory

%% Parse configuration
subjectDirectory =      tvm_getOption(configuration, 'i_SubjectDirectory');
    %no default
fractionalIntensity =   tvm_getOption(configuration, 'i_FractionalIntensity', 0.25);
    %no default
brainFile =             fullfile(subjectDirectory, tvm_getOption(configuration, 'i_ReferenceVolume'));
    %no default
maskFile =              fullfile(subjectDirectory, tvm_getOption(configuration, 'o_BrainMask'));
    %no default
maskedImage =           fullfile(subjectDirectory, tvm_getOption(configuration, 'o_MaskedImage'));
    %no default

%%
% #TODO only set if undefined
setenv('FSLOUTPUTTYPE', 'NIFTI');
unix(sprintf('bet2 %s %s -m -f %f', brainFile, maskFile, fractionalIntensity));
movefile(maskFile, maskedImage);
movefile([maskFile, '_mask.nii'], maskFile);

end %end function

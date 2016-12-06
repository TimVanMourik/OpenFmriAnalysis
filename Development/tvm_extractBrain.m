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
maskedImage =           tvm_getOption(configuration, 'o_MaskedImage');
    %no default

%%
setenv('FSLOUTPUTTYPE', 'NIFTI');
unix(sprintf('bet %s %s -m -Z -f %f', brainFile, maskFile, fractionalIntensity));
[root, file] = fileparts(maskFile);
unix(sprintf('rm %s', maskFile));
unix(sprintf('mv %s %s', [root, filesep(), file, '_mask.nii'], maskFile));

% could also use 
if ~isempty(maskedImage)
    maskedImage = fullfile(subjectDirectory, maskedImage);
    referenceVolume = spm_vol(brainFile);
    v = bsxfun(@times, spm_read_vols(referenceVolume), spm_read_vols(spm_vol(maskFile)));
    tvm_write4D(referenceVolume, v, maskedImage);
end

end %end function

function tvm_modifyMp2rage(configuration)
% TVM_MODIFYMP2RAGE 
%   TVM_MODIFYMP2RAGE(configuration)
%   From the several MP2RAGE images, one image is created. This image
%   has the best grey-white matter contrast and has a black background
%
%   Copyright (C) Tim van Mourik, 2014, DCCN
%
%   configuration.i_SubjectDirectory
%   configuration.i_ContrastImage
%   configuration.i_BlackBackgroundImage
%   configuration.i_Threshold
%   configuration.o_Output

%% Parse configuration
subjectDirectory =      tvm_getOption(configuration, 'i_SubjectDirectory', pwd());
    %default: current directory
contrastFile =          fullfile(subjectDirectory, tvm_getOption(configuration, 'i_ContrastImage'));
    %default: '*UNI*'
backgroundFile =        fullfile(subjectDirectory, tvm_getOption(configuration, 'i_BlackBackgroundImage'));
    %default: '*INV2*'
threshold =             tvm_getOption(configuration, 'i_Threshold', 1.2);
    %default = 1.2
    %this is the background threshold: everything under mean * threshold of
    %the inv2-image gets nulled in the uni-image
outputFileName =        fullfile(subjectDirectory, tvm_getOption(configuration, 'o_Output', 'MP2RAGE.nii'));
    %default: 'MP2RAGE.nii'   

%%
contrastFile = spm_vol(contrastFile);
contrastFile.volume = spm_read_vols(contrastFile);

inversionImage = spm_vol(backgroundFile);
inversionImage.volume = spm_read_vols(inversionImage);

meanVolume = mean(inversionImage.volume(:));
contrastFile.volume(inversionImage.volume < meanVolume * threshold) = 0;
contrastFile.fname = outputFileName;

empty = false(contrastFile.dim);
empty(contrastFile.volume == 0) = true;
%dilate the mask a tiny bit: 1 voxel to each side, i.e. a kernel of 3
empty = tvm_dilate3D(empty, 3);
contrastFile.volume(empty) = 0;

spm_write_vol(contrastFile, contrastFile.volume);

end %end function





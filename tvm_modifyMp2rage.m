function tvm_modifyMp2rage(configuration)
% TVM_MODIFYMP2RAGE 
%   TVM_MODIFYMP2RAGE(configuration)
%   From the 5 different MP2RAGE images, one image is created. This image
%   has the best grey-white matter contrast and has a black background
%
%   Copyright (C) Tim van Mourik, 2014, DCCN
%
%   configuration.SubjectDirectory
%   configuration.MP2RAGEFolder
%   configuration.UniFolder
%   configuration.Inv2Folder
%   configuration.MP2RAGE

%% Parse configuration
subjectDirectory =  tvm_getOption(configuration, 'i_SubjectDirectory');
    %no default
mp2rageFolder =     [subjectDirectory, tvm_getOption(configuration, 'i_MP2RAGEFolder')];
    %no default   
uniFolder =         tvm_getOption(configuration, 'i_UniFolder', '*UNI*');
inv2Folder =        tvm_getOption(configuration, 'i_Inv2Folder', '*INV2*');
anatomicalFileName =tvm_getOption(configuration, 'o_MP2RAGE', 'MP2RAGE.nii');
threshold =         tvm_getOption(configuration, 'p_Threshold', 1.2);
    %default = 1.2
    %this is the background threshold: everything under mean * threshold of
    %the inv2-image gets nulled in the uni-image

%%
folder = dir(fullfile(mp2rageFolder, uniFolder));
uniFile = [mp2rageFolder folder.name];
fileName = ls(fullfile(uniFile, '*.nii'));
contrastImage = spm_vol(fileName);
contrastImage.volume = spm_read_vols(contrastImage);

folder = dir(fullfile(mp2rageFolder, inv2Folder));
inv2File = [mp2rageFolder folder.name];
fileName = ls([inv2File '/*.nii']);
inversionImage = spm_vol(fileName);
inversionImage.volume = spm_read_vols(inversionImage);

meanVolume = mean(inversionImage.volume(:));
contrastImage.volume(inversionImage.volume < meanVolume * threshold) = 0;
contrastImage.fname = fullfile(mp2rageFolder, anatomicalFileName);

empty = false(contrastImage.dim);
empty(contrastImage.volume == 0) = true;
empty = tvm_dilate3D(empty, 3);
contrastImage.volume(empty) = 0;

spm_write_vol(contrastImage, contrastImage.volume);

end %end function
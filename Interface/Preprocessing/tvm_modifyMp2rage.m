function tvm_modifyMp2rage(configuration)
% TVM_MODIFYMP2RAGE 
%   TVM_MODIFYMP2RAGE(configuration)
%   From the several MP2RAGE images, one image is created. This image
%   has the best grey-white matter contrast and has a black background
%   @todo Expand description
%
% Input:
%   i_SubjectDirectory
%   i_ContrastImage
%   i_BlackBackgroundImage
%   i_Threshold
% Output:
%   o_OutputFile
%

%   Copyright (C) Tim van Mourik, 2014-2015, DCCN
%
% This file is part of the fmri analysis toolbox, see 
% https://github.com/TimVanMourik/FmriAnalysis for the documentation and 
% details.
%
%    This toolbox is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    This toolbox is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with the fmri analysis toolbox. If not, see 
%    <http://www.gnu.org/licenses/>.

%% Parse configuration
subjectDirectory =      tvm_getOption(configuration, 'i_SubjectDirectory', pwd());
    % default: current working directory
contrastFile =          fullfile(subjectDirectory, tvm_getOption(configuration, 'i_ContrastImage'));
    %no default
backgroundFile =        fullfile(subjectDirectory, tvm_getOption(configuration, 'i_BlackBackgroundImage'));
    %no default
threshold =             tvm_getOption(configuration, 'i_Threshold', 1.2);
    %default = 1.2
    %this is the background threshold: everything under mean * threshold of
    %the inv2-image gets nulled in the uni-image
outputFileName =        fullfile(subjectDirectory, tvm_getOption(configuration, 'o_OutputFile', 'MP2RAGE.nii'));
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





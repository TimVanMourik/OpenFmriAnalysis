function tvm_computeMeanVolume(configuration)
% TVM_COMPUTEMEANVOLUME
%   TVM_COMPUTEMEANVOLUME(configuration)
%   @todo Add description
%
% Input:
%   i_SubjectDirectory
%   i_SourceDirectory
% Output:
%   o_MeanFile
%

%   Copyright (C) Tim van Mourik, 2014, DCCN
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
niftiFolder =           fullfile(subjectDirectory, tvm_getOption(configuration, 'i_SourceDirectory'));
    %no default
meanName =              fullfile(subjectDirectory, tvm_getOption(configuration, 'o_MeanFile', 'MeanFunctional.nii'));
    %'MeanFunctional.nii'

definitions = tvm_definitions();

%%
volumeFileTypes = definitions.VolumeFileTypes;
niftis = [];
for j = 1:length(volumeFileTypes)
    folder = dir(fullfile(niftiFolder, ['*' volumeFileTypes{j}]));
    niftis = [niftis; {folder.name}];
end
niftis = fullfile(niftiFolder, niftis(:));

summedVolume = [];
numberOfVolumes = 0;
for i = 1:length(niftis)
    volumes = spm_vol(niftis{i});
    numberOfVolumes = numberOfVolumes + length(volumes);
    volumeData = spm_read_vols(volumes);
    if ~exist(summedVolume, 'var')
        volumeData = sum(volumeData, 4);
    else
        volumeData = volumeData + sum(volumeData, 4);
    end
end
volumeData = volumeData / numberOfVolumes;

meanNifti = volumes(1);
meanNifti.dt = [16,0];
meanNifti.fname = meanName;

spm_write_vol(meanNifti, volumeData);

end %end function











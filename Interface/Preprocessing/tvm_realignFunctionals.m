function tvm_realignFunctionals(configuration, realignmentConfiguration)
% TVM_REALIGNFUNCTIONALS Moves niftis to destination folder
%   TVM_REALIGNFUNCTIONALS(configuration, realignmentConfiguration)
%   @todo Add description
%
% Input:
%   i_SubjectDirectory
%   i_SourceDirectory
%   i_Characteristic
% Output:
%   o_OutputDirectory
%   o_MeanFunctional
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
if nargin < 2
    realignmentConfiguration = [];
end

subjectDirectory        = tvm_getOption(configuration, 'i_SubjectDirectory', pwd());
    % default: current working directory
niftiFolder             = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_SourceDirectory'));
    %no default
characteristic          = tvm_getOption(configuration, 'i_Characteristic', '*');
    % default: '*'
realignmentFolder       = fullfile(subjectDirectory, tvm_getOption(configuration, 'o_OutputDirectory'));
    %no default
meanName                = fullfile(subjectDirectory, tvm_getOption(configuration, 'o_MeanFunctional', 'MeanFunctional.nii'));
    % default: 'MeanFunctional.nii'
    
definitions = tvm_definitions();  
%%
volumeFileTypes = definitions.VolumeFileTypes;
niftis = [];
for j = 1:length(volumeFileTypes)
    folder = dir(fullfile(niftiFolder, [characteristic, volumeFileTypes{j}]));
    niftis = [niftis; {folder.name}];
end
niftis = fullfile(niftiFolder, niftis(:));

%The only thing spm_realign does is creating the rp*.txt (only when no
%output argument are given
realignedNiftis = spm_realign(niftis, realignmentConfiguration);
for s = 1:numel(realignedNiftis)
    %-Save parameters as rp_*.txt files
    save_parameters(realignedNiftis{s});

    %-Update voxel to world mapping in images header
    for i=1:numel(realignedNiftis{s})
        spm_get_space([realignedNiftis{s}(i).fname ',' num2str(realignedNiftis{s}(i).n)], realignedNiftis{s}(i).mat);
    end
end

spm_reslice(niftis, realignmentConfiguration);

oldMeanNifti = dir(fullfile(niftiFolder, 'mean*.nii'));
movefile(fullfile(niftiFolder, oldMeanNifti.name), meanName);
movefile(fullfile(niftiFolder, 'r*.nii'), realignmentFolder);
movefile(fullfile(niftiFolder, 'rp*.txt'), realignmentFolder);
movefile(fullfile(niftiFolder, '*.mat'), realignmentFolder);

end %end function


function save_parameters(V)
fname = spm_file(V(1).fname, 'prefix','rp_', 'ext','.txt');
n = length(V);
Q = zeros(n,6);
for j=1:n
    qq     = spm_imatrix(V(j).mat/V(1).mat);
    Q(j,:) = qq(1:6);
end
save(fname,'Q','-ascii');
end


function tvm_resampleVolume(configuration)
% TVM_RESAMPLEVOLUME(configuration)
%   TVM_RESAMPLEVOLUME(configuration)
%   @todo Add description
%
% Input:
%   i_SubjectDirectory
%   i_ReferenceVolume
%   i_VoxelSize
% Output:
%   o_OutputVolume
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
subjectDirectory        = tvm_getOption(configuration, 'i_SubjectDirectory', pwd());
    % default: current working directory
referenceFile           = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_ReferenceVolume'));
    %no default
voxelSize               = tvm_getOption(configuration, 'i_VoxelSize');
    %
outputFile              = fullfile(subjectDirectory, tvm_getOption(configuration, 'o_OutputVolume'));
    %no default

%%

% load volume information
referenceVolume         = spm_vol(referenceFile);
numberOfVolumes         = length(referenceVolume);
resampleVolume          = referenceVolume(1);

% load transformation information
oldDimensions           = referenceVolume.dim;
oldMatrix               = referenceVolume(1).mat;
oldTransformation       = reshape(spm_imatrix(oldMatrix), [3, 4]);

% convert transformation in seperate transformations
translation = oldTransformation(:, 1)';
rotation    = oldTransformation(:, 2)';
scale       = oldTransformation(:, 3)';
shear       = oldTransformation(:, 4)';

% these are the inner/outer points of the described box
x0 = translation - scale / 2;
x1 = oldDimensions .* scale + x0;

% these are the new dimensions...
newDimensions 	= round(oldDimensions ./ voxelSize(:)' .* abs(scale));
newScale     	= (x1 - x0) ./ newDimensions;
newTranslation  = x0 - newScale / 2;

% ...that make the new matrix
newMatrix = spm_matrix([newTranslation, ...
                        rotation, ...
                        newScale, ...
                        shear]);

% (pre-)allocate the volumes
newVolumeInformation    = zeros([newDimensions, numberOfVolumes]);
volumeInformation       = spm_read_vols(referenceVolume);
for n = 1:numberOfVolumes
    %don't remove the for-loop for the fourth dimension, or you will get
    %smearing from one volume to the next
    newVolumeInformation(:, :, :, n) = tvm_resample(volumeInformation(:, :, :, n), newDimensions, 1);
end
resampleVolume.dim = newDimensions;
resampleVolume.mat = newMatrix;
tvm_write4D(resampleVolume, newVolumeInformation, outputFile);

end %end function


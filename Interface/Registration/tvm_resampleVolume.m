function tvm_resampleVolume(configuration)
% TVM_DOWNSAMPLEVOLUME(configuration)
%
% INPUT
%	The nifti-image that you want to resample
%	The voxelsize (x, y and z) that you want to resample to
%
%   Copyright (C) Tim van Mourik, 2015, DCCN


%% Parse configuration
subjectDirectory        = tvm_getOption(configuration, 'i_SubjectDirectory', pwd());
    %no default
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
newDimensions           = round(oldDimensions ./ voxelSize(:)' .* abs(scale));
newScale = (x1 - x0) ./ newDimensions;
newTranslation = x0 - newScale / 2;

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


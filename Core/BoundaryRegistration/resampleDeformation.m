function voxelGrid = resampleDeformation(volume, diffX, diffY, diffZ)
%RESAMPLEDEFORMATION produces a resampled volume using a gradientfield
%   V = RESAMPLEDEFORMATION(VOLUME, DX, DY, DZ)
%   Outputs a 3D volume, based on the input VOLUME and the three gradient
%   volumes. VOLUME, DX, DY and DZ are all filenames
%
%   Copyright (C) 2012-2013, Tim van Mourik, DCCN

v = spm_vol(volume);
dx = spm_vol(diffX);
dy = spm_vol(diffY);
dz = spm_vol(diffZ);

voxelGrid = spm_read_vols(v);
gradientField = zeros([size(voxelGrid), 3]);
gradientField(:, :, :, 1) = spm_read_vols(dx);
gradientField(:, :, :, 2) = spm_read_vols(dy);
gradientField(:, :, :, 3) = spm_read_vols(dz);

indices = zeros([size(voxelGrid), 3]);
[x, y, z] = ind2sub(size(voxelGrid), 1:numel(voxelGrid));
indices(:) = [x, y, z]; 

sampleField = indices + gradientField;
sampleX = sampleField(:, :, :, 1);
sampleY = sampleField(:, :, :, 2);
sampleZ = sampleField(:, :, :, 3);

configuration = [];
configuration.InterpolationMethod = 'Trilinear';
voxelGrid(:) = tvm_sampleVoxels(voxelGrid, sampleX(:), sampleY(:), sampleZ(:), configuration);

end %end function
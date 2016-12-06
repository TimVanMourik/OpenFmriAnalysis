function tvm_warpVolumes(configuration)
%
%
%   Copyright (C) 2016, Tim van Mourik, DCCN

%% Parse configuration
subjectDirectory =      	tvm_getOption(configuration, 'i_SubjectDirectory');
    %no default
displacementMapFile =       fullfile(subjectDirectory, tvm_getOption(configuration, 'i_DisplacementMap'));
    %no default
volumeIn =                  fullfile(subjectDirectory, tvm_getOption(configuration, 'i_Volume'));
    %no default
volumeOut =                 fullfile(subjectDirectory, tvm_getOption(configuration, 'o_Volume'));
    %no default

%%
vdm = spm_vol(displacementMapFile);
vdm.volume = spm_read_vols(vdm);
configuration.InterpolationMethod = 'Trilinear';

[y, x, z] = meshgrid(1:vdm.dim(2), 1:vdm.dim(1), 1:vdm.dim(3));
coordinates = [x(:), y(:) + vdm.volume(:), z(:)];

inputVolume = spm_vol(volumeIn);
vdm.volume(:) = tvm_sampleVoxels(spm_read_vols(inputVolume), coordinates, configuration);
inputVolume.fname = volumeOut;
spm_write_vol(inputVolume, vdm.volume);

end %end function

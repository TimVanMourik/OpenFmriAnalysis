function tvm_computeMeanVolume(configuration)
% TVM_REALIGNFUNCTIONALS
%   TVM_REALIGNFUNCTIONALS(configuration)
%   
%
%   Copyright (C) Tim van Mourik, 2014, DCCN
%
%   configuration.SubjectDirectory
%   configuration.NiftiDirectory
%   configuration.RealignmentDirectory
%   configuration.MeanFunctional

%% Parse configuration
subjectDirectory =      tvm_getOption(configuration, 'i_SubjectDirectory', pwd());
    %no default
niftiFolder =           fullfile(subjectDirectory, tvm_getOption(configuration, 'i_NiftiDirectory'));
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











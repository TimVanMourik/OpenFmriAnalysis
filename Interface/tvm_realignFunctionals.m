function tvm_realignFunctionals(configuration, realignmentConfiguration)
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
if nargin < 2
    realignmentConfiguration = [];
end

subjectDirectory =      tvm_getOption(configuration, 'i_SubjectDirectory');
    %no default
niftiFolder =           fullfile(subjectDirectory, tvm_getOption(configuration, 'i_NiftiDirectory'));
    %no default
realignmentFolder =   	fullfile(subjectDirectory, tvm_getOption(configuration, 'o_RealignmentDirectory'));
    %no default
meanName =              fullfile(subjectDirectory, tvm_getOption(configuration, 'o_MeanFunctional', 'MeanFunctional.nii'));
    %'MeanFunctional.nii'
    
definitions = tvm_definitions();  
%%
functionalCharacteristic = definitions.FunctionalData;
volumeFileTypes = definitions.VolumeFileTypes;

niftis = [];
for i = 1:length(functionalCharacteristic)
    for j = 1:length(volumeFileTypes)
        folder = dir(fullfile(niftiFolder, ['*' functionalCharacteristic{i} '*' volumeFileTypes{j}]));
        niftis = [niftis; {folder.name}];
    end
end

niftis = fullfile(niftiFolder, niftis(:));

%The only thing spm_realign does is creating the rp*.txt (only when no
%output argument are given
spm_realign(niftis, realignmentConfiguration);
spm_reslice(niftis, realignmentConfiguration);

oldMeanNifti = dir(fullfile(niftiFolder, 'mean*.nii'));
movefile(fullfile(niftiFolder, oldMeanNifti.name), meanName);
movefile(fullfile(niftiFolder, 'r*.nii'), realignmentFolder);
movefile(fullfile(niftiFolder, 'rp*.txt'), realignmentFolder);
movefile(fullfile(niftiFolder, '*.mat'), realignmentFolder);



end %end function





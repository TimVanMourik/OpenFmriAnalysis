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

subjectDirectory =      tvm_getOption(configuration, 'SubjectDirectory');
    %no default
niftiFolder =           fullfile(subjectDirectory, tvm_getOption(configuration, 'NiftiDirectory'));
    %no default
realignmentFolder =   	fullfile(subjectDirectory, tvm_getOption(configuration, 'RealignmentDirectory'));
    %no default
meanName =              fullfile(subjectDirectory, tvm_getOption(configuration, 'MeanFunctional', 'MeanFunctional.nii'));
    %'MeanFunctional.nii'

definitions = tvm_definitions;

%%
functionalCharacteristic = definitions.FunctionalData;

niftis = [];
for i = 1:length(functionalCharacteristic)
    folder = dir(fullfile(niftiFolder, ['*' functionalCharacteristic{i} '*']));
    niftis = [niftis; {folder.name}];
end

for i = 1:length(niftis)
    niftis{i} = [niftiFolder niftis{i}];
end

%The only thing spm_realign does is creating the rp*.txt (only when no
%output argument are given
spm_realign(niftis, realignmentConfiguration);
spm_reslice(niftis, realignmentConfiguration);

oldMeanNifti = dir(fullfile(niftiFolder, 'mean*.nii'));
movefile(fullfile(niftiFolder, oldMeanNifti.name), meanName);
movefile(fullfile(niftiFolder, 'r*.nii'), realignmentFolder);
movefile(fullfile(niftiFolder, 'r*.mat'), realignmentFolder);
movefile(fullfile(niftiFolder, 'rp*.txt'), realignmentFolder);



end %end function





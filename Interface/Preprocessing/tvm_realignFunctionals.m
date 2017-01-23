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

subjectDirectory        = tvm_getOption(configuration, 'i_SubjectDirectory', pwd());
    %no default
niftiFolder             = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_SourceDirectory'));
    %no default
characteristic          = tvm_getOption(configuration, 'i_Characteristic', '*');
    %no default
realignmentFolder       = fullfile(subjectDirectory, tvm_getOption(configuration, 'o_OutputDirectory'));
    %no default
meanName                = fullfile(subjectDirectory, tvm_getOption(configuration, 'o_MeanFunctional', 'MeanFunctional.nii'));
    %'MeanFunctional.nii'
    
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
    %------------------------------------------------------------------
    save_parameters(realignedNiftis{s});

    %-Update voxel to world mapping in images header
    %------------------------------------------------------------------
    for i=1:numel(realignedNiftis{s})
        spm_get_space([realignedNiftis{s}(i).fname ',' num2str(realignedNiftis{s}(i).n)], realignedNiftis{s}(i).mat);
    end
end

spm_reslice(realignedNiftis, realignmentConfiguration);

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


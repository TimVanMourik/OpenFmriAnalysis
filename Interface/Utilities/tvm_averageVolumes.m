function tvm_averageVolumes(configuration)
% TVM_AVERAGEVOLUMES
%   TVM_AVERAGEVOLUMES(configuration)
%   @todo Add description
%   
%
%   Copyright (C) Tim van Mourik, 2016, DCCN
%
% Input:
%   i_SubjectDirectory
%   i_NiftiFiles
% Output:
%   o_MeanVolume
%

%% Parse configuration
subjectDirectory =      tvm_getOption(configuration, 'i_SubjectDirectory', pwd());
    % default: current working directory
inputfile               = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_NiftiFiles'));
    %no default
meanFile                = fullfile(subjectDirectory, tvm_getOption(configuration, 'o_MeanVolume'));
    %no default
    
%%
files = spm_vol(inputfile);
meanVolume = spm_read_vols(files);
tvm_write4D(files(1), mean(meanVolume, 4), meanFile);

end %end function


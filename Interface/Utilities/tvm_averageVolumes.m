function tvm_averageVolumes(configuration)
%
%
%   Copyright (C) 2016, Tim van Mourik, DCCN

%% Parse configuration
subjectDirectory        = tvm_getOption(configuration, 'i_SubjectDirectory');
    %no default
inputfile               = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_NiftiFiles'));
    %no default
meanFile                = fullfile(subjectDirectory, tvm_getOption(configuration, 'o_MeanVolume'));
    %no default
    
%%
files = spm_vol(inputfile);
meanVolume = spm_read_vols(files);
tvm_write4D(files(1), mean(meanVolume, 4), meanFile);

end %end function


function tvm_thresholdVolume(configuration)
% TVM_THRESHOLDVOLUME
%   TVM_THRESHOLDVOLUME(configuration)
%   
%
%   Copyright (C) Tim van Mourik, 2014, DCCN
%
%   configuration.SubjectDirectory
%   configuration.Design
%   configuration.GlmOutput
%   configuration.ResidualSumOfSquares
%   configuration.TMap
%   configuration.Contrast

%% Parse configuration
subjectDirectory =      tvm_getOption(configuration, 'i_SubjectDirectory');
    %no default
volumeFile =            fullfile(subjectDirectory, tvm_getOption(configuration, 'i_Volume'));
    %no default
threshold =             tvm_getOption(configuration, 'i_Threshold', 1.96);
    % 1.96, two-tailed significance threshold
thresholdFile =         fullfile(subjectDirectory, tvm_getOption(configuration, 'o_ThresholdedVolume'));
    %no default
    
%%
v = spm_vol(volumeFile);
v.volume = spm_read_vols(v);
v.volume(v.volume < threshold) = 0;
v.fname = thresholdFile;

spm_write_vol(v, v.volume);

end %end function








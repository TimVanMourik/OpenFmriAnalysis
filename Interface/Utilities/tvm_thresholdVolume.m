function tvm_thresholdVolume(configuration)
% TVM_THRESHOLDVOLUME
%   TVM_THRESHOLDVOLUME(configuration)
%   @todo Add description
%   
%
%   Copyright (C) Tim van Mourik, 2014-2015, DCCN
%
% Input:
%   i_SubjectDirectory
%   i_Volume
%   i_Threshold
% Output:
%   o_ThresholdedVolume
%


%% Parse configuration
subjectDirectory =      tvm_getOption(configuration, 'i_SubjectDirectory', pwd());
    % default: current working directory
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








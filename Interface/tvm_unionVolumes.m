function tvm_unionVolumes(configuration)
% TVM_UNIONVOLUMES
%   TVM_UNIONVOLUMES(configuration)
%   
%
%   Copyright (C) Tim van Mourik, 2014, DCCN
%
%   configuration.SubjectDirectory
%   configuration.Input
%   configuration.IntersectionVolumes
%   configuration.Output

%% Parse configuration
subjectDirectory =    	tvm_getOption(configuration, 'i_SubjectDirectory');
    %no default
volumeFiles =          	fullfile(subjectDirectory, tvm_getOption(configuration, 'i_InputVolumes'));
    %no default
outputFile =            fullfile(subjectDirectory, tvm_getOption(configuration, 'o_OutputVolume'));
    %no default
    
%%
%Load the volume data

inputVolume = spm_vol(volumeFiles{1});
unionVolume = spm_read_vols(inputVolume);

for i = 2:length(volumeFiles)
    inputVolume = spm_vol(volumeFiles{i});
    unionVolume = unionVolume | spm_read_vols(inputVolume);
end
inputVolume.fname = outputFile;
inputVolume.dt = [2, 0];
spm_write_vol(inputVolume, unionVolume);

end %end function
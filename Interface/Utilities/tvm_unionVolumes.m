function tvm_unionVolumes(configuration)
% TVM_UNIONVOLUMES
%   TVM_UNIONVOLUMES(configuration)
%   @todo Add description
%   
%
%   Copyright (C) Tim van Mourik, 2014-2015, DCCN
%
% Input:
%   i_SubjectDirectory
%   i_InputVolumes
% Output:
%   o_OutputVolume
%

%% Parse configuration
subjectDirectory =      tvm_getOption(configuration, 'i_SubjectDirectory', pwd());
    % default: current working directory
volumeFiles =           tvm_getOption(configuration, 'i_InputVolumes');
    %no default
outputFile =            fullfile(subjectDirectory, tvm_getOption(configuration, 'o_OutputVolume'));
    %no default
    
%%
for i = 1:length(volumeFiles)
    inputVolumes = fullfile(subjectDirectory, volumeFiles{i});

    currentVolume = spm_vol(inputVolumes{1});
    unionVolume = spm_read_vols(currentVolume);

    for j = 2:length(volumeFiles{i})
        currentVolume = spm_vol(inputVolumes{j});
        unionVolume = unionVolume | spm_read_vols(currentVolume);
    end
    currentVolume.fname = outputFile{i};
    spm_write_vol(currentVolume, unionVolume);
end

end %end function
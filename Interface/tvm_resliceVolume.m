function tvm_resliceVolume(configuration)
% TVM_RESLICEVOLUME
%   TVM_RESLICEVOLUME(configuration)
%   
%
%   Copyright (C) Tim van Mourik, 2014, DCCN
%
%   configuration.SubjectDirectory
%   configuration.LabelFiles
%   configuration.Hemisphere
%   configuration.VolumeFiles
%   configuration.ReferenceVolume
%   configuration.Boundaries
%

%% Parse configuration
subjectDirectory 	= tvm_getOption(configuration, 'i_SubjectDirectory');
    %no default
referenceVolumeFile = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_ReferenceVolume'));
    %no default
coregistrationFile  = tvm_getOption(configuration, 'i_CoregistrationMatrix', []);
    %no default
moveFiles           = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_MoveVolumes'));
    %no default
inverseRegistration = tvm_getOption(configuration, 'i_InverseRegistration', false);
    %no default
volumeFiles         = fullfile(subjectDirectory, tvm_getOption(configuration, 'o_OutputVolumes'));
    %no default
    
%%
if isempty(coregistrationFile)
    coregistrationMatrix = eye(4);
else
    coregistrationFile = fullfile(subjectDirectory, coregistrationFile);
    load(coregistrationFile, 'coregistrationMatrix');
    if inverseRegistration
        coregistrationMatrix = inv(coregistrationMatrix);
    end
end

reference = spm_vol(referenceVolumeFile);

files = spm_vol(moveFiles);
for i = 1:length(files)
    files{i}.mat = coregistrationMatrix \ files{i}.mat;
end
files = [reference, files{:}];
spm_reslice(files);

for i = 1:length(moveFiles)
    [root, file, extension] = fileparts(moveFiles{i});
    movefile(fullfile(root, ['r', file, extension]), volumeFiles{i});
end

end %end function







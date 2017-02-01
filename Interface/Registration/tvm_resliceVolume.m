function tvm_resliceVolume(configuration)
% TVM_RESLICEVOLUME(configuration)
%   TVM_RESLICEVOLUME(configuration)
%   @todo Add description
%   
%
%   Copyright (C) Tim van Mourik, 2014-2015, DCCN
%
% Input:
%   i_SubjectDirectory
%   i_ReferenceVolume
%   i_CoregistrationMatrix
%   i_MoveVolumes
%   i_InterpolationMethod
%   i_InverseRegistration
% Output:
%   o_OutputVolumes
%

%% Parse configuration
subjectDirectory 	= tvm_getOption(configuration, 'i_SubjectDirectory');
    % default: current working directory
referenceVolumeFile = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_ReferenceVolume'));
    %no default
coregistrationFile  = tvm_getOption(configuration, 'i_CoregistrationMatrix', []);
    % default: empty
moveFiles           = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_MoveVolumes'));
    %no default
interpolationMethod = tvm_getOption(configuration, 'i_InterpolationMethod', false);
    % default: false
inverseRegistration = tvm_getOption(configuration, 'i_InverseRegistration', false);
    % default: false
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
cfg = [];
switch interpolationMethod
    case 'NearestNeighbour'
        cfg.interp = 0;
    otherwise
        cfg.interp = 1;
end
spm_reslice(files, cfg);

for i = 1:length(moveFiles)
    [root, file, extension] = fileparts(moveFiles{i});
    movefile(fullfile(root, ['r', file, extension]), volumeFiles{i});
end

end %end function







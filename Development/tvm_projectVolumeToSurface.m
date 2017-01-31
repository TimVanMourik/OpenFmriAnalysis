function tvm_projectVolumeToSurface(configuration)
% TVM_PROJECTVOLUMETOSURFACE
%   TVM_PROJECTVOLUMETOSURFACE(configuration)
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
subjectDirectory 	= tvm_getOption(configuration, 'i_SubjectDirectory', pwd());
    %no default
volumeFiles         = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_VolumeFiles'));
    %no default
registrationFile    = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_RegistrationFile'));
    %no default
freeSurferSubject   = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_FreeSurfer', 'FreeSurfer'));
    %'FreeSurfer'
surfaceFilesRight   = fullfile(subjectDirectory, tvm_getOption(configuration, 'o_SurfaceFilesRightHemisphere'));
    %no default
surfaceFilesLeft    = fullfile(subjectDirectory, tvm_getOption(configuration, 'o_SurfaceFilesLeftHemisphere'));
    %no default
    
%%
[freeSurferPath, freeSurferSubject] = fileparts(freeSurferSubject);

for i = 1:length(volumeFiles)
    volumeFile = volumeFiles{i};
    outputFileRH = surfaceFilesRight{i};
    hemisphere = 'rh';
    unixCommand = sprintf('mri_vol2surf --mov %s --reg %s --o %s --out_type paint --hemi %s --sd %s --srcsubject %s;', volumeFile, registrationFile, outputFileRH, hemisphere, freeSurferPath, freeSurferSubject);
    unix(unixCommand);
    
    outputFileLH = surfaceFilesLeft{i};
    hemisphere = 'lh';
    unixCommand = sprintf('mri_vol2surf --mov %s --reg %s --o %s --out_type paint --hemi %s --sd %s --srcsubject %s;', volumeFile, registrationFile, outputFileLH, hemisphere, freeSurferPath, freeSurferSubject);
    unix(unixCommand);
end

end %end function







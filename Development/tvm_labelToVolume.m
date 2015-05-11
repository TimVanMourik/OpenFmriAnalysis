function tvm_labelToVolume(configuration)
% TVM_LABELSTOVOLUME
%   TVM_LABELSTOVOLUME(configuration)
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
labelFiles          = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_LabelFiles'));
    %no default
hemispheres         = tvm_getOption(configuration, 'i_Hemisphere');
    %no default
coregistrationFile  = tvm_getOption(configuration, 'i_CoregistrationMatrix', []);
    %no default
referenceVolumeFile = tvm_getOption(configuration, 'i_ReferenceVolume');
    %no default
volumeFiles         = fullfile(subjectDirectory, tvm_getOption(configuration, 'o_VolumeFile'));
    %no default
freeSurferSubject   = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_FreeSurfer', 'FreeSurfer'));
    %'FreeSurfer'
    
%%
[freeSurferPath, freeSurferSubject] = fileparts(freeSurferSubject);

for i = 1:length(labelFiles)
    unixCommand = [];
    unixCommand = [unixCommand 'SUBJECTS_DIR=' freeSurferPath ';'];

    filterThreshold = 0.3;
    projectionParameters = 'frac 0 1 .1';
    origFile = fullfile(freeSurferPath, freeSurferSubject, 'mri/orig.nii');
    unixCommand = [unixCommand, sprintf('mri_label2vol --label %s --temp %s --fillthresh %f --proj %s --subject %s --hemi %s --o %s --identity;', labelFiles{i}, origFile, filterThreshold, projectionParameters, freeSurferSubject,hemispheres{i}, volumeFiles{i})]; 
    unix(unixCommand);
end

cfg = [];
cfg.i_SubjectDirectory      = tvm_getOption(configuration, 'i_SubjectDirectory');
cfg.i_ReferenceVolume       = referenceVolumeFile;
cfg.i_CoregistrationMatrix  = coregistrationFile;
cfg.i_MoveVolumes           = tvm_getOption(configuration, 'o_VolumeFile');
cfg.o_OutputVolumes         = tvm_getOption(configuration, 'o_VolumeFile');
tvm_resliceVolume(cfg);

end %end function







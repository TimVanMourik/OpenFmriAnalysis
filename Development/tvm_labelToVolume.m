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
subjectDirectory 	= tvm_getOption(configuration, 'i_SubjectDirectory', pwd());
    %no default
labelFiles          = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_LabelFiles'));
    %no default
hemispheres         = tvm_getOption(configuration, 'i_Hemisphere');
    %no default
coregistrationFile  = tvm_getOption(configuration, 'i_CoregistrationMatrix', []);
    %no default
referenceVolumeFile = tvm_getOption(configuration, 'i_ReferenceVolume');
    %no default
registerDat         = tvm_getOption(configuration, 'i_RegisterDat', '');
    %no default
freeSurferSubject   = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_FreeSurfer', 'FreeSurfer'));
    %'FreeSurfer'
volumeFiles         = fullfile(subjectDirectory, tvm_getOption(configuration, 'o_VolumeFile'));
    %no default
    
%%
[freeSurferPath, freeSurferSubject] = fileparts(freeSurferSubject);
if isempty(registerDat)
    registrationFile = ' --identity';
else
    registrationFile = [' --invertmtx --reg ' fullfile(subjectDirectory, registerDat)];
end

for i = 1:length(labelFiles)
    unixCommand = [];
    unixCommand = [unixCommand 'SUBJECTS_DIR=' freeSurferPath ';'];

    filterThreshold = 0.3;
    projectionParameters = 'frac 0 1 .1';
    origFile = fullfile(freeSurferPath, freeSurferSubject, 'mri/orig.nii');
    if ~exist(origFile, 'file')
        unix(sprintf('mri_convert %s %s', [origFile(1:end-4), '.mgz'], origFile));
    end
    if ~exist(labelFiles{i}, 'file')
        error('Label cannot be found.');
    end
%     unixCommand = [unixCommand, sprintf('mri_label2vol --fill-ribbon --label %s --temp %s --fillthresh %f --proj %s --subject %s --hemi %s --o %s --identity;', labelFiles{i}, origFile, filterThreshold, projectionParameters, freeSurferSubject,hemispheres{i}, volumeFiles{i})]; 
%     unixCommand = [unixCommand, sprintf('mri_label2vol --label %s --temp %s --fillthresh %f --proj %s --subject %s --hemi %s --o %s --identity;', labelFiles{i}, origFile, filterThreshold, projectionParameters, freeSurferSubject,hemispheres{i}, volumeFiles{i})]; 
    if strcmp(labelFiles{i}(end-5:end), '.label')
        unixCommand = [unixCommand, sprintf('mri_label2vol --label %s --temp %s --fillthresh %f --proj %s --subject %s --hemi %s --o %s --identity;', labelFiles{i}, origFile, filterThreshold, projectionParameters, freeSurferSubject,hemispheres{i}, volumeFiles{i})]; 
    elseif strcmp(labelFiles{i}(end-5:end), '.annot')
        unixCommand = [unixCommand, sprintf('mri_label2vol --annot %s --temp %s --fillthresh %f --proj %s --subject %s --hemi %s --o %s %s;', labelFiles{i}, origFile, filterThreshold, projectionParameters, freeSurferSubject,hemispheres{i}, volumeFiles{i}, registrationFile)]; 
    end
    unix(unixCommand);
end

if ~isempty(coregistrationFile)
    cfg = [];
    cfg.i_SubjectDirectory      = tvm_getOption(configuration, 'i_SubjectDirectory');
    cfg.i_ReferenceVolume       = referenceVolumeFile;
    cfg.i_CoregistrationMatrix  = coregistrationFile;
    cfg.i_InterpolationMethod   = 'NearestNeighbour';
    cfg.i_MoveVolumes           = tvm_getOption(configuration, 'o_VolumeFile');
    cfg.o_OutputVolumes         = tvm_getOption(configuration, 'o_VolumeFile');
    tvm_resliceVolume(cfg);
end

end %end function







function tvm_realignDataAfni(configuration)
% TVM_REALIGNFUNCTIONALS
%   TVM_REALIGNFUNCTIONALS(configuration)
%   
%
%   Copyright (C) Tim van Mourik, 2014, DCCN
%
%   configuration.SubjectDirectory
%   configuration.NiftiDirectory
%   configuration.RealignmentDirectory
%   configuration.MeanFunctional

%% Parse configuration
subjectDirectory   	= tvm_getOption(configuration, 'i_SubjectDirectory', pwd());
    %no default
niftiFiles         	= fullfile(subjectDirectory, tvm_getOption(configuration, 'i_NiftiFiles'));
    %no default
realignmentFiles 	= fullfile(subjectDirectory, tvm_getOption(configuration, 'o_RealignmentFiles'));
    %no default
% meanName          	= fullfile(subjectDirectory, tvm_getOption(configuration, 'o_Mean', []));
    %no default
motionInfo        	= fullfile(subjectDirectory, tvm_getOption(configuration, 'o_RealignmentInformation', []));
    %no default
realignmentMatrix 	= fullfile(subjectDirectory, tvm_getOption(configuration, 'o_RealignmentMatrix'));
    %no default
    
%%
% oldMeanNifti = dir(fullfile(niftiFolder, 'mean*.nii'));
% movefile(fullfile(niftiFolder, oldMeanNifti.name), meanName);
% movefile(fullfile(niftiFolder, 'r*.nii'), realignmentFolder);
% movefile(fullfile(niftiFolder, 'rp*.txt'), realignmentFolder);
% movefile(fullfile(niftiFolder, '*.mat'), realignmentFolder);

verbose             = '-verbose';
zPadding            = '-zpad 15';
numberOfPasses      = '-twopass';
maxIterations       = '-maxite 128';
edging              = '-edging 15%';
baseFile            = ['-base ' niftiFiles '''[0]'''];
heptic              = '-heptic';
prefix              = ['-prefix ', realignmentFiles];
motionData          = ['-1Dfile ' motionInfo];
matrixData          = ['-1Dmatrix_save  ' realignmentMatrix];
actualInput         = niftiFiles;

delete(realignmentFiles);
delete(motionInfo);
delete(realignmentMatrix);
unixCommand = sprintf('3dvolreg %s %s %s %s %s %s %s %s %s %s %s', verbose, zPadding, numberOfPasses, maxIterations, edging, baseFile, heptic, prefix, motionData, matrixData, actualInput);
unix(unixCommand);
    
end %end function





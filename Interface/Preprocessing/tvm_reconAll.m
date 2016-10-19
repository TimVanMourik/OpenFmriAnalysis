function tvm_reconAll(configuration)
% TVM_RECONALL 
%   TVM_RECONALL(configuration)
%   From a structural scan, this matlab routine runs FreeSurfer
%
%   Copyright (C) Tim van Mourik, 2014, DCCN
%
%   configuration.SubjectDirectory
%   configuration.Structural

%% Parse configuration
subjectDirectory    = tvm_getOption(configuration, 'i_SubjectDirectory', pwd());
    %no default
structuralScan      = tvm_getOption(configuration, 'i_Structural');
    %no default
highRes             = tvm_getOption(configuration, 'i_HighRes', false);
    %no default
expertFile          = tvm_getOption(configuration, 'i_ExpertFile', '');
    %no default
timeRequirement     = tvm_getOption(configuration, 'i_ComputationTime', '22:00:00');
    %no default
memoryRequirement   = tvm_getOption(configuration, 'i_Memory', '8gb');
    %no default
freeSurferFolder    = tvm_getOption(configuration, 'i_FreeSurferFolder', 'FreeSurfer');
    %'FreeSurfer'
    
%%
%if a copy exists, the old copy is backed-up
if exist(fullfile(subjectDirectory, freeSurferFolder), 'dir')
    if ~exist(fullfile(subjectDirectory, [freeSurferFolder 'Old']), 'dir')
        mkdir(fullfile(subjectDirectory, [freeSurferFolder 'Old']));
    end
    movefile(fullfile(subjectDirectory, freeSurferFolder, '*'), fullfile(subjectDirectory, [freeSurferFolder 'Old'], '*'));
    rmdir([subjectDirectory freeSurferFolder], 's');
end

if highRes
    highResCommand = '-hires';
else
    highResCommand = '';
end

if ~isempty(expertFile)
    expertCommand = ['-expert ' fullfile(subjectDirectory, expertFile)];
else
    expertCommand = '';
end

qScript = fullfile(subjectDirectory, 'FreeSurferScript.sh');
qsubCommand = ['qsub -l walltime=' timeRequirement ',mem=' memoryRequirement ' ' qScript];

f = fopen(qScript, 'w');
fprintf(f, '#!/bin/bash\n');
unixCommand = ['SUBJECTS_DIR=', subjectDirectory ';'];
fprintf(f, '%s\n', unixCommand);
unixCommand = sprintf('recon-all -all -subjid %s -i %s %s %s;', freeSurferFolder, fullfile(subjectDirectory, structuralScan), highResCommand, expertCommand);
fprintf(f, '%s\n', unixCommand);
unixCommand = ['rm ' qScript ';'];
fprintf(f, '%s\n', unixCommand);
unixCommand = 'exit;';
fprintf(f, '%s', unixCommand);

fclose(f);
fileattrib(qScript, '+x');

unix(qsubCommand);

end %end function








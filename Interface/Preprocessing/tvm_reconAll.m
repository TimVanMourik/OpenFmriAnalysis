function tvm_reconAll(configuration)
% TVM_RECONALL 
%   TVM_RECONALL(configuration)
%   From a structural scan, this matlab routine runs FreeSurfer
%   @todo Expand description
%
% Input:
%   i_SubjectDirectory
%   i_Structural
%   i_HighRes
%   i_ExpertFile
%   i_ComputationTime
%   i_Memory
% Output:
%   o_FreeSurferFolder
%

%   Copyright (C) Tim van Mourik, 2014-2015, DCCN
%
% This file is part of the fmri analysis toolbox, see 
% https://github.com/TimVanMourik/FmriAnalysis for the documentation and 
% details.
%
%    This toolbox is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    This toolbox is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with the fmri analysis toolbox. If not, see 
%    <http://www.gnu.org/licenses/>.

%% Parse configuration
subjectDirectory    = tvm_getOption(configuration, 'i_SubjectDirectory', pwd());
    % default: current working directory
structuralScan      = tvm_getOption(configuration, 'i_Structural');
    %no default
highRes             = tvm_getOption(configuration, 'i_HighRes', false);
    % default: false
expertFile          = tvm_getOption(configuration, 'i_ExpertFile', '');
    % default: empty
timeRequirement     = tvm_getOption(configuration, 'i_ComputationTime', '22:00:00');
    % default: 22 hours
memoryRequirement   = tvm_getOption(configuration, 'i_Memory', '8gb');
    % default: 8 Gb
freeSurferFolder    = tvm_getOption(configuration, 'o_FreeSurferFolder', 'FreeSurfer');
    %'default: FreeSurfer'
    
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








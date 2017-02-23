function tvm_restoreBackupFiles(configuration)
% TVM_RESTOREBACKUPFILES
%   TVM_RESTOREBACKUPFILES(configuration)
%   @todo Add description
%
% Input:
%   i_SubjectDirectory
%   i_Files
%   i_Suffix
% Output:
%

%   Copyright (C) Tim van Mourik, 2015, DCCN
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
subjectDirectory =      tvm_getOption(configuration, 'i_SubjectDirectory', pwd());
    % default: current working directory
files =                     fullfile(subjectDirectory, tvm_getOption(configuration, 'i_Files'));
    %no default
suffix =                    tvm_getOption(configuration, 'i_Suffix', '_backup');
    %no default
 
%%
for i = 1:length(files)
    [root, file, extension] = fileparts(files{i});
    backupFile = fullfile(root, [file suffix extension]);
    if exist(backupFile, 'file')
        copyfile(backupFile, files{i});  
    end
end

end %end function














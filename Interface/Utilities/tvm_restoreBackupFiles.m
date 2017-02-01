function tvm_restoreBackupFiles(configuration)
% TVM_RESTOREBACKUPFILES
%   TVM_RESTOREBACKUPFILES(configuration)
%   @todo Add description
%   
%
%   Copyright (C) Tim van Mourik, 2015, DCCN
%
% Input:
%   i_SubjectDirectory
%   i_Files
%   i_Suffix
% Output:
%

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














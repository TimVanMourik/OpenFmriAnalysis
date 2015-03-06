function tvm_restoreBackupFiles(configuration)
% TVM_BACKUPFILES 
%   TVM_BACKUPFILES(configuration)
%   
%   Copyright (C) Tim van Mourik, 2015, DCCN
%
%   configuration.i_SubjectDirectory
%   configuration.i_Files
%   configuration.p_Suffix

%% Parse configuration
subjectDirectory =      	tvm_getOption(configuration, 'i_SubjectDirectory');
    %no default
files =                     fullfile(subjectDirectory, tvm_getOption(configuration, 'i_Files'));
    %no default
suffix =                    tvm_getOption(configuration, 'p_Suffix', '_backup');
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














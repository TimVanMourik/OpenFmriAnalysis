function tvm_backupFiles(configuration)
% TVM_AVERAGEVOLUMES
%   TVM_AVERAGEVOLUMES(configuration)
%   @todo Add description
%   
%
%   Copyright (C) Tim van Mourik, 2016, DCCN
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
    % default: 'backup'
 
%%
for i = 1:length(files)
    [root, file, extension] = fileparts(files{i});
    copyfile(files{i}, fullfile(root, [file suffix extension]));
end

end %end function














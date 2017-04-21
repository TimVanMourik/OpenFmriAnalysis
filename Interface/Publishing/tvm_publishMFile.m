function tvm_publishMFile(configuration)
%% Parse configuration
subjectDirectory        = tvm_getOption(configuration, 'i_RootDirectory', pwd());
    % default: current working directory
    %no default
mFile                   = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_Mfile'));
    %no default

%% 
[root, ~, ~] = fileparts(mFile);
addpath(root);
options = [];
options.format      = 'pdf';
options.showCode    = false;
publish(mFile, options);
close('all');

end %end function

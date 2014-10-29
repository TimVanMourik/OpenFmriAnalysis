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
subjectDirectory =  tvm_getOption(configuration, 'SubjectDirectory');
    %no default
structuralScan = tvm_getOption(configuration, 'Structural');
    %no default
subjectName = tvm_getOption(configuration, 'SubjectName', 'FreeSurfer');
    %'FreeSurfer'
    
%%
%if a copy exists, the old copy is backed-up
if exist(fullfile(subjectDirectory, subjectName), 'dir')
    if ~exist(fullfile(subjectDirectory, [subjectName 'Old']), 'dir')
        mkdir(fullfile(subjectDirectory, [subjectName 'Old']));
    end
    movefile(fullfile(subjectDirectory, subjectName, '*'), fullfile(subjectDirectory, [subjectName 'Old'], '*'));
    rmdir([subjectDirectory subjectName], 's');
end

unixCommand = ['SUBJECTS_DIR=', subjectDirectory ';'];
unixCommand = [unixCommand 'recon-all -subjid ' subjectName ' -i ' subjectDirectory structuralScan ' -all;'];
unix(unixCommand);

end %end function
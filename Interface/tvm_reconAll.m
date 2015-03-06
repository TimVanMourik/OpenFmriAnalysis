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
subjectDirectory =  tvm_getOption(configuration, 'i_SubjectDirectory');
    %no default
structuralScan = tvm_getOption(configuration, 'i_Structural');
    %no default
freeSurferFolder = tvm_getOption(configuration, 'i_FreeSurferFolder', 'FreeSurfer');
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

unixCommand = ['SUBJECTS_DIR=', subjectDirectory ';'];
unixCommand = [unixCommand 'recon-all -subjid ' freeSurferFolder ' -i ' fullfile(subjectDirectory, structuralScan) ' -all;'];
unix(unixCommand);

end %end function
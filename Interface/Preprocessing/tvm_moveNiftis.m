function tvm_moveNiftis(configuration)
% TVM_MOVENIFTIS Moves niftis to destination folder
%   TVM_MOVENIFTIS(configuration)
%
%   Copyright (C) Tim van Mourik, 2014, DCCN
%
%   configuration.i_SubjectDirectory
%   configuration.i_SourceFolder
%   configuration.i_Characteristic
%   configuration.o_Destination

%% Parse configuration
subjectDirectory    =      tvm_getOption(configuration, 'i_SubjectDirectory', pwd());
    %no default
sourceFolder        = [subjectDirectory, tvm_getOption(configuration, 'i_SourceFolder')];
    %no default
characteristic      = tvm_getOption(configuration, 'i_Characteristic', []);
    %no default
destination         = fullfile(subjectDirectory, tvm_getOption(configuration, 'o_Destination'));
    %no default
    
%%
folders = dir(fullfile(sourceFolder, characteristic));
folders = folders([folders.isdir]);
functionals = {folders.name}'; 
for i = 1:length(functionals)
    if ~isempty(dir(fullfile(sourceFolder, functionals{i}, '*.nii')))
        movefile(fullfile(sourceFolder, functionals{i}, '*.nii'), destination);  %to move functional folders remome '/' '*.nii'
    end
end

end %end function












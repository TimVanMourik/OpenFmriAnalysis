function tvm_moveNiftis(configuration)
% TVM_MOVENIFTIS Moves niftis to destination folder
%   TVM_MOVENIFTIS(configuration)
%   @todo Add description
%   
%
%   Copyright (C) Tim van Mourik, 2014-2015, DCCN
%
% Input:
%   i_SubjectDirectory
%   i_Characteristic
% Output:
%   o_OutputDirectory
%

%% Parse configuration
subjectDirectory    = tvm_getOption(configuration, 'i_SubjectDirectory', pwd());
    % default: current working directory
sourceFolder        = [subjectDirectory, tvm_getOption(configuration, 'i_SourceDirectory')];
    %no default
characteristic      = tvm_getOption(configuration, 'i_Characteristic', []);
    % default: empty
destination         = fullfile(subjectDirectory, tvm_getOption(configuration, 'o_OutputDirectory'));
    % default: empty
    
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












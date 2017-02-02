function tvm_moveNiftis(configuration)
% TVM_MOVENIFTIS Moves niftis to destination folder
%   TVM_MOVENIFTIS(configuration)
%   @todo Add description
%
% Input:
%   i_SubjectDirectory
%   i_Characteristic
% Output:
%   o_OutputDirectory
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












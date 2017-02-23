function tvm_dicomsToNifti(configuration)
% TVM_DICOMSTONIFTI
%   TVM_DICOMSTONIFTI(configuration)
%   @todo Add description
%
% Input:
%   i_SubjectDirectory
%   i_SourceDirectory
%   i_Characteristic
% Output:
%   ...
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
subjectDirectory =      tvm_getOption(configuration, 'i_SubjectDirectory', pwd());
    % default: current working directory
dicomDirectory      = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_SourceDirectory'));
    %no default
characteristic      = tvm_getOption(configuration, 'i_Characteristic', []);
    %no default

definitions = tvm_definitions();
%%
if isempty(characteristic)
    folders = dir(fullfile(dicomDirectory, '*'));
else
    folders = dir(fullfile(dicomDirectory, [characteristic '*']));
end
folders = folders([folders.isdir]);
for folder = {folders.name}
    if ~strcmp(folder{1}(1), '.')
% @todo check if folder contains .nii
% @todo make display of output optional
        % g, gzip images: no
        % r, reorient images: no
        % x, reorient and crop images: no
        % c, look in subdirectories: no
        unix(['dcm2nii -g n -r n -x n -c n ' fullfile(dicomDirectory, folder{1}) '/*.IMA;']);

        currentFolder = char(folder);
        %For the MP2RAGE we've got a special treatment, as the file type
        %need to appear in the file name.
        mp2rage = definitions.MP2RAGE;
        allFiles = [];
        for i = 1:length(mp2rage)
            if ~isempty(strfind(currentFolder, mp2rage{i}))
                fileTypes = definitions.DicomFileTypes;
                for j = 1:length(fileTypes)
%                     currentFiles = dir([dicomDirectory currentFolder '/' fileTypes{j}]);
                    currentFiles = dir(fullfile(dicomDirectory, currentFolder, ['*' fileTypes{j}]));
                    allFiles = [allFiles; {currentFiles.name}]; %#ok<AGROW>
                end   
                testFile = char(allFiles(1));
                info = dicominfo(fullfile(dicomDirectory, currentFolder, testFile));
                newName = info.SeriesDescription;
                movefile(fullfile(dicomDirectory, currentFolder), fullfile(dicomDirectory, newName));
                
            end                
%         extract subsequence in string
%         check with dicominfo the .SeriesDescription field
%         add to nifi file name the mp2rage type
         end
    end
end

end %end function









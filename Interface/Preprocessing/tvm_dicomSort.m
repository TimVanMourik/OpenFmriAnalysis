function tvm_dicomSort(configuration)
% TVM_DICOMSORT Makes a folder structure from dicoms
%   TVM_DICOMSORT(configuration)
%   Sorts DICOM files into local subdirectories with a SeriesNumber_ProtocolName
%   name. Files are moved if Opt is 'move' (default), else a symbolic link is made
%   with a PatientsName_ProtocolName_SeriesNumber_InstanceNumber naming convention
%   (unix only).
%
% Input:
%   i_SubjectDirectory
%   i_MoveOption
% Output:
%   o_Curvature
%

%   Copyright (C) 2011, Marcel Zwiers, DCCN, Tim van Mourik, 2014, DCCN
%   Copyright (C) Tim van Mourik, 2015-2016, DCCN
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
moveOption =        tvm_getOption(configuration, 'i_MoveOption', 'move');
    %move
    %link
dicomDirectory =    fullfile(subjectDirectory, tvm_getOption(configuration, 'i_SourceDirectory'));
    %no default
    
definitions = tvm_definitions();
%%
fileTypes = definitions.DicomFileTypes;
fileNames = [];
for i = 1:length(fileTypes)
    allFiles = dir(fullfile(dicomDirectory, ['*' fileTypes{i}]));
    fileNames = [fileNames; {allFiles.name}]; %#ok<AGROW>
end

%@todo make a nice fullfile out of this
fullFileNames = [repmat([dicomDirectory '/'], [length(fileNames), 1]), char(fileNames{:})];

if isempty(fullFileNames)
    fprintf('No dicoms were found that need to be sorted.\n');
    return
end

allProtocolDirectories = {''};
fileNames	 = cell(size(fullFileNames,1), 1);
%H = waitbar(0, ['Sorting ' num2str(size(FNames,1)) ' files...'], 'Name','dicom_sort');
for file = 1:size(fullFileNames,1)
    dicomHeader	 = spm_dicom_headers(fullFileNames(file,:), true);
	dicomHeader	 = dicomHeader{1};
	protocolDirectory = [fileparts(fullFileNames(file,:)) filesep sprintf('%02d',dicomHeader.SeriesNumber) ...
				'_' strtrim(dicomHeader.ProtocolName)];
	if ~any(strcmp(protocolDirectory, allProtocolDirectories))		% We have a new dir/protocol
		allProtocolDirectories = [allProtocolDirectories protocolDirectory]; %#ok<AGROW>
        if ~exist(protocolDirectory, 'dir')
			mkdir(protocolDirectory)
        end
	end
	switch moveOption
        case 'move'
            [~, fileName, extension] = fileparts(strtrim(fullFileNames(file,:)));
            fileNames{file} = fullfile(protocolDirectory, [fileName extension]);
            movefile(strtrim(fullFileNames(file,:)), fileNames{file}, 'f')
        case 'link'
            if ~isunix()
                error('Linking option is implemented for unix/linux only')
            end
            fileNames{file} = sprintf('%s%s%s_%s_%04d_%04d.dcm', protocolDirectory, filesep, ...
                strtrim(dicomHeader.PatientsName), strtrim(dicomHeader.ProtocolName), ...
                dicomHeader.SeriesNumber, dicomHeader.InstanceNumber);
            unix(['ln -sf ' strtrim(fullFileNames(file,:)) ' ' fileNames{file}]);

        otherwise
		error('This option is not implemented')
	end
end

end %end function







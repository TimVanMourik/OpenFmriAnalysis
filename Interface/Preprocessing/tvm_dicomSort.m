function tvm_dicomSort(configuration)
% TVM_DICOMSORT Makes a folder structure from dicoms
%   TVM_DICOMSORT(configuration)
%   Sorts DICOM files into local subdirectories with a SeriesNumber_ProtocolName
%   name. Files are moved if Opt is 'move' (default), else a symbolic link is made
%   with a PatientsName_ProtocolName_SeriesNumber_InstanceNumber naming convention
%   (unix only).
%
%   Copyright (C) 2011, Marcel Zwiers, DCCN
%   Adapted by Tim van Mourik, 2014, DCCN
%
%   configuration.SubjectDirectory
%   configuration.MoveOption
%       -'move'
%       -'link'

%% Parse configuration
subjectDirectory =      tvm_getOption(configuration, 'i_SubjectDirectory', pwd());
    %no default
moveOption =        tvm_getOption(configuration, 'p_MoveOption', 'move');
    %move
    %link
dicomDirectory =    fullfile(subjectDirectory, tvm_getOption(configuration, 'i_DicomDirectory'));
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
            [~, FName, Ext] = fileparts(strtrim(fullFileNames(file,:)));
            fileNames{file} = fullfile(protocolDirectory, [FName Ext]);
            movefile(strtrim(fullFileNames(file,:)), fileNames{file}, 'f')
        case 'link'
            if isunix()
                fileNames{file} = sprintf('%s%s%s_%s_%04d_%04d.dcm', protocolDirectory, filesep, ...
                    strtrim(dicomHeader.PatientsName), strtrim(dicomHeader.ProtocolName), ...
                    dicomHeader.SeriesNumber, dicomHeader.InstanceNumber);
                unix(['ln -sf ' strtrim(fullFileNames(file,:)) ' ' fileNames{file}]);
            else
                error('Linking option is implemented for unix/linux only')
            end
        otherwise
		error('This option is not implemented')
	end
end

end %end function






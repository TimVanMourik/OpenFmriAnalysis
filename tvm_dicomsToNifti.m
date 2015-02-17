function tvm_dicomsToNifti(configuration)
% TVM_DICOMSTONIFTI Makes niftis out of dicoms
%   TVM_DICOMSTONIFTI(configuration)
%
%   Copyright (C) Tim van Mourik, 2014, DCCN
%
%   configuration.SubjectDirectory
%   configuration.DicomDirectory

% @todo Make sure copies are removed.
%% Parse configuration
subjectDirectory    = tvm_getOption(configuration, 'SubjectDirectory');
    %no default
dicomDirectory      = fullfile(subjectDirectory, tvm_getOption(configuration, 'DicomDirectory'));
    %no default
characteristic      = tvm_getOption(configuration, 'Characteristic', []);
    %no default

definitions = tvm_definitions;
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
        
        unix(['dcm2nii -g n -r n -x n ' fullfile(dicomDirectory, folder{1}) ';']);

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









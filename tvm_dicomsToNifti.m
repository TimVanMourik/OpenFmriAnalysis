function [memoryUsage, computationTime] = tvm_dicomsToNifti(configuration)

tic
memtic

subjectDirectory = configuration.SubjectDirectory;

definitions = tvm_definitions;

dicoms = [subjectDirectory configuration.DicomsDirectory];
folders = dir([dicoms '*']);
folders = folders([folders.isdir]);
for folder = {folders.name}
    if ~strcmp(folder{1}(1), '.')
% @todo check if folder contains .nii
% @todo make display of output optional
%        unix(['dcm2nii -g n -r n -x n -o ' dicoms ' ' dicoms folder{1} ';']);
        unix(['dcm2nii -g n -r n -x n ' dicoms folder{1} ';']);

        currentFolder = char(folder);
        mp2rage = definitions.mp2rage;
        allFiles = [];
        for i = 1:length(mp2rage)
            if ~isempty(strfind(currentFolder, mp2rage{i}))
                fileTypes = definitions.fileTypes;
                for i = 1:length(fileTypes)
                    currentFiles = dir([dicoms currentFolder '/' fileTypes{i}]);
                    allFiles = [allFiles; {currentFiles.name}];
                end   
                testFile = char(allFiles(1));
                info = dicominfo([dicoms currentFolder '/' testFile]);
                newName = info.SeriesDescription;
                movefile([dicoms currentFolder], [dicoms newName]);
                
            end                
%         extract subsequence in string
%         check with dicominfo the .SeriesDescription field
%         add to nifi file name the mp2rage type
         end
    end
end

memoryUsage = memtoc;
computationTime = toc;

end %end function
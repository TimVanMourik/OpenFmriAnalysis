function tvm_objToBoundary(configuration)
% TVM_OBJTOBOUNDARY
%   TVM_OBJTOBOUNDARY(configuration)
%   @todo Add description
%
%   Copyright (C) Tim van Mourik, 2015-2016, DCCN
%
% Input:
%   i_SubjectDirectory
%   i_ObjFile
% Output:
%   o_BoundaryFile

%% Parse configuration
subjectDirectory        = tvm_getOption(configuration, 'i_SubjectDirectory', pwd());
    % default: current working directory
objectFile              = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_ObjFile'));
    %no default
boundaryFile            = fullfile(subjectDirectory, tvm_getOption(configuration, 'o_BoundaryFile'));
    %no default
    
% definitions = tvm_definitions();

%%
numberOfFiles = length(objectFile);
vertices = cell(numberOfFiles, 1);
faceData = cell(numberOfFiles, 1);
for i = 1:numberOfFiles
    [vertices{i}, faceData{i}] = tvm_importObjFile(objectFile{i});
end
save(boundaryFile, 'vertices', 'faceData');

end %end function


function tvm_objToBoundary(configuration)
% TVM_OBJTOBOUNDARY 
%   TVM_OBJTOBOUNDARY(configuration)
%   
%
%   Copyright (C) Tim van Mourik, 2015, DCCN
%
%   configuration.SubjectDirectory
%

%% Parse configuration
subjectDirectory =      tvm_getOption(configuration, 'i_SubjectDirectory', pwd());
    %no default
objectFile              = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_ObjFile'));
    %no default
boundaryFile                 = fullfile(subjectDirectory, tvm_getOption(configuration, 'o_BoundaryFile'));
    %no default
    
definitions = tvm_definitions();

%%
[vertices, faces] = tvm_importObjFile(objFiles);

save(boundaryFile, 'vertices', 'faces');



end %end function


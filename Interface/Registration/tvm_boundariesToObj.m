function tvm_boundariesToObj(configuration)
% TVM_BOUNDARIESTOOBJ
%   TVM_BOUNDARIESTOOBJ(configuration)
%   @todo Add description
%   
%
%   Copyright (C) Tim van Mourik, 2014, DCCN
%
% Input:
%   i_SubjectDirectory
%   i_Boundaries
% Output:
%   o_ObjWhite
%   o_ObjPial
%

%% Parse configuration
subjectDirectory =      tvm_getOption(configuration, 'i_SubjectDirectory', pwd());
    % default: current working directory
boundariesFile =        fullfile(subjectDirectory, tvm_getOption(configuration, 'i_Boundaries'));
    %no default
objWhite =              fullfile(subjectDirectory, tvm_getOption(configuration, 'o_ObjWhite'));
    %no default
objPial =               fullfile(subjectDirectory, tvm_getOption(configuration, 'o_ObjPial'));
    %no default

definitions = tvm_definitions();
%%
load(boundariesFile, definitions.WhiteMatterSurface, definitions.PialSurface, definitions.FaceData);
wSurface = eval(definitions.WhiteMatterSurface);
pSurface = eval(definitions.PialSurface);
faceData = eval(definitions.FaceData);

for hemisphere = 1:2

    if hemisphere == 1
        % 1 = right
        outputFileWhite = strrep(objWhite, '?', 'r');
        outputFilePial = strrep(objPial, '?', 'r');
    elseif hemisphere == 2
        % 2 = left
        outputFileWhite = strrep(objWhite, '?', 'l');
        outputFilePial = strrep(objPial, '?', 'l');
    end

%   vertex - 1, because obj as a file format has default origin at 0 
    tvm_exportObjFile(wSurface{hemisphere} - 1, faceData{hemisphere}, outputFileWhite); 
    tvm_exportObjFile(pSurface{hemisphere} - 1, faceData{hemisphere}, outputFilePial);  
    
end  

end %end function











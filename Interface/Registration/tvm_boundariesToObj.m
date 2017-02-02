function tvm_boundariesToObj(configuration)
% TVM_BOUNDARIESTOOBJ
%   TVM_BOUNDARIESTOOBJ(configuration)
%   @todo Add description
%
% Input:
%   i_SubjectDirectory
%   i_Boundaries
% Output:
%   o_ObjWhite
%   o_ObjPial
%

%   Copyright (C) Tim van Mourik, 2014, DCCN
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











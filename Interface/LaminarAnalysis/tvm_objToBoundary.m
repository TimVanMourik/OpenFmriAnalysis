function tvm_objToBoundary(configuration)
% TVM_OBJTOBOUNDARY
%   TVM_OBJTOBOUNDARY(configuration)
%   @todo Add description
%
% Input:
%   i_SubjectDirectory
%   i_ObjFile
% Output:
%   o_BoundaryFile
%

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


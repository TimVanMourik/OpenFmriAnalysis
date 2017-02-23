function tvm_recursiveBoundaryRegistration(configuration, registrationConfiguration)
% TVM_RECURSIVEBOUNDARYREGISTRATION
%   TVM_RECURSIVEBOUNDARYREGISTRATION(configuration)
%   @todo Add description
%
% Input:
%   i_SubjectDirectory
%   i_ReferenceVolume
%   i_Boundaries
%   i_Mask
% Output:
%   o_Boundaries
%

%   Copyright (C) Tim van Mourik, 2014-2016, DCCN
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
referenceFile =             fullfile(subjectDirectory, tvm_getOption(configuration, 'i_ReferenceVolume'));
    %no default
boundariesFile =            fullfile(subjectDirectory, tvm_getOption(configuration, 'i_Boundaries'));
    %no default
maskFile =                  tvm_getOption(configuration, 'i_Mask', '');
    % default: empty
registeredBoundaries =   	fullfile(subjectDirectory, tvm_getOption(configuration, 'o_Boundaries'));
    %no default
    
definitions = tvm_definitions();
%%
tic();
referenceVolume = spm_read_vols(spm_vol(referenceFile));
load(boundariesFile, definitions.WhiteMatterSurface, definitions.PialSurface, definitions.FaceData);
% wSurface = eval(definitions.WhiteMatterSurface);
% pSurface = eval(definitions.PialSurface);
% faceData = eval(definitions.FaceData);

if isempty(maskFile)
    mask = true(size(referenceVolume));
else
    maskFile = fullfile(subjectDirectory, maskFile);
    mask = ~~spm_read_vols(spm_vol(maskFile));
end

transformStack = cell(size(wSurface)); 
for hemisphere = 1:2
    [~, selectedVerticesW] = selectVertices(wSurface{hemisphere}, mask);
    [~, selectedVerticesP] = selectVertices(pSurface{hemisphere}, mask);
%     selectedVertices = intersect(selectedVerticesW, selectedVerticesP);
    selectedVertices = selectedVerticesW & selectedVerticesP;

    [wSurface{hemisphere}(selectedVertices, :), pSurface{hemisphere}(selectedVertices, :), transformStack{hemisphere}] = tvm_wrapperRecursiveRegistration(wSurface{hemisphere}(selectedVertices, :), pSurface{hemisphere}(selectedVertices, :), referenceVolume, registrationConfiguration);  
end

% eval(tvm_changeVariableNames(definitions.WhiteMatterSurface, wSurface));
% eval(tvm_changeVariableNames(definitions.PialSurface, pSurface));
% eval(tvm_changeVariableNames(definitions.FaceData, faceData));
% eval(tvm_changeVariableNames(definitions.TransformStack, transformStack));

computationTime = [];
computationTime.RecursiveRegistration = toc();
save(registeredBoundaries, definitions.WhiteMatterSurface, definitions.PialSurface, definitions.FaceData, definitions.TransformStack, 'computationTime');

end %end function




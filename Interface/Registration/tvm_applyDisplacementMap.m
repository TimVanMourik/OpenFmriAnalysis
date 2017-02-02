function tvm_applyDisplacementMap(configuration)
% TVM_APPLYDISPLACEMENTMAP
%   TVM_APPLYDISPLACEMENTMAP(configuration)
%   @todo Add description
%
% Input:
%   i_SubjectDirectory
%   i_DisplacementMap
%   i_Boundaries
% Output:
%   o_Boundaries
%

%   Copyright (C) Tim van Mourik, 2015, DCCN
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
subjectDirectory =      	tvm_getOption(configuration, 'i_SubjectDirectory');
    % default: current working directory
displacementMapFile =       fullfile(subjectDirectory, tvm_getOption(configuration, 'i_DisplacementMap'));
    %no default
boundariesFileIn =          fullfile(subjectDirectory, tvm_getOption(configuration, 'i_Boundaries'));
    %no default
boundariesFileOut =         fullfile(subjectDirectory, tvm_getOption(configuration, 'o_Boundaries'));
    %no default
    
definitions = tvm_definitions();
%%
load(boundariesFileIn, definitions.WhiteMatterSurface, definitions.PialSurface, definitions.FaceData);
% wSurface = eval(definitions.WhiteMatterSurface);
% pSurface = eval(definitions.PialSurface);
% faceData = eval(definitions.FaceData);

fieldMap = spm_read_vols(spm_vol(displacementMapFile));

%%
configuration.InterpolationMethod = 'Trilinear';
wTemp = cell(size(wSurface));
pTemp = cell(size(pSurface));
for hemisphere = 1:length(wSurface)
    for i = 1:3
        %todo, what to do with Nans?
        wTemp{hemisphere}(:, i) = wSurface{hemisphere}(:, i) + tvm_sampleVoxels(fieldMap(:, :, :, i), wSurface{hemisphere}(:, 1:3), configuration);
        pTemp{hemisphere}(:, i) = pSurface{hemisphere}(:, i) + tvm_sampleVoxels(fieldMap(:, :, :, i), pSurface{hemisphere}(:, 1:3), configuration);
    end
end

% add a column of to save as 4D 
for hemisphere = 1:length(wSurface)
    wTemp{hemisphere} = [wTemp{hemisphere}, ones(size(wTemp{hemisphere},1), 1)];
    pTemp{hemisphere} = [pTemp{hemisphere}, ones(size(pTemp{hemisphere},1), 1)];
end

wSurface = wTemp;
pSurface = pTemp;

% eval(tvm_changeVariableNames(definitions.WhiteMatterSurface, wSurface));
% eval(tvm_changeVariableNames(definitions.PialSurface, pSurface));
% eval(tvm_changeVariableNames(definitions.FaceData, faceData));
save(boundariesFileOut, definitions.WhiteMatterSurface, definitions.PialSurface, definitions.FaceData);

end %end function


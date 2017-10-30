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
multipleLoops         	= tvm_getOption(registrationConfiguration, 'MultipleLoops',     false);
    % false
useQsub                 = tvm_getOption(registrationConfiguration, 'qsub',              false);
    % false
timeRequirement         = tvm_getOption(registrationConfiguration, 'TimeRequirement',   1200);
    % 800
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
    
    if size(wSurface{hemisphere}, 2) == 3
        wSurface{hemisphere} = [wSurface{hemisphere}, ones(size(wSurface{hemisphere}, 1), 1)];
        pSurface{hemisphere} = [pSurface{hemisphere}, ones(size(pSurface{hemisphere}, 1), 1)];
    end

    if multipleLoops
        dimensions = {...
            [1, 2, 3]; ...
            [1, 3, 2]; ...
            [2, 1, 3]; ...
            [2, 3, 1]; ...
            [3, 1, 2]; ...
            [3, 2, 1]};
    else
        dimensions = {[1, 2, 3]};
    end
    %memory copies of the data. One for each node on the cluster.
    whiteMatterBoundary = cell(length(dimensions), 1);
    pialBoundary        = cell(length(dimensions), 1);
    volumeData          = cell(length(dimensions), 1);
    cfg                 = cell(length(dimensions), 1);

    whiteMatterBoundary(:)  = wSurface(hemisphere);
    pialBoundary(:)         = pSurface(hemisphere);
    volumeData(:)           = {referenceVolume};
    cfg(:)                  = {registrationConfiguration};

    if useQsub
        memoryRequirement = length(dimensions) * (numel(wSurface{hemisphere}) + numel(pSurface{hemisphere}) + numel(referenceVolume)) * 8 * 2;
        %timeRequirement = ?; @TODO: make a nice estimation function
        [w, p, transformStack] = qsubcellfun(@tvm_recursiveRegistration, whiteMatterBoundary, pialBoundary, volumeData, dimensions, cfg, 'UniformOutput', false, 'memreq', memoryRequirement, 'timreq', timeRequirement);
    else
        [w, p, transformStack] =     cellfun(@tvm_recursiveRegistration, whiteMatterBoundary, pialBoundary, volumeData, dimensions, cfg, 'UniformOutput', false);
    end
    w = reshape([w{:}], [size(wSurface{hemisphere}, 1), size(wSurface{hemisphere}, 2), length(dimensions)]);
    p = reshape([p{:}], [size(pSurface{hemisphere}, 1), size(pSurface{hemisphere}, 2), length(dimensions)]);
    
    wSurface{hemisphere}(selectedVertices, :) = median(w, 3);
    pSurface{hemisphere}(selectedVertices, :) = median(p, 3);
    transformStack{hemisphere} = transformStack;
end

% eval(tvm_changeVariableNames(definitions.WhiteMatterSurface, wSurface));
% eval(tvm_changeVariableNames(definitions.PialSurface, pSurface));
% eval(tvm_changeVariableNames(definitions.FaceData, faceData));
% eval(tvm_changeVariableNames(definitions.TransformStack, transformStack));

computationTime = [];
computationTime.RecursiveRegistration = toc();
save(registeredBoundaries, definitions.WhiteMatterSurface, definitions.PialSurface, definitions.FaceData, definitions.TransformStack, 'computationTime');

end %end function




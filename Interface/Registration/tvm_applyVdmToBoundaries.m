function tvm_applyVdmToBoundaries(configuration)
% TVM_APPLYVDMTOBOUNDARIES
%   TVM_APPLYVDMTOBOUNDARIES(configuration)
%   @todo Add description
%
% Input:
%   i_SubjectDirectory
%   i_Boundaries
%   i_VoxelDisplacementMap
%   i_TransformationFunction
%   i_DistortionDimenions
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
subjectDirectory        = tvm_getOption(configuration, 'i_SubjectDirectory', pwd());
    % default: current working directory
boundariesFiles         = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_Boundaries'));
    %no default
voxelDisplacementFile   = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_VoxelDisplacementMap'));
    %no default
transformation          = tvm_getOption(configuration, 'i_TransformationFunction', @(x)x);
    % 
distortionDimension     = tvm_getOption(configuration, 'i_DistortionDimension');
    %no default
boundariesFilesOutput   = fullfile(subjectDirectory, tvm_getOption(configuration, 'o_Boundaries'));
    %no default
    
%%
voxelDisplacement           = spm_vol(voxelDisplacementFile);
voxelDisplacement.volume    = spm_read_vols(voxelDisplacement);
load(boundariesFiles, 'wSurface', 'pSurface', 'faceData');

displacement = cell(size(wSurface));
for i = 1:length(wSurface)
    volumeSize = voxelDisplacement.dim;
    integerParts = floor(wSurface{i}(:, 1:3));
    insideVolume = ~any(integerParts < 1 | bsxfun(@gt, integerParts, volumeSize(1:3) - 1) | isnan(integerParts), 2);
    displacement{i} = zeros(size(wSurface{i}));
    displacement{i}(~insideVolume, :) = NaN;
    shift = cumsum(~insideVolume);
    wSurface{i} = wSurface{i}(insideVolume, :);
    pSurface{i} = pSurface{i}(insideVolume, :);
    displacement{i}(insideVolume, distortionDimension) = tvm_sampleVoxels(transformation(voxelDisplacement.volume), wSurface{i}(:, 1:3));
    map = [1:length(shift)]';
    wSurface{i} = wSurface{i} + displacement{i}(insideVolume, :);
    pSurface{i} = pSurface{i} + displacement{i}(insideVolume, :);
    faceData{i} = faceData{i}(all(ismember(faceData{i}, find(insideVolume)), 2), :);
    [~, index] = ismember(faceData{i}, map); 
    map = map - shift;
    faceData{i} = map(index);
end
save(boundariesFilesOutput, 'wSurface', 'pSurface', 'faceData', 'displacement');

end %end function










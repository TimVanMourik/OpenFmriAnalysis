function tvm_volumetricLayering(configuration)
% TVM_VOLUMETRICLAYERING
%   TVM_VOLUMETRICLAYERING(configuration)
%   @todo Add description
%
% Input:
%   i_SubjectDirectory
%   i_White
%   i_Pial
%   i_Gradient
%   i_Curvature
%   i_Levels
%   i_UpsampleFactor
% Output:
%   o_Layering
%   o_LevelSet
%

%   Copyright (C) Tim van Mourik, 2014-2017, DCCN
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
subjectDirectory    = tvm_getOption(configuration, 'i_SubjectDirectory', pwd());
    % default: current working directory
white               = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_White'));
    %no default
pial                = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_Pial'));
    %no default
gradientFile        = tvm_getOption(configuration, 'i_Gradient', '');
    %default: empty
curvatureFile       = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_Curvature'));
    %no default
levels              = tvm_getOption(configuration, 'i_Levels');
    %
upsampleFactor     	= tvm_getOption(configuration, 'i_UpsampleFactor', 1);
    %default: unity scaling
layerFile           = fullfile(subjectDirectory, tvm_getOption(configuration, 'o_Layering'));
    %no default
levelSetFile        = tvm_getOption(configuration, 'o_LevelSet', '');
    %default: empty

%%
sdfIn   = spm_vol(white);
sdfOut  = spm_vol(pial);

sdfIn.volume    = spm_read_vols(sdfIn);
sdfOut.volume   = spm_read_vols(sdfOut);

curvature = spm_vol(curvatureFile);
curvature.volume = spm_read_vols(curvature);

numberOfLaminae = length(levels);

%%
curvature.volume(isnan(curvature.volume)) = 0;
levelSet = -reshape(squeeze(tvm_getBokCoordinates(sdfIn.volume(:), sdfOut.volume(:), curvature.volume(:) / nthroot(abs(det(curvature.mat)), 3) / 2, levels, sign(sdfOut.volume(:) - sdfIn.volume(:)), sdfIn.volume(:) - sdfOut.volume(:))), [curvature.dim, numberOfLaminae]);

%%
oldMatrix = curvature.mat;
oldDimensions = curvature.dim;
[newMatrix, newDimensions] = tvm_getResampledMatrix(oldMatrix, oldDimensions, upsampleFactor);
curvature.dim = newDimensions;
curvature.mat = newMatrix;

%%
% curvature.mat = newMatrix;
if ~isempty(levelSetFile)
    if upsampleFactor ~= 1

        downsampledVolume = zeros([curvature.dim, numberOfLaminae]);
        for x = 1:upsampleFactor
            for y = 1:upsampleFactor
                for z = 1:upsampleFactor
                    downsampledVolume = downsampledVolume + levelSet(x:upsampleFactor:end, y:upsampleFactor:end, z:upsampleFactor:end, :);
                end
            end
        end
        downsampledVolume = downsampledVolume / upsampleFactor ^ 3;    
    else
        downsampledVolume = levelSet;
    end
    tvm_write4D(curvature, downsampledVolume, fullfile(subjectDirectory, levelSetFile));
end

%%
laminae = curvature;
if ~isempty(gradientFile)
    gradient = spm_read_vols(spm_vol(fullfile(subjectDirectory, gradientFile)));
    laminae.volume = tvm_partialVolumeArea(levelSet / nthroot(abs(det(oldMatrix)), 3), 'gradient', gradient);      
else
    laminae.volume = tvm_partialVolumeArea(levelSet / nthroot(abs(det(oldMatrix)), 3), 'cubic');
end
for lamina = numberOfLaminae:-1:2
    laminae.volume(:, :, :, lamina) = laminae.volume(:, :, :, lamina) - laminae.volume(:, :, :, lamina - 1);
end
laminae.volume = cat(4, laminae.volume, 1 - sum(laminae.volume, 4));

% set all edges to zero: the curvature is not defined at the edges and
% hence the layer distribution is undefined.
laminae.volume(1,   :,   :,   :) = 0;
laminae.volume(:,   1,   :,   :) = 0;
laminae.volume(:,   :,   1,   :) = 0;
laminae.volume(end, :,   :,   :) = 0;
laminae.volume(:,   end, :,   :) = 0;
laminae.volume(:,   :,   end, :) = 0;

if upsampleFactor ~= 1
    downsampledVolume = zeros([laminae.dim, numberOfLaminae + 1]);
    for x = 1:upsampleFactor
        for y = 1:upsampleFactor
            for z = 1:upsampleFactor
                downsampledVolume = downsampledVolume + laminae.volume(x:upsampleFactor:end, y:upsampleFactor:end, z:upsampleFactor:end, :);
            end
        end
    end
    laminae.volume = downsampledVolume / upsampleFactor ^ 3;    
end

tvm_write4D(laminae, laminae.volume, layerFile);

end %end function


























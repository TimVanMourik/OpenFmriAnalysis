function tvm_potentialToLayers(configuration)
% TVM_POTENTIALTOLAYERS
%   TVM_POTENTIALTOLAYERS(configuration)
%   @todo Add description
%
% Input:
%   i_SubjectDirectory
%   i_White
%   i_Pial
%   i_Potential
%   i_Levels
% Output:
%   o_Layering
%

%   Copyright (C) Tim van Mourik, 2016-2017, DCCN
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
potentialFile       = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_Potential'));
    %no default
levels              = tvm_getOption(configuration, 'i_Levels', 0:1/3:1);
    %0:1/3:1
layerFile           = fullfile(subjectDirectory, tvm_getOption(configuration, 'o_Layering'));
    %no default

%%
sdfIn   = spm_vol(white);
sdfOut  = spm_vol(pial);

sdfIn.volume    = spm_read_vols(sdfIn);
sdfOut.volume   = spm_read_vols(sdfOut);

potential = spm_vol(potentialFile);
potential.volume = spm_read_vols(potential);

%number of volume layers, so number of SDFs is one more
numberOfLaminae = length(levels);
rho = sdfIn;
rho.volume = zeros([rho.dim, numberOfLaminae]);

for lamina = 1:numberOfLaminae
    rhoValue = (lamina - 1) / (numberOfLaminae - 1);
    rho.volume(:, :, :, lamina) = (1 - rhoValue) .* sdfIn.volume + rhoValue .* sdfOut.volume;
end
tvm_write4D(rho, rho.volume, levelSetFile);


%%
laminae = rho;
% laminae.volume = tvm_partialVolumeAreaGradient(rho.volume, gradient);
laminae.volume = tvm_partialVolumeArea(rho.volume);

laminae.volume = cat(4, ones(rho.dim), laminae.volume);
cumulativeVolume = zeros(rho.dim);
for lamina = (numberOfLaminae + 1):-1:1
    laminae.volume(:, :, :, lamina) = laminae.volume(:, :, :, lamina) - cumulativeVolume;
    cumulativeVolume = cumulativeVolume + laminae.volume(:, :, :, lamina);
end

% set all edges to zero: the curvature is not defined at the edges and
% hence the layer distribution is undefined.
laminae.volume(1, :, :, :) = 0;
laminae.volume(:, 1, :, :) = 0;
laminae.volume(:, :, 1, :) = 0;
laminae.volume(end, :, :, :) = 0;
laminae.volume(:, end, :, :) = 0;
laminae.volume(:, :, end, :) = 0;
tvm_write4D(laminae, laminae.volume, layerFile);

end %end function


























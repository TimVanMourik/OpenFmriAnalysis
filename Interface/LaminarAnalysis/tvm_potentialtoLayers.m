function tvm_volumetricLayering(configuration)
% TVM_VOLUMETRICLAYERING 
%   TVM_VOLUMETRICLAYERING(configuration)
%   
%
%   Copyright (C) Tim van Mourik, 2014, DCCN
%
%   configuration.SubjectDirectory
%   configuration.White
%   configuration.Pial
%   configuration.WhiteCurvature
%   configuration.WhiteCurvature
%   configuration.Levels
%   configuration.LevelSet
%   configuration.Layers
%
%
% The levels will be the volume in between the numbers given in configuration.Levels

%% Parse configuration
subjectDirectory    = tvm_getOption(configuration, 'i_SubjectDirectory', pwd());
    %no default
white               = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_White'));
    %no default
pial                = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_Pial'));
    %no default
% whiteNormals        = tvm_getOption(configuration, 'i_WhiteNormals', '');
    %default: ''
    %when there is no curvature input, equidistant sampling will be used.
% pialNormals         = tvm_getOption(configuration, 'i_PialNormals', '');
    %default: ''
    %when there is no curvature input, equidistant sampling will be used.
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


























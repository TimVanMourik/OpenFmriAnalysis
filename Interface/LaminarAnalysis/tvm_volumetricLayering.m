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
subjectDirectory =      tvm_getOption(configuration, 'i_SubjectDirectory', pwd());
    %no default
white               = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_White'));
    %no default
pial                = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_Pial'));
    %no default
whiteK              = tvm_getOption(configuration, 'i_WhiteCurvature', '');
    %default: ''
    %when there is no curvature input, equidistant sampling will be used.
pialK               = tvm_getOption(configuration, 'i_PialCurvature', '');
    %default: ''
    %when there is no curvature input, equidistant sampling will be used.
whiteNormals        = tvm_getOption(configuration, 'i_WhiteNormals', '');
    %default: ''
    %when there is no curvature input, equidistant sampling will be used.
pialNormals         = tvm_getOption(configuration, 'i_PialNormals', '');
    %default: ''
    %when there is no curvature input, equidistant sampling will be used.
levels              = tvm_getOption(configuration, 'i_Levels', 0:1/3:1);
    %0:1/3:1
levelSetFile        = fullfile(subjectDirectory, tvm_getOption(configuration, 'o_LevelSet', 'LevelSets/brain.levels.nii'));
    %no default
layerFile           = fullfile(subjectDirectory, tvm_getOption(configuration, 'o_Layers', 'LevelSets/brain.layers.nii'));
    %no default

%%
curvature = false;
% if all of them are not empty
if all(~[isempty(whiteK), isempty(pialK)])
    whiteK             = fullfile(subjectDirectory, whiteK);
    pialK              = fullfile(subjectDirectory, pialK);

    curvature = true;
end

%%
sdfIn   = spm_vol(white);
sdfOut  = spm_vol(pial);

sdfIn.volume    = spm_read_vols(sdfIn);
sdfOut.volume   = spm_read_vols(sdfOut);

if curvature
    curvIn     = spm_vol(whiteK);
    curvOut    = spm_vol(pialK);

    curvIn.volume  = spm_read_vols(curvIn);
    curvOut.volume = spm_read_vols(curvOut);
    
    %%
    distance = sdfIn;
%     distance.fname = 'brain.distance.nii';
    distance.volume = abs(sdfIn.volume - sdfOut.volume);

    %%
    aIn = sdfIn;
%     aIn.fname = 'brain.ain.nii';
    aIn.volume = 4 / (2 + sign(curvIn.volume - curvOut.volume) .* distance.volume .* curvIn.volume);
    aIn.volume(aIn.volume < 0) = 0;
    aIn.volume(aIn.volume > 3) = 3;
    aIn.volume(isnan(aIn.volume)) = 0;

    %%
    aOut = sdfIn;
%     aOut.fname = 'brain.aout.nii';
    aOut.volume = 4 / (2 + sign(curvOut.volume - curvIn.volume) .* distance.volume .* curvOut.volume);
    aOut.volume(aOut.volume < 0) = 0;
    aOut.volume(aOut.volume > 3) = 3;
    aOut.volume(isnan(aOut.volume)) = 0;

    %%
    clear('curvIn', 'curvOut', 'distance');

    %%
    aDif = sdfIn;
%     aDif.fname = 'brain.adif.nii';
    aDif.volume = aOut.volume - aIn.volume;


    %%
    %number of volume layers, so number of SDFs is one more
    numberOfLaminae = length(levels);

    %%
    rho = sdfIn;
%     rho.fname = 'brain.layers.nii';
    rho.volume = zeros(rho.dim);

    for lamina = 1:numberOfLaminae
        rho.volume(:, :, :, lamina) = (sqrt(levels(lamina) * aOut.volume .^ 2 + (1 - levels(lamina)) * aIn.volume .^ 2) - aIn.volume) ./ aDif.volume;
    end
    rho.volume(isnan(rho.volume)) = 0;

    %%
    clear aIn aOut aDif lamina

    %%
    for lamina = 1:numberOfLaminae
        rho.volume(:, :, :, lamina) = (1 - rho.volume(:, :, :, lamina)) .* sdfIn.volume + rho.volume(:, :, :, lamina) .* sdfOut.volume;
    end
    tvm_write4D(rho, rho.volume, levelSetFile);

else
    %number of volume layers, so number of SDFs is one more
    numberOfLaminae = length(levels);
    rho = sdfIn;
%     rho.fname = 'brain.layers.nii';
    rho.volume = zeros([rho.dim, numberOfLaminae]);


    %%
    for lamina = 1:numberOfLaminae
        rhoValue = (lamina - 1) / (numberOfLaminae - 1);
        rho.volume(:, :, :, lamina) = (1 - rhoValue) .* sdfIn.volume + rhoValue .* sdfOut.volume;
    end
    tvm_write4D(rho, rho.volume, levelSetFile);
    
end
%%
clear sdfIn sdfOut

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


























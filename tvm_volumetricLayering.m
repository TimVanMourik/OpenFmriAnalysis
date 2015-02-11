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
%   configuration.WhiteCurvature1
%   configuration.WhiteCurvature2
%   configuration.PialCurvature1
%   configuration.PialCurvature2
%   configuration.Levels
%   configuration.LevelSet
%   configuration.Layers
%
%
% The levels will be the volume in between the numbers given in configuration.Levels

%% Parse configuration
subjectDirectory 	= tvm_getOption(configuration, 'SubjectDirectory');
    %no default
white               = fullfile(subjectDirectory, tvm_getOption(configuration, 'White'));
    %no default
pial                = fullfile(subjectDirectory, tvm_getOption(configuration, 'Pial'));
    %no default
whiteK1             = fullfile(subjectDirectory, tvm_getOption(configuration, 'WhiteCurvature1', ''));
    %default: ''
    %when there is no curvature input, equidistant sampling will be used.
whiteK2             = fullfile(subjectDirectory, tvm_getOption(configuration, 'WhiteCurvature2', ''));
    %default: ''
    %when there is no curvature input, equidistant sampling will be used.
pialK1              = fullfile(subjectDirectory, tvm_getOption(configuration, 'PialCurvature1', ''));
    %default: ''
    %when there is no curvature input, equidistant sampling will be used.
pialK2              = fullfile(subjectDirectory, tvm_getOption(configuration, 'PialCurvature2', ''));
    %default: ''
    %when there is no curvature input, equidistant sampling will be used.
levels              = tvm_getOption(configuration, 'Levels', 0:1/3:1);
    %0:1/3:1
levelSetFile        = fullfile(subjectDirectory, tvm_getOption(configuration, 'LevelSet', 'LevelSets/brain.levels.nii'));
    %no default
layerFile           = fullfile(subjectDirectory, tvm_getOption(configuration, 'Layers', 'LevelSets/brain.layers.nii'));
    %no default

%%
curvature = false;
% if all of them are not empty
if all(~[isempty(whiteK1), isempty(whiteK2), isempty(pialK1), isempty(pialK1)])
    curvature = true;
end

%%
sdfIn   = spm_vol(white);
sdfOut  = spm_vol(pial);

sdfIn.volume    = spm_read_vols(sdfIn);
sdfOut.volume   = spm_read_vols(sdfOut);

if curvature
    curv1In     = spm_vol(whiteK1);
    curv2In     = spm_vol(whiteK2);
    curv1Out    = spm_vol(pialK1);
    curv2Out    = spm_vol(pialK2);

    curv1In.volume  = spm_read_vols(curv1In);
    curv2In.volume  = spm_read_vols(curv2In);
    curv1Out.volume = spm_read_vols(curv1Out);
    curv2Out.volume = spm_read_vols(curv2Out);
    
    %%
    distance = sdfIn;
%     distance.fname = 'brain.distance.nii';
    distance.volume = abs(sdfIn.volume - sdfOut.volume);

    %%
    aIn = sdfIn;
%     aIn.fname = 'brain.ain.nii';
    aIn.volume = 4 / ((2 + sign(curv1In.volume - curv1Out.volume) .* distance.volume .* curv1In.volume) .* (2 + sign(curv2In.volume - curv2Out.volume) .* distance.volume .* curv2In.volume));
    aIn.volume(aIn.volume < 0) = 0;
    aIn.volume(aIn.volume > 3) = 3;
    aIn.volume(isnan(aIn.volume)) = 0;

    %%
    aOut = sdfIn;
%     aOut.fname = 'brain.aout.nii';
    aOut.volume = 4 / ((2 + sign(curv1Out.volume - curv1In.volume) .* distance.volume .* curv1Out.volume) .* (2 + sign(curv2Out.volume - curv2In.volume) .* distance.volume .* curv2Out.volume));
    aOut.volume(aOut.volume < 0) = 0;
    aOut.volume(aOut.volume > 3) = 3;
    aOut.volume(isnan(aOut.volume)) = 0;

    %%
    clear curv1In curv2In curv1Out curv2Out distance

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


























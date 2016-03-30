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
gradientFile        = tvm_getOption(configuration, 'i_Gradient', '');
    %default: ''
curvatureFile       = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_Curvature'));
    %no default
levels              = tvm_getOption(configuration, 'i_Levels');
    %
layerFile           = fullfile(subjectDirectory, tvm_getOption(configuration, 'o_Layering'));
    %no default
levelSetFile        = tvm_getOption(configuration, 'o_LevelSet', '');
    %no default

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
levelSet = -reshape(squeeze(tvm_getBokCoordinates(sdfIn.volume(:), sdfOut.volume(:), curvature.volume(:), levels, sign(sdfOut.volume(:) - sdfIn.volume(:)), sdfIn.volume(:) - sdfOut.volume(:))), [curvature.dim, numberOfLaminae]);
if ~isempty(levelSetFile)
    tvm_write4D(curvature, levelSet, fullfile(subjectDirectory, levelSetFile));
end

%%
laminae = curvature;
if ~isempty(gradientFile)
    gradient = spm_read_vols(spm_vol(fullfile(subjectDirectory, gradientFile)));
    laminae.volume = tvm_partialVolumeArea(levelSet, 'gradient', gradient);
else
    laminae.volume = tvm_partialVolumeArea(levelSet, 'cubic');
end
for lamina = numberOfLaminae:-1:2
    laminae.volume(:, :, :, lamina) = laminae.volume(:, :, :, lamina) - laminae.volume(:, :, :, lamina - 1);
end
laminae.volume = cat(4, laminae.volume, 1 - sum(laminae.volume, 4));

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


























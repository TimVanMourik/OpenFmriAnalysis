function output = tvm_volumetricLayering(configuration)
%
%
% The levels will be the volume in between the numbers given in configuration.Levels

memtic

subjectDirectory = configuration.SubjectDirectory;

sdfIn = spm_vol([subjectDirectory configuration.White]);
sdfOut = spm_vol([subjectDirectory configuration.Pial]);

curv1In = spm_vol([subjectDirectory configuration.WhiteCurvature1]);
curv2In = spm_vol([subjectDirectory configuration.WhiteCurvature2]);
curv1Out = spm_vol([subjectDirectory configuration.PialCurvature1]);
curv2Out = spm_vol([subjectDirectory configuration.PialCurvature2]);

sdfIn.volume    = spm_read_vols(sdfIn);
sdfOut.volume   = spm_read_vols(sdfOut);
curv1In.volume  = spm_read_vols(curv1In);
curv2In.volume  = spm_read_vols(curv2In);
curv1Out.volume = spm_read_vols(curv1Out);
curv2Out.volume = spm_read_vols(curv2Out);

%%
distance = sdfIn;
distance.fname = 'brain.distance.nii';
distance.volume = abs(sdfIn.volume - sdfOut.volume);

%%
aIn = sdfIn;
aIn.fname = 'brain.ain.nii';
aIn.volume = 4 / ((2 + sign(curv1In.volume - curv1Out.volume) .* distance.volume .* curv1In.volume) .* (2 + sign(curv2In.volume - curv2Out.volume) .* distance.volume .* curv2In.volume));
aIn.volume(aIn.volume < 0) = 0;
aIn.volume(aIn.volume > 3) = 3;
aIn.volume(isnan(aIn.volume)) = 0;

%%
aOut = sdfIn;
aOut.fname = 'brain.aout.nii';
aOut.volume = 4 / ((2 + sign(curv1Out.volume - curv1In.volume) .* distance.volume .* curv1Out.volume) .* (2 + sign(curv2Out.volume - curv2In.volume) .* distance.volume .* curv2Out.volume));
aOut.volume(aOut.volume < 0) = 0;
aOut.volume(aOut.volume > 3) = 3;
aOut.volume(isnan(aOut.volume)) = 0;

%%
clear curv1In curv2In curv1Out curv2Out distance

%%
aDif = sdfIn;
aDif.fname = 'brain.adif.nii';
aDif.volume = aOut.volume - aIn.volume;

%%
%number of volume layers, so number of SDFs is one more
alpha = configuration.Levels;
numberOfLaminae = length(alpha);

%%
rho = sdfIn;
rho.fname = 'brain.layers.nii';
rho.volume = zeros(rho.dim);

for lamina = 1:numberOfLaminae
    rho.volume(:, :, :, lamina) = (sqrt(alpha(lamina) * aOut.volume .^ 2 + (1 - alpha(lamina)) * aIn.volume .^ 2) - aIn.volume) ./ aDif.volume;
end
rho.volume(isnan(rho.volume)) = 0;

%%
clear aIn aOut aDif lamina

%%
for lamina = 1:numberOfLaminae
    rho.volume(:, :, :, lamina) = (1 - rho.volume(:, :, :, lamina)) .* sdfIn.volume + rho.volume(:, :, :, lamina) .* sdfOut.volume;
end
spmWrite4D(rho, rho.volume, [subjectDirectory configuration.LevelSet]);

%%
clear sdfIn sdfOut

%%
laminae = rho;
laminae.volume = partialVolumeArea(rho.volume);
laminae.volume = cat(4, ones(rho.dim), laminae.volume);
cumulativeVolume = zeros(rho.dim);
for lamina = (numberOfLaminae + 1):-1:1
    laminae.volume(:, :, :, lamina) = laminae.volume(:, :, :, lamina) - cumulativeVolume;
    cumulativeVolume = cumulativeVolume + laminae.volume(:, :, :, lamina);
end
spmWrite4D(laminae, laminae.volume, [subjectDirectory configuration.Layers]);

output = memtoc;

end %end function


























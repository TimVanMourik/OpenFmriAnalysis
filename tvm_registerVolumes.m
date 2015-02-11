function tvm_registerVolumes(configuration, registrationConfiguration)
% TVM_REGISTERVOLUMES 
%   TVM_REGISTERVOLUMES(configuration)
%   
%
%   Copyright (C) Tim van Mourik, 2014, DCCN
%
%   configuration.SubjectDirectory
%   configuration.FunctionalDirectory
%   configuration.SmoothingDirectory
%   configuration.SmoothingKernel

%% Parse configuration
subjectDirectory =      tvm_getOption(configuration, 'i_SubjectDirectory');
    %no default
coregistrationFile =    fullfile(subjectDirectory, tvm_getOption(configuration, 'io_CoregistrationMatrix'));
    %no default
referenceFile =         fullfile(subjectDirectory, tvm_getOption(configuration, 'i_ReferenceVolume'));
    %no default
freeSurferFolder =      fullfile(subjectDirectory, tvm_getOption(configuration, 'i_FreeSurferFolder', 'FreeSurfer'));
    %[subjectDirectory, 'FreeSurfer']
boundariesFile =        fullfile(subjectDirectory, tvm_getOption(configuration, 'o_Boundaries'));
    %no default
    
%%
surfaceFolder = fullfile(freeSurferFolder, 'surf');
u = [];
if ~exist(fullfile(surfaceFolder, 'rh.white.asc'), 'file')
    u = [u, 'mris_convert ' fullfile(surfaceFolder, 'rh.white') ' ' fullfile(surfaceFolder, 'rh.white.asc') ';'];
end
if ~exist(fullfile(surfaceFolder, 'rh.pial.asc'), 'file')
    u = [u, 'mris_convert ' fullfile(surfaceFolder, 'rh.pial') ' ' fullfile(surfaceFolder, 'rh.pial.asc') ';'];
end

if ~exist(fullfile(surfaceFolder, 'lh.white.asc'), 'file')
    u = [u, 'mris_convert ' fullfile(surfaceFolder, 'lh.white') ' ' fullfile(surfaceFolder, 'lh.white.asc') ';'];
end
if ~exist(fullfile(surfaceFolder, 'lh.pial.asc'), 'file')
    u = [u, 'mris_convert ' fullfile(surfaceFolder, 'lh.pial') ' ' fullfile(surfaceFolder, 'lh.pial.asc') ';'];
end


if ~isempty(u)
    unix(u);
end

if ~exist(fullfile(freeSurferFolder, 'mri', 'brain.nii'), 'file')
    unix(['mri_convert ' fullfile(freeSurferFolder, 'mri', 'brain.mgz') ' ' fullfile(freeSurferFolder, 'mri', 'brain.nii') ' ;']);
end

%Load the volume data
functionalScan          = spm_vol(referenceFile);
structuralScan          = spm_vol(fullfile(freeSurferFolder, 'mri/brain.nii'));
functionalScan.volume   = spm_read_vols(functionalScan);
structuralScan.volume   = spm_read_vols(structuralScan);

if exist(coregistrationFile, 'file')
    load(coregistrationFile, 'coregistrationMatrix', 'registrationParameters');
    if exist('registrationParameters', 'var')
        registrationConfiguration.params = registrationParameters(1:6); %#ok<NODEF>
    end
end

registrationParameters = spm_coreg(functionalScan, structuralScan, registrationConfiguration);
coregistrationMatrix = spm_matrix(registrationParameters);
registrationParameters = [registrationParameters, 0, 0, 0]; %#ok<NASGU>
save(coregistrationFile, 'coregistrationMatrix', 'registrationParameters');
clear coregistrationTransformation

% load boundaries
loadedBoundaryInformation = [];
loadedBoundaryInformation.SurfaceWhite = fullfile(freeSurferFolder, 'surf/?h.white.asc');
loadedBoundaryInformation.SurfacePial  = fullfile(freeSurferFolder, 'surf/?h.pial.asc');

surfaceData = tvm_loadFreeSurferAsciiFile(loadedBoundaryInformation);
wSurface = surfaceData.SurfaceWhite;
pSurface = surfaceData.SurfacePial;
faceData = surfaceData.Faces; %#ok<NASGU>

voxelDimensionsStructural = sqrt(sum(structuralScan.mat(:, 1:3) .^ 2));
freeSurferMatrix = tvm_dimensionsToFreesurferMatrix(voxelDimensionsStructural, structuralScan.dim);

%FreeSurfer conversion matrix to go to voxel space
%Convert to anatomical world space
%Coregister with the functional scan
%And bring to functional voxel space
%    t = inv(freeSurferMatrix)' * structuralScan.mat' * inv(coregistrationMatrix)' * inv(functionalScan.mat)';
%which is equivalent to:
t = coregistrationMatrix * functionalScan.mat \ structuralScan.mat / freeSurferMatrix;
t = t';
for hemisphere = 1:2
    wSurface{hemisphere} = [wSurface{hemisphere}, ones(size(wSurface{hemisphere}, 1), 1)];
    pSurface{hemisphere} = [pSurface{hemisphere}, ones(size(pSurface{hemisphere}, 1), 1)];
    wSurface{hemisphere} = wSurface{hemisphere} * t;
    pSurface{hemisphere} = pSurface{hemisphere} * t;
end
save(boundariesFile, 'wSurface', 'pSurface', 'faceData')

end %end function









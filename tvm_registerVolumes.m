function tvm_registerVolumes(configuration)
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
subjectDirectory =      tvm_getOption(configuration, 'SubjectDirectory');
    %no default
coregistrationFile =    fullfile(subjectDirectory, tvm_getOption(configuration, 'CoregistrationMatrix'));
    %no default
referenceFile =         fullfile(subjectDirectory, tvm_getOption(configuration, 'ReferenceVolume'));
    %no default
freeSurferFolder =      fullfile(subjectDirectory, tvm_getOption(configuration, 'FreeSurferFolder', 'FreeSurfer'));
    %[subjectDirectory, 'FreeSurfer']
boundariesFile =        fullfile(subjectDirectory, tvm_getOption(configuration, 'Boundaries'));
    %no default
    
%%
cd(fullfile(freeSurferFolder, 'surf'));
u1 = 'mris_convert rh.white rh.white.asc;';
u2 = 'mris_convert rh.pial rh.pial.asc;';
u3 = 'mris_convert lh.white lh.white.asc;';
u4 = 'mris_convert lh.pial lh.pial.asc;';
u5 = 'mris_convert -v rh.white rh.neighbours.asc;';
u6 = 'mris_convert -v lh.white lh.neighbours.asc;';
unix([u1, u2, u3, u4, u5, u6]);
cd(fullfile(freeSurferFolder, 'mri'));
unix('mri_convert orig.mgz orig.nii;');
clear u1 u2 u3 u4 u5 u6

%Load the volume data
functionalScan          = spm_vol(referenceFile);
structuralScan          = spm_vol(fullfile(freeSurferFolder, 'mri/orig.nii'));
functionalScan.volume   = spm_read_vols(functionalScan);
structuralScan.volume   = spm_read_vols(structuralScan);

coregistrationTransformation = spm_coreg(functionalScan, structuralScan);
coregistrationMatrix = spm_matrix(coregistrationTransformation);
save(coregistrationFile, 'coregistrationMatrix', 'coregistrationTransformation')
clear coregistrationTransformation

% load boundaries
loadedBoundaryInformation = [];
loadedBoundaryInformation.SurfaceWhite = fullfile(freeSurferFolder, 'surf/?h.white.asc');
loadedBoundaryInformation.SurfacePial  = fullfile(freeSurferFolder, 'surf/?h.pial.asc');

[wSurface, pSurface] = tvm_loadFreeSurferAsciiFile(loadedBoundaryInformation);

freeSurferMatrix =     [-1,    0,  0,  128;
                        0,     0,  1,  -128;
                        0,     -1, 0,  128;
                        0,     0,  0,  1];

%FreeSurfer conversion matrix to go to voxel space
%Convert to anatomical world space
%Coregister with the functional scan
%And bring to functional voxel space
%    t = inv(freeSurferMatrix)' * Structural.mat' * inv(coregistrationMatrix)' * inv(meanFunctional.mat)';
%which is equivalent to:
t = coregistrationMatrix * functionalScan.mat \ structuralScan.mat / freeSurferMatrix;
t = t';
for hemisphere = 1:2
    wSurface{hemisphere} = [wSurface{hemisphere}, ones(size(wSurface{hemisphere}, 1), 1)];
    pSurface{hemisphere} = [pSurface{hemisphere}, ones(size(pSurface{hemisphere}, 1), 1)];
    wSurface{hemisphere} = wSurface{hemisphere} * t;
    pSurface{hemisphere} = pSurface{hemisphere} * t;
end
save(boundariesFile, 'wSurface', 'pSurface')

end %end function









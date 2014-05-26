function output = tvm_registerVolumes(configuration)

memtic
%Load the volume data
subjectDirectory = configuration.SubjectDirectory;
freesurferFolder = [subjectDirectory 'FreeSurfer/'];

cd([freesurferFolder 'surf']);
initialiseFreeSurfer = 'source ~/SetUpFreeSurfer.sh;';
u1 = 'mris_convert rh.white rh.white.asc;';
u2 = 'mris_convert rh.pial rh.pial.asc;';
u3 = 'mris_convert lh.white lh.white.asc;';
u4 = 'mris_convert lh.pial lh.pial.asc;';
u5 = 'mris_convert -v rh.white rh.neighbours.asc;';
u6 = 'mris_convert -v lh.white lh.neighbours.asc;';
unix([initialiseFreeSurfer u1, u2, u3, u4, u5, u6]);
cd([freesurferFolder 'mri']);
unix([initialiseFreeSurfer 'mri_convert orig.mgz orig.nii;']);
clear initialiseFreeSurfer u1 u2 u3 u4

functionalScan          = spm_vol([subjectDirectory 'Scans/Functional/MeanFunctional.nii']);
structuralScan          = spm_vol([freesurferFolder 'mri/orig.nii']);
functionalScan.volume   = spm_read_vols(functionalScan);

coregistrationTransformation = spm_coreg(functionalScan, structuralScan);
coregistrationMatrix = spm_matrix(coregistrationTransformation);
save([subjectDirectory configuration.CoregistrationMatrix], 'coregistrationMatrix', 'coregistrationTransformation')
clear coregistrationTransformation
%load([subjectDirectory configuration.CoregistrationMatrix], 'coregistrationMatrix')

% load boundaries
loadedBoundaryInformation = [];
loadedBoundaryInformation.SurfaceWhite = [freesurferFolder 'surf/?h.white.asc'];
loadedBoundaryInformation.SurfacePial  = [freesurferFolder 'surf/?h.pial.asc'];

[wSurface, pSurface] = loadFreeSurferAsciiFile(loadedBoundaryInformation);

structural = structuralScan;
structural.volume = spm_read_vols(structural);
meanFunctional = spm_vol([subjectDirectory 'Scans/Functional/MeanFunctional.nii']);
meanFunctional.volume = spm_read_vols(meanFunctional);

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
t = coregistrationMatrix * meanFunctional.mat \ structuralScan.mat / freeSurferMatrix;
t = t';
for hemisphere = 1:2
    wSurface{hemisphere} = [wSurface{hemisphere}, ones(size(wSurface{hemisphere}, 1), 1)];
    pSurface{hemisphere} = [pSurface{hemisphere}, ones(size(pSurface{hemisphere}, 1), 1)];
    wSurface{hemisphere} = wSurface{hemisphere} * t;
    pSurface{hemisphere} = pSurface{hemisphere} * t;
end
save([subjectDirectory configuration.Boundaries], 'wSurface', 'pSurface')

output = memtoc;

end %end function
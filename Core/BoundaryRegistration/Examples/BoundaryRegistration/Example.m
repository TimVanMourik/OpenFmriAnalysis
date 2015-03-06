showOutput = true;
saveOutput = false;
%% Move to the current directory
%This only works when the whole file is executed, not when just this block
%is executed
rootDirectory = mfilename('fullpath');
rootDirectory = rootDirectory(1:end - length(mfilename()));
cd([rootDirectory '/Functions']);
path(pwd, path);
cd(rootDirectory);
error
%% Convert FreeSurfer file to NifTI
%freeSurferVolume = 'Volumes/brain.mgz'; %or T1.mgz or orig.mgz
%unix(['mri_convert ' freeSurferVolume ' -ot nii Volumes/brain.nii;']);
%% Load the volume data
Functional          = spm_vol('Volumes/MeanFunctional.nii');
Structural          = spm_vol('Volumes/brain.nii');
Functional.volume   = spm_read_vols(Functional);
%%
coregstrationTransformation = spm_coreg(Functional, Structural);
coregistrationMatrix = spm_matrix(coregstrationTransformation);
%% Convert FreeSurfer boundaries to ascii files that are MATLAB readable
%setupFreeSurfer = 'source ~/SetUpFreeSurfer.sh;';
%convertlw = 'mris_convert Boundaries/lh.white Boundaries/lh.white.asc;';
%convertrw = 'mris_convert Boundaries/rh.white Boundaries/rh.white.asc;';
%convertlp = 'mris_convert Boundaries/lh.pial Boundaries/lh.pial.asc;';
%convertrp = 'mris_convert Boundaries/rh.pial Boundaries/rh.pial.asc;';
%unix([setupFreeSurfer convertlw convertrw convertlp convertrp]);
%clear convertlw convertrw convertlp convertrp
%% Load the boundaries that are found by Freesurfer and converted to ASCII
fileNames = [];
fileNames.SurfaceWhite  = 'Boundaries/?h.white.asc';
fileNames.SurfacePial   = 'Boundaries/?h.pial.asc';
[W, P] = loadFreeSurferAsciiFile(fileNames);
%% Makes coordinates homogeneous (i.e. add a column of 1s)
for hemisphere = 1:2
    W{hemisphere} = [W{hemisphere}, ones(size(W{hemisphere}, 1), 1)];
    P{hemisphere} = [P{hemisphere}, ones(size(P{hemisphere}, 1), 1)];
end
%% Convert FreeSurfer space to MATLAB space
freeSurferMatrix =     [-1,    0,  0,  128;
                        0,     0,  1,  -128;
                        0,     -1, 0,  128;
                        0,     0,  0,  1];

%FreeSurfer conversion matrix from vertex space to voxel space
%Convert to anatomical world space
%Coregister with the functional scan
%And bring to functional voxel space
t = inv(freeSurferMatrix)' * Structural.mat' * inv(coregistrationMatrix)' * inv(Functional.mat)';

for hemisphere = 1:2
    Functional.W{hemisphere} = W{hemisphere} * t;
    Functional.P{hemisphere} = P{hemisphere} * t;
end


%% Show and save a slice with the original boundaries
slicePercentage = 50;
if showOutput
    showSlice(Functional.volume,       round(slicePercentage / 100 * size(Functional.volume, 3)),     Functional.W,      Functional.P);
    if saveOutput
        saveas(gca, [rootDirectory 'Images/EPI_original.png']);
        saveas(gca, [rootDirectory 'Images/EPI_original.fig']);
    end
end

%% Boundary registration
for hemisphere = 1:2
    %clear the possibly existing configuration structure and set the
    %required fields
    bbrConfiguration = [];
    bbrConfiguration.ReverseContrast =     true;            %white matter darker than gray matter: true
    bbrConfiguration.ContrastMethod =      'gradient';      %sampling method
    bbrConfiguration.OptimisationMethod =  'GreveFischl';   %method for computing the contrast
    bbrConfiguration.Mode =                'rsyt';          %7 degrees of freedom: rx, ry, rz, sy, tx, ty, tz
    bbrConfiguration.MinVertices =         4000;            %Minimum vertices in one compartment 
    bbrConfiguration.MultipleLoops =       true;            %do the boundary registration 6 times and take the median result
    bbrConfiguration.Accuracy =            4;               %sampling density
    bbrConfiguration.DynamicAccuracy =     true;            %automatic sampling density
    bbrConfiguration.Display =             'on';            %display terminal output
    bbrConfiguration.BBR =                 true;            %start with a thorough initial Boundary Based Registration, such that the initial guess is optimal
    bbrConfiguration.TimeRequirement =     900;             %time requirement for the boundary registration

    tic;
    %The original MPRAGE boundary is transformed into the new EPI boundary
    %by registering to the the EPI volume
    [Functional.WNew{hemisphere}, Functional.PNew{hemisphere}] = boundaryRegistration(Functional.W{hemisphere}, Functional.P{hemisphere}, Functional.volume, bbrConfiguration);
    fprintf('The computation time for the boundary registration was %f seconds.\n',  toc);
end
W = Functional.WNew{hemisphere}; %#ok
P = Functional.PNew{hemisphere}; %#ok
cd(rootDirectory)
%save('Boundaries/Registered Boundaries.mat', 'W', 'P')
clear W P;
%% Show and save a slice with the new boundaries
if showOutput
    showSlice(Functional.volume, round(slicePercentage / 100 * size(Functional.volume, 3)), Functional.WNew, Functional.PNew);
    if saveOutput
        saveas(gca, [rootDirectory 'Images/EPI_registered.png'])
        saveas(gca, [rootDirectory 'Images/EPI_registered.fig'])
    end
end










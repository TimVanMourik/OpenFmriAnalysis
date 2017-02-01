function tvm_registerVolumes(configuration, registrationConfiguration)
% TVM_REGISTERVOLUMES
%   TVM_REGISTERVOLUMES(configuration)
%   @todo Add description
%   
%
%   Copyright (C) Tim van Mourik, 2014-2015, DCCN
%
% Input:
%   i_SubjectDirectory
%   i_ReferenceVolume
%   i_FreeSurferFolder
%   i_CoregistrationMatrix
% Output:
%   o_CoregistrationMatrix
%   o_Boundaries
%

%% Parse configuration
subjectDirectory =      tvm_getOption(configuration, 'i_SubjectDirectory', pwd());
    % default: current working directory
referenceFile =         fullfile(subjectDirectory, tvm_getOption(configuration, 'i_ReferenceVolume'));
    %no default
freeSurferFolder =      fullfile(subjectDirectory, tvm_getOption(configuration, 'i_FreeSurferFolder', 'FreeSurfer'));
    %[subjectDirectory, 'FreeSurfer']
coregistrationFileIn =  fullfile(subjectDirectory, tvm_getOption(configuration, 'i_CoregistrationMatrix', []));
    % default: empty
coregistrationFileOut = fullfile(subjectDirectory, tvm_getOption(configuration, 'o_CoregistrationMatrix'));
    %no default
boundariesFile =        fullfile(subjectDirectory, tvm_getOption(configuration, 'o_Boundaries'));
    %no default

if nargin < 2
    %register with default parameters
    registrationConfiguration = [];
end
    
definitions = tvm_definitions();
%%
surfaceFolder = fullfile(freeSurferFolder, 'surf');

convertToAscii(fullfile(surfaceFolder, 'rh.white'));
convertToAscii(fullfile(surfaceFolder, 'rh.pial'));
convertToAscii(fullfile(surfaceFolder, 'lh.white'));
convertToAscii(fullfile(surfaceFolder, 'lh.pial'));

if ~exist(fullfile(freeSurferFolder, 'mri', 'brain.nii'), 'file')
    unix(['mri_convert ' fullfile(freeSurferFolder, 'mri', 'brain.mgz') ' ' fullfile(freeSurferFolder, 'mri', 'brain.nii') ' ;']);
end

%Load the volume data
functionalScan          = spm_vol(referenceFile);
structuralScan          = spm_vol(fullfile(freeSurferFolder, 'mri/brain.nii'));
functionalScan.volume   = spm_read_vols(functionalScan);
structuralScan.volume   = spm_read_vols(structuralScan);

if exist(coregistrationFileIn, 'file') == 2
    load(coregistrationFileIn, 'coregistrationMatrix', 'registrationParameters');
    if exist('registrationParameters', 'var')
        registrationConfiguration.params = registrationParameters(1:6); %#ok<NODEF>
    end
end

registrationParameters = spm_coreg(functionalScan, structuralScan, registrationConfiguration);
coregistrationMatrix = spm_matrix(registrationParameters);
registrationParameters = [registrationParameters, 0, 0, 0]; %#ok<NASGU>
save(coregistrationFileOut, 'coregistrationMatrix', 'registrationParameters');
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

shiftByOne = [  1, 0, 0, 1; 
                0, 1, 0, 1; 
                0, 0, 1, 1; 
                0, 0, 0, 1];
shiftByHalf = [ 1, 0, 0, 0.5; 
                0, 1, 0, 0.5; 
                0, 0, 1, 0.5; 
                0, 0, 0, 1];
            
%FreeSurfer conversion matrix to go to voxel space
%Convert to anatomical world space
%Coregister with the functional scan
%And bring to functional voxel space
%    t = inv(freeSurferMatrix)' * shiftByOne * structuralScan.mat' * inv(coregistrationMatrix)' * inv(functionalScan.mat)' * inv(shiftByHalf);
%which is equivalent to:
t = inv(freeSurferMatrix)' * shiftByOne' * structuralScan.mat' * inv(coregistrationMatrix)' * inv(functionalScan.mat)' * inv(shiftByHalf)';
% t = t';
for hemisphere = 1:2
    wSurface{hemisphere} = wSurface{hemisphere} * t;
    pSurface{hemisphere} = pSurface{hemisphere} * t;
end
save(boundariesFile, 'wSurface', 'pSurface', 'faceData')

end %end function


function convertToAscii(fileName)
asciiFile = [fileName '.asc'];

if ~exist(asciiFile, 'file')
    unix(['mris_convert ' fileName ' ' asciiFile ';']);
end

end %end function






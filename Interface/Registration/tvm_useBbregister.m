function tvm_useBbregister(configuration)
% TVM_USEBBREGISTER(configuration)
%   TVM_USEBBREGISTER(configuration)
%   @todo Add description
%
% Input:
%   i_SubjectDirectory
%   i_RegistrationVolume
%   i_FreeSurferFolder
%   i_SpmInitialisation
%   i_FslInitialisation
%   i_Contrast
%   i_DegreesOfFreedom
%   i_InititialMatrix
% Output:
%   o_Boundaries
%   o_RegisterDat
%   o_CoregistrationMatrix
%

%   Copyright (C) Tim van Mourik, 2014, DCCN
%
% This file is part of the fmri analysis toolbox, see 
% https://github.com/TimVanMourik/FmriAnalysis for the documentation and 
% details.
%
%    This toolbox is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    This toolbox is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with the fmri analysis toolbox. If not, see 
%    <http://www.gnu.org/licenses/>.

%% Parse configuration
subjectDirectory        = tvm_getOption(configuration, 'i_SubjectDirectory', pwd());
    % default: current working directory
referenceFile           = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_RegistrationVolume'));
    %no default
freeSurferName          = tvm_getOption(configuration, 'i_FreeSurferFolder', 'FreeSurfer');
    %[subjectDirectory, 'FreeSurfer']
spmInitialisation       = tvm_getOption(configuration, 'i_SpmInitialisation', false);
    % default: false
fslInitialisation       = tvm_getOption(configuration, 'i_FslInitialisation', true);
    % default: true
contrast                = tvm_getOption(configuration, 'i_Contrast', 'T2');
    % default: T2 contrast
degreesOfFreedom    	= tvm_getOption(configuration, 'i_DegreesOfFreedom', 6);
    % default: 6 DoF, translation and rotation
initialisationMatrix    = tvm_getOption(configuration, 'i_InititialMatrix', '');
    % no default
additionalBBrFlags      = tvm_getOption(configuration, 'i_additionalBBrFlags', '');
    % default: empty
reslicedVolume          = tvm_getOption(configuration, 'o_ReslicedVolume', '');
    %no default
boundariesFile          = fullfile(subjectDirectory, tvm_getOption(configuration, 'o_Boundaries'));
    %no default
registerDatFile       	= fullfile(subjectDirectory, tvm_getOption(configuration, 'o_RegisterDat'));
    %no default
coregistrationFile      = fullfile(subjectDirectory, tvm_getOption(configuration, 'o_CoregistrationMatrix'));
    %no default
    
% definitions = tvm_definitions();

%%
freeSurferFolder = fullfile(subjectDirectory, freeSurferName);
if fslInitialisation
    fsl = ' --init-fsl';
else
    fsl = [];
end
if spmInitialisation %doesn't start matlab properly
    spm = ' --init-spm';
else
    spm = [];
end
switch contrast 
    case 'T1'
        contrastArgument = ' --t1';
    case {'T2', 'T2*'}
        contrastArgument = ' --t2';
end
switch degreesOfFreedom
    case 6
        dof = ' --6';
    case 9
        dof = ' --9';
    case 12
        dof = ' --12';
end
if isempty(initialisationMatrix)
    matrixInitialisation = '';
else
    matrixInitialisation = sprintf(' --init-reg %s', fullfile(subjectDirectory, initialisationMatrix));
end
if isempty(additionalBBrFlags)
    BBrFlags = '';
else
    BBrFlags = [' ' additionalBBrFlags ' '];
end
if isempty(reslicedVolume)
    resliceCommand = '';
else
    resliceCommand = [' --o ' , fullfile(subjectDirectory, reslicedVolume)];
end
[~, name, ~] = fileparts(freeSurferName);
unixCommand = ['SUBJECTS_DIR=', fullfile(freeSurferFolder, '..') ';'];
unixCommand = [unixCommand 'bbregister --s ' name ' --mov ' referenceFile ' --reg ' registerDatFile resliceCommand fsl spm contrastArgument dof matrixInitialisation BBrFlags ';'];
unix(unixCommand);

if ~exist(fullfile(freeSurferFolder, 'mri/brain.nii'), 'file')
    unix(['mri_convert ' fullfile(freeSurferFolder, 'mri/brain.mgz') ' ' fullfile(freeSurferFolder, 'mri/brain.nii') ' ;']);
end

surfaceFolder = fullfile(freeSurferFolder, 'surf');
convertToAscii(fullfile(surfaceFolder, 'rh.white'));
convertToAscii(fullfile(surfaceFolder, 'rh.pial'));
convertToAscii(fullfile(surfaceFolder, 'lh.white'));
convertToAscii(fullfile(surfaceFolder, 'lh.pial'));

%% Load the volume data
functionalScan          = spm_vol(referenceFile);
structuralScan          = spm_vol(fullfile(freeSurferFolder, 'mri/brain.nii'));
functionalScan.volume   = spm_read_vols(functionalScan);
structuralScan.volume   = spm_read_vols(structuralScan);

voxelDimensionsFunctional = sqrt(sum(functionalScan.mat(:, 1:3) .^ 2));
voxelDimensionsStructural = sqrt(sum(structuralScan.mat(:, 1:3) .^ 2));

% load boundaries
loadedBoundaryInformation = [];
loadedBoundaryInformation.SurfaceWhite = fullfile(freeSurferFolder, 'surf/?h.white.asc');
loadedBoundaryInformation.SurfacePial  = fullfile(freeSurferFolder, 'surf/?h.pial.asc');

surfaceData = tvm_loadFreeSurferAsciiFile(loadedBoundaryInformation);
wSurface = surfaceData.SurfaceWhite;
pSurface = surfaceData.SurfacePial;
faceData = surfaceData.Faces; %#ok<NASGU>

%%
freeSurferMatrixFunctional = tvm_dimensionsToFreesurferMatrix(voxelDimensionsFunctional, functionalScan.dim);
freeSurferMatrixStructural = tvm_dimensionsToFreesurferMatrix(voxelDimensionsStructural, structuralScan.dim);
                    
shiftByOne = [  1, 0, 0, 1; 
                0, 1, 0, 1; 
                0, 0, 1, 1; 
                0, 0, 0, 1];
shiftByHalf = [ 1, 0, 0, 0.5; 
                0, 1, 0, 0.5; 
                0, 0, 1, 0.5; 
                0, 0, 0, 1];
            
bbrCoregistrationMatrix = tvm_matrixFromRegisterDatFile(registerDatFile);            
transformation = bbrCoregistrationMatrix' * inv(freeSurferMatrixFunctional)' * shiftByHalf'; 
%world space to world space coregistration matrix
coregistrationMatrix = inv(functionalScan.mat)' * inv(shiftByOne)' * freeSurferMatrixFunctional' * inv(bbrCoregistrationMatrix)' * inv(freeSurferMatrixStructural') * shiftByOne' * structuralScan.mat'; %#ok<NASGU>
coregistrationMatrix = coregistrationMatrix';
% @todo shouldn't this be equal to directly:
% coregistrationMatrix =  structuralScan.mat * shiftByOne * inv(freeSurferMatrixStructural) * inv(bbrCoregistrationMatrix) * freeSurferMatrixFunctional * inv(shiftByOne) * inv(functionalScan.mat);


%%
for hemisphere = 1:2
    wSurface{hemisphere} = wSurface{hemisphere} * transformation;
    pSurface{hemisphere} = pSurface{hemisphere} * transformation;
end

%%
save(boundariesFile, 'wSurface', 'pSurface', 'faceData');
save(coregistrationFile, 'coregistrationMatrix');

end %end function

function convertToAscii(fileName)
asciiFile = [fileName '.asc'];

if ~exist(asciiFile, 'file')
    unix(['mris_convert ' fileName ' ' asciiFile ';']);
end

end %end function




function test %#ok<DEFNU>
%% reverse transformation
for hemisphere = 1:2
    wSurface{hemisphere} = wSurface{hemisphere} / t; %#ok<AGROW>
    pSurface{hemisphere} = pSurface{hemisphere} / t; %#ok<AGROW>
end
%%
slice = functionalScan.dim(1) / 2;
showSlice(functionalScan.volume,  slice, wSurface, pSurface, 'sagittal');
slice = functionalScan.dim(2) / 2;
showSlice(functionalScan.volume,  slice, wSurface, pSurface, 'coronal');
slice = functionalScan.dim(3) / 2;
showSlice(functionalScan.volume,  slice, wSurface, pSurface, 'horizontal');

%%
slice = structuralScan.dim(1) / 2;
showSlice(structuralScan.volume,  slice, wSurface, pSurface, 'sagittal');
slice = structuralScan.dim(2) / 2;
showSlice(structuralScan.volume,  slice, wSurface, pSurface, 'coronal');
slice = structuralScan.dim(3) / 2;
showSlice(structuralScan.volume,  slice, wSurface, pSurface, 'horizontal');
end

% freeSurferIdentityRegistration = inv(freeSurferMatrixStructural)' * shiftByOne' * structuralScan.mat' * inv(functionalScan.mat)' * inv(shiftByOne)' * freeSurferMatrixFunctional';
% perfect structural match:
% t = inv(freeSurferMatrixStructural)' * shiftByHalf';
% functional match without registration
% t = inv(freeSurferMatrixStructural)' * shiftByOne' * structuralScan.mat' * inv(functionalScan.mat)' * inv(shiftByOne)' * shiftByHalf'; 
% identical to the previous line
% t = freeSurferIdentityRegistration * inv(freeSurferMatrixFunctional)' * shiftByHalf'; 


% ?coregistrationMatrix = inv(functionalScan.mat) * inv(shiftByOne) * freeSurferMatrixFunctional * bbrCoregistrationMatrix * inv(freeSurferMatrixStructural) * shiftByOne * structuralScan.mat; %#ok<NASGU>
% ?coregistrationMatrix = inv(structuralScan.mat) * inv(shiftByOne) * freeSurferMatrixStructural * bbrCoregistrationMatrix * inv(freeSurferMatrixFunctional) * shiftByOne * functionalScan.mat; %#ok<NASGU>
% Cfs = bbrCoregistrationMatrix' * inv(freeSurferMatrixFunctional') * shiftByOne' * functionalScan.mat' * inv(structuralScan.mat)' * inv(shiftByOne)' * freeSurferMatrixStructural';
% coregistrationMatrix = inv(structuralScan.mat)' * inv(shiftByOne)' * freeSurferMatrixStructural' * bbrCoregistrationMatrix' * inv(freeSurferMatrixFunctional') * shiftByOne' * functionalScan.mat';
% coregistrationMatrix = inv(coregistrationMatrix);
% coregistrationMatrix = (freeSurferIdentityRegistration \ bbrCoregistrationMatrix')';
% t = inv(freeSurferMatrixStructural)' * inv(shiftByOne)' * inv(structuralScan.mat)' * functionalScan.mat' * shiftByOne' * inv(freeSurferMatrixFunctional)' * coregistrationMatrix' * freeSurferMatrixStructural';


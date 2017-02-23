function tvm_matrixToRegisterDat(configuration)
% TVM_MATRIXTOREGISTERDAT
%   TVM_MATRIXTOREGISTERDAT(configuration)
%   @todo Add description
%
% Input:
%   i_SubjectDirectory
%   i_ReferenceVolume
%   i_MoveVolume
%   i_CoregistrationMatrix
% Output:
%   o_RegisterDat
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
subjectDirectory =      tvm_getOption(configuration, 'i_SubjectDirectory', pwd());
    % default: current working directory
referenceFile =         fullfile(subjectDirectory, tvm_getOption(configuration, 'i_ReferenceVolume'));
    %no default
moveFile =              fullfile(subjectDirectory, tvm_getOption(configuration, 'i_MoveVolume'));
    %no default
coregistrationFile =    fullfile(subjectDirectory, tvm_getOption(configuration, 'i_CoregistrationMatrix'));
    %no default
registerDatFile =      	fullfile(subjectDirectory, tvm_getOption(configuration, 'o_RegisterDat'));
    %no default
    
% definitions = tvm_definitions();    

%%
load(coregistrationFile, 'coregistrationMatrix');
functionalScan = spm_vol(referenceFile);
structuralScan = spm_vol(moveFile);

voxelDimensionsFunctional = sqrt(sum(functionalScan.mat(:, 1:3) .^ 2));
voxelDimensionsStructural = sqrt(sum(structuralScan.mat(:, 1:3) .^ 2));

freeSurferMatrixFunctional = tvm_dimensionsToFreesurferMatrix(voxelDimensionsFunctional, functionalScan.dim);
freeSurferMatrixStructural = tvm_dimensionsToFreesurferMatrix(voxelDimensionsStructural, structuralScan.dim);
                    
shiftByOne = [  1, 0, 0, 1; 
                0, 1, 0, 1; 
                0, 0, 1, 1; 
                0, 0, 0, 1];            

bbrCoregistrationMatrix = inv(freeSurferMatrixFunctional)' * shiftByOne' * functionalScan.mat' * coregistrationMatrix' * inv(structuralScan.mat') * inv(shiftByOne') * freeSurferMatrixStructural'; %#ok<NASGU>
bbrCoregistrationMatrix = inv(bbrCoregistrationMatrix)';

weirdDimensions = [voxelDimensionsFunctional(1), voxelDimensionsFunctional(3), 0.15];
tvm_saveAsRegisterDat(registerDatFile, bbrCoregistrationMatrix', weirdDimensions, 'FreeSurfer');

end %end function




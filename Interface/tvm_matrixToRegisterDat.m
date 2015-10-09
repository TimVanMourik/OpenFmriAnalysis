function tvm_matrixToRegisterDat(configuration)
% TVM_MATRIXTOREGISTERDAT 
%   TVM_MATRIXTOREGISTERDAT(configuration)
%   
%
%   Copyright (C) Tim van Mourik, 2014, DCCN
%

%% Parse configuration
subjectDirectory =      tvm_getOption(configuration, 'i_SubjectDirectory', '.');
    %no default
referenceFile =         fullfile(subjectDirectory, tvm_getOption(configuration, 'i_ReferenceVolume'));
    %no default
moveFile =         fullfile(subjectDirectory, tvm_getOption(configuration, 'i_MoveVolume'));
    %no default
coregistrationFile =    fullfile(subjectDirectory, tvm_getOption(configuration, 'i_CoregistrationMatrix'));
    %no default
registerDatFile =      	fullfile(subjectDirectory, tvm_getOption(configuration, 'o_RegisterDat'));
    %no default
    
definitions = tvm_definitions();    

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




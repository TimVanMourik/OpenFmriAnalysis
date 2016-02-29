function tvm_boundariesToFreesurferFile(configuration)
% TVM_BOUNDARIESTOFREESURFERFILE 
%   TVM_BOUNDARIESTOFREESURFERFILE(configuration)
%   
%   Copyright (C) Tim van Mourik, 2015, DCCN
%
%   configuration.i_SubjectDirectory
%   configuration.i_Files
%   configuration.p_Suffix

%% Parse configuration
subjectDirectory =      	tvm_getOption(configuration, 'i_SubjectDirectory');
    %no default
boundaryFile =            	fullfile(subjectDirectory, tvm_getOption(configuration, 'i_Boundaries'));
    %no default
referenceFile =             fullfile(subjectDirectory, tvm_getOption(configuration, 'i_ReferenceVolume'));
    %no default
coregistrationFile =        fullfile(subjectDirectory, tvm_getOption(configuration, 'i_CoregistrationMatrix'));
    %no default
freeSurferName =            tvm_getOption(configuration, 'i_FreeSurferFolder');
    %no default
whiteFile =                	fullfile(subjectDirectory, tvm_getOption(configuration, 'o_WhiteMatterSurface'));
    %no default
pialFile =                 	fullfile(subjectDirectory, tvm_getOption(configuration, 'o_PialSurface'));
    %no default
 
%%
freeSurferFolder = fullfile(subjectDirectory, freeSurferName);
load(coregistrationFile, 'coregistrationMatrix');

structuralScan      = spm_vol(fullfile(freeSurferFolder, 'mri/brain.nii'));
functionalScan      = spm_vol(referenceFile);

% voxelDimensionsFunctional = sqrt(sum(functionalScan.mat(:, 1:3) .^ 2));
voxelDimensionsStructural = sqrt(sum(structuralScan.mat(:, 1:3) .^ 2));

% freeSurferMatrixFunctional = tvm_dimensionsToFreesurferMatrix(voxelDimensionsFunctional, functionalScan.dim);
freeSurferMatrixStructural = tvm_dimensionsToFreesurferMatrix(voxelDimensionsStructural, structuralScan.dim);
     
shiftByOne = [  1, 0, 0, 1; 
                0, 1, 0, 1; 
                0, 0, 1, 1; 
                0, 0, 0, 1];

% transformation = shiftByHalf' * functionalScan.mat' * coregistrationMatrix' * inv(structuralScan.mat)' * inv(shiftByOne)' * freeSurferMatrixStructural';
transformation = functionalScan.mat' * coregistrationMatrix' * inv(structuralScan.mat)' * inv(shiftByOne)' * freeSurferMatrixStructural';


load(boundaryFile, 'wSurface', 'pSurface', 'faceData');

for hemisphere = 1:2
    wSurface{hemisphere} = wSurface{hemisphere} * transformation;
    pSurface{hemisphere} = pSurface{hemisphere} * transformation;
end            

for hemisphere = 1:2
    switch hemisphere
        case 1
            prefix = 'r';
        case 2
            prefix = 'l';
    end
    
    fileName = strrep(whiteFile, '?', prefix);
    tvm_saveFreesurferAsciiFile(wSurface{hemisphere}, faceData{hemisphere}, [fileName '.asc']); %#ok<USENS>
    unix(['mris_convert ' fileName '.asc ' fileName]);
    unix(['rm ' fileName '.asc']);

    fileName = strrep(pialFile, '?', prefix);
    tvm_saveFreesurferAsciiFile(pSurface{hemisphere}, faceData{hemisphere}, [fileName '.asc']); 
    unix(['mris_convert ' fileName '.asc ' fileName]);
    unix(['rm ' fileName '.asc']);

end %end function





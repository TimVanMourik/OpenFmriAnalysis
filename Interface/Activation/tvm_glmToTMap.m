function tvm_glmToTMap(configuration)
% TVM_GLMTOTMAP
%   TVM_GLMTOTMAP(configuration)
%   @todo Add description
%   @todo Fix bug with degrees of freedom
%
%   Copyright (C) Tim van Mourik, 2016-2017, DCCN
%
% Input:
%   i_SubjectDirectory
%   i_DesignMatrix
%   i_Betas
%   i_ResidualSumOfSquares
%   i_Contrast
% Output:
%   o_TMap

%% Parse configuration
subjectDirectory =      tvm_getOption(configuration, 'i_SubjectDirectory', pwd());
    % default: current working directory
designFile =            fullfile(subjectDirectory, tvm_getOption(configuration, 'i_DesignMatrix'));
    %no default
glmFile =               fullfile(subjectDirectory, tvm_getOption(configuration, 'i_Betas'));
    %no default
resDevFile =            fullfile(subjectDirectory, tvm_getOption(configuration, 'i_ResidualSumOfSquares'));
    %no default
contrasts =              tvm_getOption(configuration, 'i_Contrast');
    %no default
tMapFiles =              fullfile(subjectDirectory, tvm_getOption(configuration, 'o_TMap'));
    %no default
    
definitions = tvm_definitions();

%%
load(designFile, definitions.GlmDesign);
design = eval(definitions.GlmDesign);

designMatrix = design.DesignMatrix;
% note that the actual covariance matrix is the inverse of this. But this allows us to use
% a matrix division later on, which is faster if you don't have to many contrasts 
covarianceMatrix = designMatrix' * designMatrix;
degreesOfFreedom = size(designMatrix, 1) - size(designMatrix, 2);

if ~iscell(tMapFiles)
    tMapFiles = {tMapFiles};
    contrasts = {contrasts};
end

betaValues = spm_vol(glmFile);
betaValues = spm_read_vols(betaValues);
residualSumOfSquares = spm_vol(resDevFile);
residualSumOfSquares.volume = spm_read_vols(residualSumOfSquares);
    
numberOfContrasts = length(contrasts);
for i = 1:numberOfContrasts
    currentContrast = tvm_getContrastVector(contrasts{i}, designMatrix, design.RegressorLabel);
    numberOfRegressors = length(currentContrast);
    tMap = zeros(residualSumOfSquares.dim);
    for j = 1:numberOfRegressors
        tMap = tMap + currentContrast(j) * betaValues(:, :, :, j);
    end
    
    squaredError = currentContrast / covarianceMatrix * currentContrast' * residualSumOfSquares.volume / degreesOfFreedom;
    standardError = sqrt(squaredError);
    tMap = tMap ./ standardError;
    tMap(standardError == 0) = 0;

    residualSumOfSquares.fname = tMapFiles{i};
    spm_write_vol(residualSumOfSquares, tMap);
end

end %end function






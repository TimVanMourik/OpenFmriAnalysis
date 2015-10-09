function tvm_glmToTMap(configuration)
% TVM_GLMTOTMAP
%   TVM_GLMTOTMAP(configuration)
%   
%
%   Copyright (C) Tim van Mourik, 2014, DCCN
%
%   configuration.SubjectDirectory
%   configuration.Design
%   configuration.GlmOutput
%   configuration.ResidualSumOfSquares
%   configuration.TMap
%   configuration.Contrast

%% Parse configuration
subjectDirectory =      tvm_getOption(configuration, 'i_SubjectDirectory');
    %no default
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
    if length(contrasts{i}) < size(designMatrix, 2)
        contrasts{i} =[contrasts{i}, zeros(1, size(designMatrix, 2) - length(contrasts{i}))];
    end

    numberOfRegressors = length(contrasts{i});

    squaredError = contrasts{i} / covarianceMatrix * contrasts{i}' * residualSumOfSquares.volume / degreesOfFreedom;
    tMap = zeros(residualSumOfSquares.dim);
    for j = 1:numberOfRegressors
        tMap = tMap + contrasts{i}(j) * betaValues(:, :, :, j);
    end
    standardError = sqrt(squaredError);
    tMap = tMap ./ standardError;
    tMap(standardError == 0) = 0;

    residualSumOfSquares.fname = tMapFiles{i};
    spm_write_vol(residualSumOfSquares, tMap);
end

end %end function








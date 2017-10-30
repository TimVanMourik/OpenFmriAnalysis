function tvm_glmToTMap(configuration)
% TVM_GLMTOTMAP
%   TVM_GLMTOTMAP(configuration)
%   @todo Add description
%   @todo Fix bug with degrees of freedom
%
% Input:
%   i_SubjectDirectory
%   i_DesignMatrix
%   i_Betas
%   i_ResidualSumOfSquares
%   i_Contrast
% Output:
%   o_TMap

%   Copyright (C) Tim van Mourik, 2016-2017, DCCN
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






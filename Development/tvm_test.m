function tvm_test(configuration)
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
subjectDirectory =      tvm_getOption(configuration, 'i_SubjectDirectory', pwd());
    %no default
temporalDesignFile =    fullfile(subjectDirectory, tvm_getOption(configuration, 'i_TemporalDesign'));
    %no default
glmFile =               fullfile(subjectDirectory, tvm_getOption(configuration, 'i_Betas'));
    %no default
resDevFile =            fullfile(subjectDirectory, tvm_getOption(configuration, 'i_ResidualSumOfSquares'));
    %no default
designFile =          	fullfile(subjectDirectory, tvm_getOption(configuration, 'i_SpatialDesign'));
    %no default
regressors =          	tvm_getOption(configuration, 'i_Regressors');
    %no default
output =             	fullfile(subjectDirectory, tvm_getOption(configuration, 'o_'));
    %no default
    
definitions = tvm_definitions();

%%
numberOfRegions = length(designFile);

load(temporalDesignFile, definitions.GlmDesign);
temporalDesign = eval(definitions.GlmDesign);

betaValues = spm_vol(glmFile);
dimensions = betaValues(1).dim;
betaValues = spm_read_vols(betaValues);
residualSumOfSquares = spm_vol(resDevFile);
residualSumOfSquares = spm_read_vols(residualSumOfSquares);

volumeData  = cell(numberOfRegions, 1);
d = cell(numberOfRegions, 1);
% load design matrices
for region = 1:numberOfRegions
    load(designFile{region}, definitions.GlmDesign);
    [x, y, z] = ind2sub(dimensions, design.Indices);
    d{region}.Design = design.DesignMatrix;
    d{region}.Locations = [x, y, z];
    d{region}.Betas = [];
    d{region}.RegressorLabels = regressors;
    for i = 1:length(regressors)
        currentContrast = tvm_getContrastVector({regressors{i}}, temporalDesign.DesignMatrix, temporalDesign.RegressorLabel);
        d{region}.Betas = [d{region}.Betas, betaValues(sub2ind(size(betaValues), x, y, z, repmat(find(currentContrast), size(x))))];
    end
    d{region}.RSS = residualSumOfSquares(design.Indices);
    save(output{region}, 'd');
end

end %end function






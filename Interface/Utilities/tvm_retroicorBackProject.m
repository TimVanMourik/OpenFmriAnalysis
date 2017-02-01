function tvm_retroicorBackProject(configuration)
% TVM_RETROICORBACKPROJECT
%   TVM_RETROICORBACKPROJECT(configuration)
%   @todo Add description
%   
%
%   Copyright (C) Tim van Mourik, 2016, DCCN
%
% Input:
%   i_SubjectDirectory
%   i_DesignMatrix
%   i_Betas
%   i_TemplateVolume
%   i_Resolution
%   i_Order
%   i_PhysioType
% Output:
%   o_BackProjection
%

%% Parse configuration
subjectDirectory =      tvm_getOption(configuration, 'i_SubjectDirectory', pwd());
    % default: current working directory
designFile =            fullfile(subjectDirectory, tvm_getOption(configuration, 'i_DesignMatrix'));
    %no default
glmFile =               fullfile(subjectDirectory, tvm_getOption(configuration, 'i_Betas'));
    %no default
template =              tvm_getOption(configuration, 'i_TemplateVolume', []);
    % default: empty
resolution =            tvm_getOption(configuration, 'i_Resolution');
    %no default
order =                 tvm_getOption(configuration, 'i_Order');
    %no default
physioType =            tvm_getOption(configuration, 'i_PhysioType');
    %no default
output =                fullfile(subjectDirectory, tvm_getOption(configuration, 'o_BackProjection'));
    %no default
    
definitions = tvm_definitions();

%%
load(designFile, definitions.GlmDesign);
design = eval(definitions.GlmDesign);

phase = linspace(0, 2 * pi, resolution);
oscillations = zeros(order * 2, resolution);
for i = 1:order
    oscillations(1 + (i - 1) * 2, :) =  sin(phase * i);
    oscillations(2 + (i - 1) * 2, :) =  cos(phase * i);
end

for i = 1:length(physioType)
    currentContrast = getContrastVector(physioType(i), design.DesignMatrix, design.RegressorLabel);
    betas = spm_vol(glmFile);
    betaValues = spm_read_vols(betas);
    betaValues = betaValues(:, :, :, ~~currentContrast);
    dimensions = size(betaValues);
    betaValues = reshape(betaValues, prod(dimensions(1:3)), dimensions(4));
    oscillations = repmat(oscillations, [dimensions(4) / size(oscillations, 1), 1]);

    betaValues = reshape(betaValues * oscillations, [dimensions(1:3), resolution]);

    if ~isempty(template)
        betaValues = bsxfun(@plus, betaValues, spm_read_vols(spm_vol(fullfile(subjectDirectory, template))));
    end
    tvm_write4D(betas(1), betaValues, output{i});
end

end %end function


function currentContrast = getContrastVector(contrast, designMatrix, regressorLabels)

if isnumeric(contrast) %1s, 0s and -1s
    if length(contrast) < size(designMatrix, 2)
        currentContrast =[contrast, zeros(1, size(designMatrix, 2) - length(contrast))];
    end
else %cell array with strings
    currentContrast = zeros(1, size(designMatrix, 2));
    for j = 1:length(contrast)
        if contrast{j}(1) == '-'
            contrast{j} = contrast{j}(2:end);
            sign = -1;
        else
            sign = 1;
        end
%         regressorsOfInterest = find(~cellfun(@isempty, strfind(design.RegressorLabel, contrast{j})));
        regressorsOfInterest = find(strcmp(regressorLabels, contrast{j}));
        currentContrast(regressorsOfInterest) = sign * 1;
        if isempty(regressorsOfInterest)
            warning('Regressors ''%s'' do not exist\n', contrast{j});
            continue;
        end
    end
end
end






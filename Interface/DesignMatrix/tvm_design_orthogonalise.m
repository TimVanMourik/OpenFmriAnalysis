function tvm_design_orthogonalise(configuration)
% TVM_DESIGN_ORTHOGONALISE
%   TVM_DESIGN_ORTHOGONALISE(configuration)
%   @todo Add description
%
%   Copyright (C) Tim van Mourik, 2015-2016, DCCN
%
% Input:
%   i_SubjectDirectory
%   i_DesignMatrix
%   i_Order
% Output:
%   o_DesignMatrix

%% Parse configuration
subjectDirectory        = tvm_getOption(configuration, 'i_SubjectDirectory', pwd());
    % default: current working directory
designFileIn            = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_DesignMatrix'));
    %no default
regressorsLabels        = tvm_getOption(configuration, 'i_Order');
    %no default
designFileOut           = fullfile(subjectDirectory, tvm_getOption(configuration, 'o_DesignMatrix'));
    %no default
    
definitions = tvm_definitions();

%%
load(designFileIn, definitions.GlmDesign);

regressorsOfInterest = cellfun(@strfind, repmat({design.RegressorLabel}, [1, length(regressorsLabels)]), regressorsLabels, 'UniformOutput', false);
regressorsOfInterest = mod(find(~cellfun(@isempty, [regressorsOfInterest{:}])), length(design.RegressorLabel));

design.DesignMatrix(:, regressorsOfInterest) = spm_orth(design.DesignMatrix(:, regressorsOfInterest));

save(designFileOut, definitions.GlmDesign);


end %end function
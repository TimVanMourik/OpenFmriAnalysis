function tvm_design_reorderRegressors(configuration)
% TVM_DESIGN_REORDERREGRESSORS
%   TVM_DESIGN_REORDERREGRESSORS(configuration)
%   Reorder the regressors. Everything that does not show up in 'i_Order'
%   will be pushed backward.
%   @todo Expand description
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
order                   = tvm_getOption(configuration, 'i_Order');
    %no default
designFileOut           = fullfile(subjectDirectory, tvm_getOption(configuration, 'o_DesignMatrix'));
    %no default
    
definitions = tvm_definitions();

%%
load(designFileIn, definitions.GlmDesign);

newDesignMatrix = [];
newRegressorLabels = {};
for type = order
    indices = strcmp(design.RegressorLabel, type);
    newDesignMatrix = [newDesignMatrix, design.DesignMatrix(:, indices)]; %#ok<AGROW>
    newRegressorLabels = [newRegressorLabels, design.RegressorLabel(:, indices)]; %#ok<AGROW>
    design.DesignMatrix(:, indices) = [];
    design.RegressorLabel(indices) = [];
end
newDesignMatrix = [newDesignMatrix, design.DesignMatrix];
newRegressorLabels = [newRegressorLabels, design.RegressorLabel];
design.DesignMatrix = newDesignMatrix;
design.RegressorLabel = newRegressorLabels;

% @todo add temporal derivatives?

save(designFileOut, definitions.GlmDesign);

end %end function
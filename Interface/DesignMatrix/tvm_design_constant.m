function tvm_design_constant(configuration)
% TVM_DESIGN_CONSTANT
%   TVM_DESIGN_CONSTANT(configuration)
%   @todo Add description
%
%   Copyright (C) Tim van Mourik, 2015-2016, DCCN
%
% Input:
%   i_SubjectDirectory
%   i_DesignMatrix
% Output:
%   o_DesignMatrix

%% Parse configuration
subjectDirectory        = tvm_getOption(configuration, 'i_SubjectDirectory', pwd());
    % default: current working directory
designFileIn            = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_DesignMatrix'));
    %no default
designFileOut           = fullfile(subjectDirectory, tvm_getOption(configuration, 'o_DesignMatrix'));
    %no default
    
definitions = tvm_definitions();

%%
load(designFileIn, definitions.GlmDesign);

designMatrix = zeros(design.Length, length(design.Partitions));
regressorLabels = cell(1, length(design.Partitions));
for column = 1:length(design.Partitions)
    designMatrix(design.Partitions{column}, column) = 1;
    regressorLabels{column} = 'Constant';
end
design.DesignMatrix = [design.DesignMatrix, designMatrix];
design.RegressorLabel = [design.RegressorLabel, regressorLabels];
save(designFileOut, definitions.GlmDesign);

end %end function
function tvm_design_addVector(configuration)
% TVM_DESIGN_ADDVECTOR
%   TVM_DESIGN_ADDVECTOR(configuration)
%   @todo Add description
%
%   Copyright (C) Tim van Mourik, 2016, DCCN
%
% Input:
%   i_SubjectDirectory
%   i_DesignMatrix
%   i_Vector
% Output:
%   o_DesignMatrix

%% Parse configuration
subjectDirectory        = tvm_getOption(configuration, 'i_SubjectDirectory', pwd());
    % default: current working directory
designFileIn            = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_DesignMatrix'));
    %no default
vector                  = tvm_getOption(configuration, 'i_Vector');
    %no default
designFileOut           = fullfile(subjectDirectory, tvm_getOption(configuration, 'o_DesignMatrix'));
    %no default
    
definitions = tvm_definitions();

%%
load(designFileIn, definitions.GlmDesign);

tvm_workInProgress();
% designMatrix = zeros(design.Length, length(design.Partitions));
% regressorLabels = cell(1, length(design.Partitions));
% for column = 1:length(design.Partitions)
%     designMatrix(design.Partitions{column}, column) = 1;
%     regressorLabels{column} = 'Constant';
% end
design.DesignMatrix = [design.DesignMatrix, designMatrix];
design.RegressorLabel = [design.RegressorLabel, regressorLabels];
save(designFileOut, definitions.GlmDesign);

end %end function
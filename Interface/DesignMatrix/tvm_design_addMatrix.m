function tvm_design_addMatrix(configuration)
% TVM_DESIGN_ADDMATRIX
%   TVM_DESIGN_ADDMATRIX(configuration)
%   @todo Add description
%
%   Copyright (C) Tim van Mourik, 2016, DCCN
%
% Input:
%   i_SubjectDirectory
%   i_DesignMatrix
%   i_Label
%   i_Matrix
% Output:
%   o_DesignMatrix

%% Parse configuration
subjectDirectory        = tvm_getOption(configuration, 'i_SubjectDirectory', pwd());
    % default: current working directory
designFileIn            = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_DesignMatrix'));
    %no default
label                   = tvm_getOption(configuration, 'i_Label');
    %no default
matrix                  = tvm_getOption(configuration, 'i_Matrix');
    %no default
designFileOut           = fullfile(subjectDirectory, tvm_getOption(configuration, 'o_DesignMatrix'));
    %no default
    
definitions = tvm_definitions();

%%
load(designFileIn, definitions.GlmDesign);
design.DesignMatrix = [design.DesignMatrix, matrix];
design.RegressorLabel = [design.RegressorLabel, label];
save(designFileOut, definitions.GlmDesign);

end %end function
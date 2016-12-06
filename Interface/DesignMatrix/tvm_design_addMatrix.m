function tvm_design_addMatrix(configuration)
%   
%
%   Copyright (C) Tim van Mourik, 2015, DCCN
%

%% Parse configuration
subjectDirectory        = tvm_getOption(configuration, 'i_SubjectDirectory', '.');
    %no default
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
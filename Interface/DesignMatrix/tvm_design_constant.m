function tvm_design_constant(configuration)
%   
%
%   Copyright (C) Tim van Mourik, 2015, DCCN
%

%% Parse configuration
subjectDirectory        = tvm_getOption(configuration, 'i_SubjectDirectory', '.');
    %no default
designFileIn            = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_Design'));
    %no default
designFileOut           = fullfile(subjectDirectory, tvm_getOption(configuration, 'o_Design'));
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
function tvm_design_timeCourse(configuration)
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
cutOffFrequency =       tvm_getOption(configuration, 'i_CutOffFrequency', 1/64);
    %default: 1/64 Hz
TR =                    tvm_getOption(configuration, 'i_TR', 1);
    %default: 1
    
definitions = tvm_definitions();

%%
load(designFileIn, definitions.GlmDesign);
numberOfVolumes = zeros(design.NumberOfPartitions, 1);
for i = 1:design.NumberOfPartitions
    numberOfVolumes(i) = length(design.Partitions{i});
end

filter = tvm_makeFilterRegressors(numberOfVolumes, TR, cutOffFrequency);
numberOfFilterRegressors = size(filter, 2);
regressorLabels = cell(1, numberOfFilterRegressors);
for i = 1:numberOfFilterRegressors
    regressorLabels{i} = 'Filter';
end

design.DesignMatrix = [design.DesignMatrix, filter];
design.RegressorLabel = [design.RegressorLabel, regressorLabels];
save(designFileOut, definitions.GlmDesign);

end %end function
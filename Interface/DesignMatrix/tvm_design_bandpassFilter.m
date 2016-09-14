function tvm_design_bandpassFilter(configuration)
%   
%
%   Copyright (C) Tim van Mourik, 2015, DCCN
%

%% Parse configuration
subjectDirectory        = tvm_getOption(configuration, 'i_SubjectDirectory', '.');
    %no default
designFileIn            = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_DesignMatrix'));
    %no default
designFileOut           = fullfile(subjectDirectory, tvm_getOption(configuration, 'o_DesignMatrix'));
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

% the continuous forms of the filters are orthogonal, but the sampled
% version not necessarily orthogonal up to numerical precission.  
filter = spm_orth(filter);

design.DesignMatrix = [design.DesignMatrix, filter];
design.RegressorLabel = [design.RegressorLabel, regressorLabels];
save(designFileOut, definitions.GlmDesign);

end %end function
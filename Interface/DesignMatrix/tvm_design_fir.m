function tvm_design_fir(configuration)
% TVM_DESIGN_FIR
%   TVM_DESIGN_FIR(configuration)
%   @todo Add description
%   @todo Change old FIR function to current design philosophy
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

tvm_workInProgress();

%%
load(designFileIn, definitions.GlmDesign);

numberOfStimuli = size(stimulusFiles, 2);
allStimuli = cell(numberOfStimuli, 1);
allDurations = cell(numberOfStimuli, 1);
for i = 1:numberOfStimuli
    load(fullfile(subjectDirectory, stimulusFiles{i}), definitions.Stimulus, definitions.Duration);
    stimulusOnset = eval(definitions.Stimulus);
    stimulusDuration = eval(definitions.Duration);
    allStimuli{i} = stimulusOnset;
    allDurations{i} = stimulusDuration;
end

if ischar(hrfParameters)
    hrfFile = fullfile(subjectDirectory, hrfParameters);
    load(hrfFile, definitions.HrfParameters);
    %todo, check if the correct parameters are loaded in
end

designMatrix = zeros(sum(numberOfVolumes), numberOfSegments);
startOfRun = [0, cumsum(numberOfVolumes)] + 1;

for condition = 1:numberOfStimuli
    counter = 1;
    for run = functionalIndices
        timePoints = startOfRun(counter):startOfRun(counter + 1) - 1;

        samplingPoints = TR * ((1:numberOfVolumes(counter)) - 1/2);

        cfg = [];
        cfg.SegmentSpacing = segmentSpacing;
        cfg.NumberOfSegments = numberOfSegments;
        cfg.TimePoints = samplingPoints;
        cfg.Stimulus = allStimuli{condition}{run};
        designMatrix(timePoints, :) = designMatrix(timePoints, :) + tvm_constructFirModel(cfg);
        counter = counter + 1;
    end
end
regressorLabels = cell(1, numberOfSegments);
for i = 1:numberOfSegments
    regressorLabels{i} = 'FIR';
end
design.DesignMatrix = [design.DesignMatrix, designMatrix];
design.RegressorLabel = [design.RegressorLabel, regressorLabels];
save(designFileOut, definitions.GlmDesign);

end %end function




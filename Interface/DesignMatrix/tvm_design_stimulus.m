function tvm_design_stimulus(configuration)

%   
%
%   Copyright (C) Tim van Mourik, 2015, DCCN
%

%% Parse configuration
subjectDirectory        = tvm_getOption(configuration, 'i_SubjectDirectory', pwd());
    %no default
designFileIn            = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_DesignMatrix'));
    %no default
stimulusFiles           = tvm_getOption(configuration, 'i_Stimulus');
    %no default
hrfParameters           = tvm_getOption(configuration, 'i_HrfParameters', []);
    %default:[6, 16, 1, 1, 6, 0, 32]
labels                  = tvm_getOption(configuration, 'i_Labels', {});
    %default: 1
TR                      = tvm_getOption(configuration, 'i_TR', 1);
    %default: 1
temporalDerivative      = tvm_getOption(configuration, 'i_TemporalDerivative', false);
    %default: false
dispersionDerivative    = tvm_getOption(configuration, 'i_DispersionDerivative', false);
    %default: false
designFileOut           = fullfile(subjectDirectory, tvm_getOption(configuration, 'o_DesignMatrix'));
    %no default
    
definitions = tvm_definitions();

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

if isempty(hrfParameters)
    hrfParameters = [6, 16, 1, 1, 6, 0, 32];
elseif isnumeric(hrfParameters)
    %do nothing
else
    hrfFile = fullfile(subjectDirectory, hrfParameters);
    load(hrfFile, definitions.HrfParameters);
    %todo, check if the correct parameters are loaded in  
end

%% Task Regressors
numberOfRuns = length(design.Partitions);
designPerRun = cell(numberOfStimuli, numberOfRuns);
for stimulus = 1:numberOfStimuli
    for run = 1:numberOfRuns
        %minus a half because the volume is said to be acquired at half a TR.
        timePoints = design.Partitions{run} - min(design.Partitions{run}) + 1/2;
        timePoints = timePoints * TR;
        if exist(definitions.Duration, 'var')
            durations = allDurations{stimulus}{run};
        else
            durations = zeros(size(allStimuli{stimulus}{run}));
        end
        configuration = [];
        configuration.Timepoints            = timePoints;
        configuration.Stimuli               = allStimuli{stimulus}{run};
        configuration.Durations             = durations;
        configuration.HrfParameters         = hrfParameters;
        configuration.TemporalDerivative    = temporalDerivative;
        configuration.DispersionDerivative  = dispersionDerivative;
        configuration.DeMean                = false;
        designPerRun{stimulus, run}         = tvm_hrf(configuration)';
    end
end

n = sum([1, temporalDerivative, dispersionDerivative]);
designMatrix = zeros(design.Length, numberOfStimuli * n);
for i = 1:design.NumberOfPartitions
    designMatrix(design.Partitions{i}, 1:numberOfStimuli * n) = [designPerRun{1:numberOfStimuli, i}];
end
% designMatrix = bsxfun(@rdivide, designMatrix, sqrt(sum(designMatrix .^ 2, 1)));

regressorLabels = {};%cell(1, size(designMatrix, 2));
for i = 1:numberOfStimuli
    r = cell(1, n);
    index = 1;
    r{index} = labels{i};
    index = index + 1;
    if temporalDerivative
        r{index} = [labels{i} ', Temp. Deriv.'];
        index = index + 1;
    end
    if dispersionDerivative
        r{index} = [labels{i} ', Disp. Deriv.'];
        index = index + 1;
    end
    regressorLabels = [regressorLabels, r];
end
design.RegressorLabel = [design.RegressorLabel, regressorLabels];

design.DesignMatrix = [design.DesignMatrix, designMatrix];
save(designFileOut, definitions.GlmDesign);

end %end function



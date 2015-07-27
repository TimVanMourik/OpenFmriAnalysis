function tvm_design_stimulus(configuration)

%   
%
%   Copyright (C) Tim van Mourik, 2015, DCCN
%

%% Parse configuration
subjectDirectory        = tvm_getOption(configuration, 'i_SubjectDirectory', '.');
    %no default
designFileIn            = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_Design'));
    %no default
stimulusFiles           = tvm_getOption(configuration, 'i_Stimulus');
    %no default
hrfParameters           = tvm_getOption(configuration, 'i_HrfParameters', '');
    %default:[6, 16, 1, 1, 6, 0, 32]
TR                      = tvm_getOption(configuration, 'i_TR', 1);
    %default: 1
designFileOut           = fullfile(subjectDirectory, tvm_getOption(configuration, 'o_Design'));
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
            designPerRun{stimulus, run} = tvm_hrf(timePoints, allStimuli{stimulus}{run}, allDurations{stimulus}{run}, hrfParameters)';
        else
            designPerRun{stimulus, run} = tvm_hrf(timePoints, allStimuli{stimulus}{run}, zeros(size(allStimuli{stimulus}{run})), hrfParameters)';
        end
    end
end

designMatrix = zeros(design.Length, numberOfStimuli);
for i = 1:design.NumberOfPartitions
    designMatrix(design.Partitions{i}, 1:numberOfStimuli) = [designPerRun{1:numberOfStimuli, i}];
end


regressorLabels = cell(1, size(designMatrix, 2));
for i = 1:size(designMatrix, 2)
    regressorLabels{i} = 'Stimulus';
end
design.RegressorLabel = [design.RegressorLabel, regressorLabels];

design.DesignMatrix = [design.DesignMatrix, designMatrix];
save(designFileOut, definitions.GlmDesign);

end %end function



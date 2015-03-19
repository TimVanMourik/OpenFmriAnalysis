function tvm_constructTemporalDesignMatrix(configuration)
%   
%
%   Copyright (C) Tim van Mourik, 2014, DCCN
%

%% Parse configuration
subjectDirectory =      tvm_getOption(configuration, 'i_SubjectDirectory');
    %no default
stimulusFiles =         tvm_getOption(configuration, 'i_Stimulus');
    %no default
functionalFolder =      fullfile(subjectDirectory, tvm_getOption(configuration, 'i_FunctionalFolder'));
    %default: false
motionFiles =           fullfile(subjectDirectory, tvm_getOption(configuration, 'i_MotionFiles'));
    %no default
designFile =            fullfile(subjectDirectory, tvm_getOption(configuration, 'o_DesignMatrix'));
    %no default
designImageFile =       fullfile(subjectDirectory, tvm_getOption(configuration, 'o_DesignImage'));
    %no default
fir =                   tvm_getOption(configuration, 'p_Fir', false);
    %default: false
segmentSpacing =        tvm_getOption(configuration, 'p_SegmentSpacing', 1);
    %default: 1
numberOfSegments =      tvm_getOption(configuration, 'p_NumberOfSegments', 16);
    %default: 16
functionalIndices  =    tvm_getOption(configuration, 'p_FunctionalSelection', []);
    %no default
linearTrend =           tvm_getOption(configuration, 'p_LinearTrend', false);
    %default: false
sessionRegression =     tvm_getOption(configuration, 'p_SessionRegression', false);
    %default: false
motionRegression =      tvm_getOption(configuration, 'p_MotionRegression', false);
    %no default
highPassFilter =        tvm_getOption(configuration, 'p_HighPassFilter', false);
    %default: false
cutOffFrequency =       tvm_getOption(configuration, 'p_CutOffFrequency', 1 / 64);
    %default: false
TR =                    tvm_getOption(configuration, 'p_TR', 1);
    %default: 1
hrfParameters =         tvm_getOption(configuration, 'p_HrfParameters', [6, 16, 1, 1, 6, 0, 32]);
    %default:[6, 16, 1, 1, 6, 0, 32]
    
definitions = tvm_definitions();
    
%% Construct regressors of interest
allVolumes = [];
for file = 1:length(definitions.VolumeFileTypes)
    allVolumes = [allVolumes; dir(fullfile(functionalFolder, ['*', definitions.VolumeFileTypes{file}]))];
end
if isempty(functionalIndices)
	functionalIndices = 1:size(allVolumes, 1);
end
allVolumes = allVolumes(functionalIndices, :);

numberOfRuns = length(allVolumes);
numberOfVolumes = zeros(1, numberOfRuns);
for session = 1:length(allVolumes)
    sessionVolumes = spm_vol(fullfile(functionalFolder, allVolumes(session).name));
    numberOfVolumes(session) = length(sessionVolumes);
end
startOfRun = [0, cumsum(numberOfVolumes)] + 1;

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

if fir
    taskRegressors = false;
else
    taskRegressors = true;
end

if taskRegressors
    %% Task Regressors
    designPerRun = cell(numberOfStimuli, numberOfRuns);
    for stimulus = 1:numberOfStimuli
        counter = 1;
        for run = functionalIndices
            %minus a half because the volume is said to be acquired at half a TR.
            timePoints = TR * ((1:numberOfVolumes(counter)) - 1/2);
            if exist(definitions.Duration, 'var')
                designPerRun{stimulus, counter} = tvm_hrf(timePoints, allStimuli{stimulus}{run}, allDurations{stimulus}{run}, hrfParameters)';
            else
                designPerRun{stimulus, counter} = tvm_hrf(timePoints, allStimuli{stimulus}{run}, zeros(size(allStimuli{stimulus}{run})), hrfParameters)';
            end
            counter = counter + 1;
        end
    end

    designMatrix = zeros(sum(numberOfVolumes), numberOfStimuli);
    for i = 1:numberOfRuns
        designMatrix(startOfRun(i):startOfRun(i + 1) - 1, 1:numberOfStimuli) = [designPerRun{1:numberOfStimuli, i}];
    end
elseif fir
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
else
    %@todo mmake nice error message
    error('Nice error message to be inserted');
end
%% Session Regressors
if sessionRegression
    designPart = zeros(sum(numberOfVolumes), numberOfRuns);
    counter = 1;
    for run = 1:numberOfRuns
        designPart(startOfRun(counter):startOfRun(counter + 1) - 1, counter) = 1;
        counter = counter + 1;
    end
    designMatrix = [designMatrix, designPart];
end

%% Linear Trend
if linearTrend
    designPart = zeros(sum(numberOfVolumes), 1);
    for run = 1:numberOfRuns
        timePoints = startOfRun(run):startOfRun(run + 1) - 1;
        designPart(timePoints, run) = -1:2 / (length(timePoints) - 1):1;
    end
    designMatrix = [designMatrix, designPart];
end

%% High-pass Filter
if highPassFilter
    filter = tvm_makeFilterRegressors(numberOfVolumes, TR, cutOffFrequency);
    designMatrix = [designMatrix, filter];
end

%% In case of motion regression
if motionRegression
    designPart = zeros(sum(numberOfVolumes), numberOfRuns * 6);
    [root, ~, ~] = fileparts(motionFiles);
    motionFiles = dir(motionFiles);
    counter = 1;
    for run = functionalIndices
        motionParameters = importdata(fullfile(root, motionFiles(run).name));
        designPart(startOfRun(counter):startOfRun(counter + 1) - 1, (1:6) + 6 * (counter - 1)) = motionParameters;
        counter = counter + 1;
    end
    designMatrix = [designMatrix, designPart];
end

%% Save picture
figure('units', 'normalized', 'outerposition', [0, 0, 1, 1]);
imagesc(designMatrix);
saveas(gca, designImageFile);

%%
design = [];
design.DesignMatrix = designMatrix;
save(designFile, definitions.GlmDesign);

end %end function








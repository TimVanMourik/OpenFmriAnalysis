function tvm_design_stimulus(configuration)
% TVM_DESIGN_STIMULUS
%   TVM_DESIGN_STIMULUS(configuration)
%   @todo Add description
%
% Input:
%   i_SubjectDirectory
%   i_DesignMatrix
%   i_Stimulus
%   i_HrfParameters
%   i_Labels
%   i_TR
%   i_TemporalDerivative
%   i_DispersionDerivative
%   i_DiagonaliseElements
% Output:
%   o_DesignMatrix

%   Copyright (C) Tim van Mourik, 2015-2017, DCCN
%
% This file is part of the fmri analysis toolbox, see 
% https://github.com/TimVanMourik/FmriAnalysis for the documentation and 
% details.
%
%    This toolbox is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    This toolbox is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with the fmri analysis toolbox. If not, see 
%    <http://www.gnu.org/licenses/>.

%% Parse configuration
subjectDirectory        = tvm_getOption(configuration, 'i_SubjectDirectory', pwd());
    % default: current working directory
designFileIn            = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_DesignMatrix'));
    %no default
stimulusFiles           = tvm_getOption(configuration, 'i_Stimulus');
    %no default
hrfParameters           = tvm_getOption(configuration, 'i_HrfParameters', []);
    %default: empty (later standard settings will be inserted)
labels                  = tvm_getOption(configuration, 'i_Labels', {});
    %default: empty
TR                      = tvm_getOption(configuration, 'i_TR', 1);
    %default: 1 second
temporalDerivative      = tvm_getOption(configuration, 'i_TemporalDerivative', false);
    %default: false
dispersionDerivative    = tvm_getOption(configuration, 'i_DispersionDerivative', false);
    %default: false
diagonaliseElements     = tvm_getOption(configuration, 'i_DiagonaliseElements', true);
    %default: true
designFileOut           = fullfile(subjectDirectory, tvm_getOption(configuration, 'o_DesignMatrix'));
    %no default
    
definitions = tvm_definitions();

%%
load(designFileIn, definitions.GlmDesign);

numberOfStimuli = size(stimulusFiles, 2);
allStimuli = cell(numberOfStimuli, 1);
allDurations = cell(numberOfStimuli, 1);
for i = 1:numberOfStimuli
    if iscell(stimulusFiles{i})
        for j = 1:length(stimulusFiles{i})
            load(fullfile(subjectDirectory, stimulusFiles{i}{j}), definitions.Stimulus, definitions.Duration);
            stimulusOnset = eval(definitions.Stimulus);
            stimulusDuration = eval(definitions.Duration);
            if isempty(allStimuli{i})
                allStimuli{i} = stimulusOnset;
                allDurations{i} = stimulusDuration;
            else
                allStimuli{i}   = cellfun(@horzcat, allStimuli{i}, stimulusOnset, 'UniformOutput', false);
                allDurations{i} = cellfun(@horzcat, allDurations{i}, stimulusDuration, 'UniformOutput', false);
            end
        end
    else
        load(fullfile(subjectDirectory, stimulusFiles{i}), definitions.Stimulus, definitions.Duration);
        stimulusOnset = eval(definitions.Stimulus);
        stimulusDuration = eval(definitions.Duration);
        allStimuli{i} = stimulusOnset;
        allDurations{i} = stimulusDuration;
    end
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
        cfg = [];
        cfg.Timepoints            = timePoints;
        cfg.Stimuli               = allStimuli{stimulus}{run};
        cfg.Durations             = durations;
        cfg.HrfParameters         = hrfParameters;
        cfg.TemporalDerivative    = temporalDerivative;
        cfg.DispersionDerivative  = dispersionDerivative;
        cfg.DeMean                = false;
        designPerRun{stimulus, run}         = tvm_hrf(cfg)';
    end
end


n = sum([1, temporalDerivative, dispersionDerivative]);

if diagonaliseElements
    designMatrix = zeros(design.Length, numberOfStimuli * n * numberOfRuns);
    x = zeros(1,numberOfRuns);
    for i = 1:numberOfRuns
        x(i) = numberOfStimuli * n * (i-1);
    end
else
    designMatrix = zeros(design.Length, numberOfStimuli * n);
    x = zeros(1,numberOfRuns);
end

for i = 1:design.NumberOfPartitions
    designMatrix(design.Partitions{i}, (1:numberOfStimuli * n) + x(i)) = [designPerRun{1:numberOfStimuli, i}];
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

if diagonaliseElements
    design.RegressorLabel = [design.RegressorLabel, repmat(regressorLabels, 1, design.NumberOfPartitions)];
else
    design.RegressorLabel = [design.RegressorLabel, regressorLabels]; 
end

design.DesignMatrix = [design.DesignMatrix, designMatrix];
save(designFileOut, definitions.GlmDesign);

end %end function



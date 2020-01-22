function tvm_design_fir(configuration)
% TVM_DESIGN_FIR
%   TVM_DESIGN_FIR(configuration)
%   @todo Add description
%   @todo Change old FIR function to current design philosophy
%
% Input:
%   i_SubjectDirectory
%   i_DesignMatrix
% Output:
%   o_DesignMatrix

%   Copyright (C) Tim van Mourik, 2015-2016, DCCN
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
labels                  = tvm_getOption(configuration, 'i_Labels');
    %no default
numberOfSegments        = tvm_getOption(configuration, 'i_NumberOfSegments');
    %no default
segmentSpacing          = tvm_getOption(configuration, 'i_SegmentSpacing');
    %no default
prestimulus             = tvm_getOption(configuration, 'i_PreStimulus', 0);
    %no default
TR                      = tvm_getOption(configuration, 'i_TR');
    %no default
designFileOut           = fullfile(subjectDirectory, tvm_getOption(configuration, 'o_DesignMatrix'));
    %no default
    
definitions = tvm_definitions();


%%
numberOfStimuli = size(stimulusFiles, 2);
allStimuli = cell(numberOfStimuli, 1);
for i = 1:numberOfStimuli
    if iscell(stimulusFiles{i})
        onsets = [];
        for j = 1:length(stimulusFiles{i})
            if exist(stimulusFiles{i}{j}, 'file')
                load(fullfile(subjectDirectory, stimulusFiles{i}{j}), definitions.Stimulus);
                onsets = [onsets, stimulusOnset];
            end
        end
        stimulusOnset = onsets;
    else
        load(fullfile(subjectDirectory, stimulusFiles{i}{1}), definitions.Stimulus);
        stimulusOnset = eval(definitions.Stimulus);
    end
    allStimuli{i} = stimulusOnset;
end

load(designFileIn, definitions.GlmDesign);
numberOfVolumes = cellfun(@(x)length(x), design.Partitions);
startOfRun = [0; cumsum(numberOfVolumes)] + 1;

for condition = 1:numberOfStimuli
    designMatrix = zeros(sum(numberOfVolumes), numberOfSegments);
    for run = 1:length(numberOfVolumes)
        timePoints = startOfRun(run):startOfRun(run + 1) - 1;
        samplingPoints = TR * ((1:numberOfVolumes(run)) - 1/2);

        cfg = [];
        cfg.SegmentSpacing = segmentSpacing;
        cfg.NumberOfSegments = numberOfSegments;
        cfg.TimePoints = samplingPoints;
        cfg.Stimulus = allStimuli{condition}{run} - prestimulus;
        designMatrix(timePoints, :) = designMatrix(timePoints, :) + tvm_constructFirModel(cfg);
    end
    
    design.DesignMatrix = [design.DesignMatrix, designMatrix];
    
    regressorLabels = cell(1, numberOfSegments);
    for i = 1:numberOfSegments
        regressorLabels{i} = sprintf('%s_FIR_%d', labels{condition}, i);
    end
    design.RegressorLabel = [design.RegressorLabel, regressorLabels];
end

save(designFileOut, definitions.GlmDesign);

end %end function




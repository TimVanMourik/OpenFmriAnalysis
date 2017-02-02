function tvm_design_retroicor(configuration)
% TVM_DESIGN_RETROICOR
%   TVM_DESIGN_RETROICOR(configuration)
%   @todo Add description
%
% Input:
%   i_SubjectDirectory
%   i_DesignMatrix
%   i_PhysioFiles
%   i_ScanTriggers
%   i_Order
%   i_Type
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
physioFiles             = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_PhysioFiles'));
    %no default
ScanTriggerFiles      	= fullfile(subjectDirectory, tvm_getOption(configuration, 'i_ScanTriggers'));
    %no default
orderOfRegressors       = tvm_getOption(configuration, 'i_Order', 1);
    %default: 1
type                    = tvm_getOption(configuration, 'i_Type', 'Physio');
    %default: 'Physio'
designFileOut           = fullfile(subjectDirectory, tvm_getOption(configuration, 'o_DesignMatrix'));
    %no default
  
definitions = tvm_definitions();

%%
load(designFileIn, definitions.GlmDesign);

% extract full files
triggerFiles = strsplit(ls(ScanTriggerFiles), '\n');
% remove empty cells
triggerFiles = triggerFiles(~cellfun(@isempty, triggerFiles));

% extract full files
fileNames = strsplit(ls(physioFiles), '\n');
% remove empty cells
fileNames = fileNames(~cellfun(@isempty, fileNames));
% generate regressors
physioRegressors = zeros(design.Length, design.NumberOfPartitions * orderOfRegressors * 2);

%%
emptyColumn = true(1, size(physioRegressors, 2));
for column = 1:length(fileNames)
    %@TODO make this file conditional, use TR otherwise
    load(triggerFiles{column}, 'acquisitionTimes');
    
    [triggers, rejectionWindows] = tvm_readPhysioFile(fileNames{column});
    [phase, phaseKnown] = tvm_getPhase(triggers, acquisitionTimes);
    withinReject = false(size(acquisitionTimes));
   	for i = 1:length(rejectionWindows)
        withinReject = withinReject | (acquisitionTimes > rejectionWindows{i}(1) & acquisitionTimes < rejectionWindows{i}(2));
    end
    phaseKnown(withinReject) = false;
    if sum(phaseKnown) ~= 0
        a = (column - 1) * 2 * orderOfRegressors + 1;
        b = column * 2 * orderOfRegressors;
        emptyColumn(a:b) = false;
    else
        continue
    end
        
    for order = 1:orderOfRegressors
        offset = (column - 1) * 2 * orderOfRegressors;
        if length(phaseKnown) > length(design.Partitions{column})
            phaseKnown = phaseKnown(1:length(design.Partitions{column}));
        end
        physioRegressors(design.Partitions{column}(phaseKnown), offset + order)                         = sin(phase(phaseKnown) * order * 2 * pi);
        physioRegressors(design.Partitions{column}(phaseKnown), offset + order + orderOfRegressors) = cos(phase(phaseKnown) * order * 2 * pi);
    end
end

physioRegressors = physioRegressors(:, ~emptyColumn);
regressorLabels = cell(1, size(physioRegressors, 2));
for column = 1:size(physioRegressors, 2)
    regressorLabels{column} = type; %@TODO add order number
end
design.DesignMatrix     = [design.DesignMatrix, physioRegressors];
design.RegressorLabel   = [design.RegressorLabel, regressorLabels];

%%
save(designFileOut, definitions.GlmDesign);

end %end function



function tvm_design_highpassFilter(configuration)
% TVM_DESIGN_HIGHPASSFILTER
%   TVM_DESIGN_HIGHPASSFILTER(configuration)
%   @todo Add description
%
% Input:
%   i_SubjectDirectory
%   i_DesignMatrix
%   i_CutOffFrequency
%   i_TR
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
cutOffFrequency         = tvm_getOption(configuration, 'i_CutOffFrequency', 1/64);
    %default: 1/64 Hz
TR                      = tvm_getOption(configuration, 'i_TR', 1);
    %default: 1 second
designFileOut           = fullfile(subjectDirectory, tvm_getOption(configuration, 'o_DesignMatrix'));
    %no default
    
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
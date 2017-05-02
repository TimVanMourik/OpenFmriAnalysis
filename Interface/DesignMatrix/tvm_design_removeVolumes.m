function tvm_design_removeVolumes(configuration)
% TVM_DESIGN_REMOVEVOLUMES
%   TVM_DESIGN_REMOVEVOLUMES(configuration)
%   @todo Add description
%
% Input:
%   i_SubjectDirectory
%   i_DesignMatrix
%   i_Deletions
% Output:
%   o_DesignMatrix

%   Copyright (C) Tim van Mourik, 2017, DCCN
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
deletions               = tvm_getOption(configuration, 'i_Deletions');
    %no default
designFileOut           = fullfile(subjectDirectory, tvm_getOption(configuration, 'o_DesignMatrix'));
    %no default
    
definitions = tvm_definitions();

%%
load(designFileIn, definitions.GlmDesign);

designMatrix = zeros(design.Length, length([deletions{:}]));
regressorLabels = repmat({'Deleted'}, [1, length([deletions{:}])]);
for run = 1:length(design.Partitions)
    rows = design.Partitions{run}(deletions{run});
    columns = length([deletions{1:(run-1)}]) + (1:length(deletions{run}));
    designMatrix(sub2ind(size(designMatrix), rows, columns)) = 1;
end

design.DesignMatrix = [design.DesignMatrix, designMatrix];
design.RegressorLabel = [design.RegressorLabel, regressorLabels];
save(designFileOut, definitions.GlmDesign);

end %end function
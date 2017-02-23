function tvm_design_reorderRegressors(configuration)
% TVM_DESIGN_REORDERREGRESSORS
%   TVM_DESIGN_REORDERREGRESSORS(configuration)
%   Reorder the regressors. Everything that does not show up in 'i_Order'
%   will be pushed backward.
%   @todo Expand description
%
% Input:
%   i_SubjectDirectory
%   i_DesignMatrix
%   i_Order
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
order                   = tvm_getOption(configuration, 'i_Order');
    %no default
designFileOut           = fullfile(subjectDirectory, tvm_getOption(configuration, 'o_DesignMatrix'));
    %no default
    
definitions = tvm_definitions();

%%
load(designFileIn, definitions.GlmDesign);

newDesignMatrix = [];
newRegressorLabels = {};
for type = order
    indices = strcmp(design.RegressorLabel, type);
    newDesignMatrix = [newDesignMatrix, design.DesignMatrix(:, indices)]; %#ok<AGROW>
    newRegressorLabels = [newRegressorLabels, design.RegressorLabel(:, indices)]; %#ok<AGROW>
    design.DesignMatrix(:, indices) = [];
    design.RegressorLabel(indices) = [];
end
newDesignMatrix = [newDesignMatrix, design.DesignMatrix];
newRegressorLabels = [newRegressorLabels, design.RegressorLabel];
design.DesignMatrix = newDesignMatrix;
design.RegressorLabel = newRegressorLabels;

% @todo add temporal derivatives?

save(designFileOut, definitions.GlmDesign);

end %end function
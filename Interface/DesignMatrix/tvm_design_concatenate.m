function tvm_design_concatenate(configuration)
% TVM_DESIGN_CONCATENATE
%   TVM_DESIGN_CONCATENATE(configuration)
%   @todo Add description
%
% Input:
%   i_SubjectDirectory
%   i_DesignMatrices
% Output:
%   o_DesignMatrix

%   Copyright (C) Tim van Mourik, 2019, DCCN
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
inputDesigns            = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_DesignMatrices'));
    % default: empty
designFileOut           = fullfile(subjectDirectory, tvm_getOption(configuration, 'o_DesignMatrix'));
    %no default
  
definitions = tvm_definitions();

%%
designs = cell(size(inputDesigns));
for i = 1:length(inputDesigns)
    if exist(inputDesigns{i}, 'file')
        load(inputDesigns{i}, definitions.GlmDesign);
        designs{i} = eval(definitions.GlmDesign);
    else 
        designs = designs(1:end -1);
    end
end

newDesign = [];
newDesign.NumberOfPartitions = sum(cellfun(@(x) x.NumberOfPartitions, designs));
newDesign.Partitions = cellfun(@(x) x.Partitions, designs, 'UniformOutput', false);
newDesign.Partitions = vertcat(newDesign.Partitions{:});
newDesign.PartitionLabel = cellfun(@(x) x.PartitionLabel, designs, 'UniformOutput', false);
newDesign.PartitionLabel = vertcat(newDesign.PartitionLabel{:});
newDesign.RegressorLabel = cellfun(@(x) x.RegressorLabel, designs, 'UniformOutput', false);
newDesign.RegressorLabel = horzcat(newDesign.RegressorLabel{:});
newDesign.Length = sum(cellfun(@(x) x.Length, designs));

a = cellfun(@(x) size(x.DesignMatrix), designs, 'UniformOutput', false);
dimensions = vertcat(a{:});
newDesign.DesignMatrix = zeros(sum(dimensions, 1));
sumDimensions = cumsum([1,1; dimensions]);
for i = 1:size(dimensions, 1)
    x = sumDimensions(i, 1) : sumDimensions(i + 1, 1) - 1;
    y = sumDimensions(i, 2) : sumDimensions(i + 1, 2) - 1;
    newDesign.DesignMatrix(x, y) = designs{i}.DesignMatrix;
end

design = newDesign;

save(designFileOut, definitions.GlmDesign);

end %end function



function tvm_multiplyMatrices(configuration)
% TVM_MULTIPLYMATRICES
%   TVM_MULTIPLYMATRICES(configuration)
%   @todo Add description
%
% Input:
%   i_SubjectDirectory
%   i_Matrices
% Output:
%   o_Matrix
%

%   Copyright (C) Tim van Mourik, 2014, DCCN
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
subjectDirectory =      tvm_getOption(configuration, 'i_SubjectDirectory', pwd());
    % default: current working directory
inputMatrices =         fullfile(subjectDirectory, tvm_getOption(configuration, 'i_Matrices'));
    %no default
outputMatrix =      	fullfile(subjectDirectory, tvm_getOption(configuration, 'o_Matrix'));
    %no default
    
% definitions = tvm_definitions();    

%%
m = eye(4);
for i = 1:length(inputMatrices)
    load(inputMatrices{i}, 'coregistrationMatrix');
    m = m * coregistrationMatrix;
end
coregistrationMatrix = m;

save(outputMatrix, 'coregistrationMatrix');

end %end function




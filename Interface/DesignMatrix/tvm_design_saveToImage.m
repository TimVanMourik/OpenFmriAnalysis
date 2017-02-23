function tvm_design_saveToImage(configuration)
% TVM_DESIGN_SAVETOIMAGE
%   TVM_DESIGN_SAVETOIMAGE(configuration)
%   @todo Add description
%
% Input:
%   i_SubjectDirectory
%   i_DesignMatrix
% Output:
%   o_Image

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
imageFile               = fullfile(subjectDirectory, tvm_getOption(configuration, 'o_Image'));
    %no default
  
definitions = tvm_definitions();

%%
load(designFileIn, definitions.GlmDesign);

%% Save picture
figure('units', 'normalized', 'outerposition', [0, 0, 1, 1]);
imagesc(design.DesignMatrix);
%todo: incorporate the design matrix labels
saveas(gca, imageFile);

end %end function



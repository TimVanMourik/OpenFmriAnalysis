function tvm_smoothFunctionals(configuration)
% TVM_RECONALL 
%   TVM_RECONALL(configuration)
%   From a structural scan, this matlab routine runs FreeSurfer
%   @todo Expand description
%
% Input:
%   i_SubjectDirectory
%   i_SourceDirectory
%   i_SmoothingKernel
%   i_Qsub
% Output:
%   o_OutputDirectory
%

%   Copyright (C) Tim van Mourik, 2014-2015, DCCN
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
functionalDirectory =   fullfile(subjectDirectory, tvm_getOption(configuration, 'i_SourceDirectory'));
    %no default
smoothingKernel =       tvm_getOption(configuration, 'i_SmoothingKernel', [4, 4, 4]);
    % default: [4, 4, 4]
useQsub =               tvm_getOption(configuration, 'i_Qsub', false);
    % default: no parallellisation
smoothingDirectory =    fullfile(subjectDirectory, tvm_getOption(configuration, 'o_OutputDirectory'));
    %no default
    
%%
volumeNames = dir(fullfile(functionalDirectory, '*.nii'));
volumeNames = {volumeNames.name};
allVolumes = fullfile(functionalDirectory, volumeNames);
newVolumes = fullfile(smoothingDirectory, strcat('s', volumeNames));

if useQsub
    compilation = 'no';
    memoryRequirement = 2 * 1024 ^ 3;
    timeRequirement = 10 * 60;
    for i = 1:length(allVolumes)
        qsubfeval(@spm_smooth, allVolumes{i}, newVolumes{i}, smoothingKernel, 'memreq', memoryRequirement, 'timreq', timeRequirement, 'compile', compilation);
    end
else
    cellfun(@spm_smooth, allVolumes, newVolumes, repmat({smoothingKernel}, 1, length(allVolumes)));
end

end %end function






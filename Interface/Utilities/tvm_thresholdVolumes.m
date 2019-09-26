function tvm_thresholdVolumes(configuration)
% TVM_THRESHOLDVOLUMES
%   TVM_THRESHOLDVOLUMES(configuration)
%   @todo Add description
%
% Input:
%   i_SubjectDirectory
%   i_Volumes
%   i_Threshold
% Output:
%   o_ThresholdedVolume
%

%   Copyright (C) Tim van Mourik, 2014-2019, DCCN
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
volumeFile =            fullfile(subjectDirectory, tvm_getOption(configuration, 'i_Volumes'));
    %no default
threshold =             tvm_getOption(configuration, 'i_Threshold', 1.96);
    % 1.96, two-tailed significance threshold
thresholdFile =         fullfile(subjectDirectory, tvm_getOption(configuration, 'o_ThresholdedVolumes'));
    %no default
    
%%
if ~iscell(volumeFile)
    volumeFile = {volumeFile};
    thresholdFile = {thresholdFile};
end

for i = 1:length(volumeFile)
    v = spm_vol(volumeFile{i});
    v.volume = spm_read_vols(v);
    v.volume(v.volume < threshold) = 0;
    v.fname = thresholdFile{i};

    spm_write_vol(v, v.volume);
end

end %end function








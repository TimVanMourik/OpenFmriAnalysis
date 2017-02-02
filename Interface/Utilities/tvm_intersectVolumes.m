function tvm_intersectVolumes(configuration)
% TVM_INTERSECTVOLUMES
%   TVM_INTERSECTVOLUMES(configuration)
%   @todo Add description
%
% Input:
%   i_SubjectDirectory
%   i_InputVolumes
%   i_IntersectionVolumes
% Output:
%   o_OutputVolumes
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
volumeFiles =          	fullfile(subjectDirectory, tvm_getOption(configuration, 'i_InputVolumes'));
    %no default
intersectionFiles =    	fullfile(subjectDirectory, tvm_getOption(configuration, 'i_IntersectionVolumes'));
    %no default
outputFiles =           fullfile(subjectDirectory, tvm_getOption(configuration, 'o_OutputVolumes'));
    %no default
    
%%
%Load the volume data

for i = 1:length(volumeFiles)
    inputVolume = spm_vol(volumeFiles{i});
    inputVolume.volume = spm_read_vols(inputVolume);
    for j = 1:length(intersectionFiles);
        intersectVolume = spm_vol(intersectionFiles{j});
        intersectVolume.volume = spm_read_vols(intersectVolume);
        inputVolume.volume = inputVolume.volume & intersectVolume.volume;
    end
    inputVolume.fname = outputFiles{i};
    spm_write_vol(inputVolume, inputVolume.volume);
end

output = memtoc;

end %end function
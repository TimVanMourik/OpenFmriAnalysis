function tvm_unionVolumes(configuration)
% TVM_UNIONVOLUMES
%   TVM_UNIONVOLUMES(configuration)
%   @todo Add description
%
% Input:
%   i_SubjectDirectory
%   i_InputVolumes
% Output:
%   o_OutputVolume
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
volumeFiles =           tvm_getOption(configuration, 'i_InputVolumes');
    %no default
outputFile =            fullfile(subjectDirectory, tvm_getOption(configuration, 'o_OutputVolume'));
    %no default
    
%%
for i = 1:length(volumeFiles)
    inputVolumes = fullfile(subjectDirectory, volumeFiles{i});

    currentVolume = spm_vol(inputVolumes{1});
    unionVolume = spm_read_vols(currentVolume);

    for j = 2:length(volumeFiles{i})
        currentVolume = spm_vol(inputVolumes{j});
        unionVolume = unionVolume | spm_read_vols(currentVolume);
    end
    currentVolume.fname = outputFile{i};
    spm_write_vol(currentVolume, unionVolume);
end

end %end function
function tvm_warpVolumes(configuration)
% TVM_WARPVOLUMES(configuration)
%   TVM_WARPVOLUMES(configuration)
%   @todo Add description
%
% Input:
%   i_SubjectDirectory
%   i_DisplacementMap
%   i_Volume
% Output:
%   o_Volume
%

%   Copyright (C) Tim van Mourik, 2016, DCCN
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
subjectDirectory =      	tvm_getOption(configuration, 'i_SubjectDirectory');
    % default: current working directory
displacementMapFile =       fullfile(subjectDirectory, tvm_getOption(configuration, 'i_DisplacementMap'));
    %no default
volumeIn =                  fullfile(subjectDirectory, tvm_getOption(configuration, 'i_Volume'));
    %no default
volumeOut =                 fullfile(subjectDirectory, tvm_getOption(configuration, 'o_Volume'));
    %no default

%%
vdm = spm_vol(displacementMapFile);
vdm.volume = spm_read_vols(vdm);
configuration.InterpolationMethod = 'Trilinear';

[y, x, z] = meshgrid(1:vdm.dim(2), 1:vdm.dim(1), 1:vdm.dim(3));
coordinates = [x(:), y(:) + vdm.volume(:), z(:)];

inputVolume = spm_vol(volumeIn);
vdm.volume(:) = tvm_sampleVoxels(spm_read_vols(inputVolume), coordinates, configuration);
inputVolume.fname = volumeOut;
spm_write_vol(inputVolume, vdm.volume);

end %end function

function tvm_resliceVolume(configuration)
% TVM_RESLICEVOLUME(configuration)
%   TVM_RESLICEVOLUME(configuration)
%   @todo Add description
%
% Input:
%   i_SubjectDirectory
%   i_ReferenceVolume
%   i_CoregistrationMatrix
%   i_MoveVolumes
%   i_InterpolationMethod
%   i_InverseRegistration
% Output:
%   o_OutputVolumes
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
subjectDirectory 	= tvm_getOption(configuration, 'i_SubjectDirectory');
    % default: current working directory
referenceVolumeFile = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_ReferenceVolume'));
    %no default
coregistrationFile  = tvm_getOption(configuration, 'i_CoregistrationMatrix', []);
    % default: empty
moveFiles           = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_MoveVolumes'));
    %no default
interpolationMethod = tvm_getOption(configuration, 'i_InterpolationMethod', false);
    % default: false
inverseRegistration = tvm_getOption(configuration, 'i_InverseRegistration', false);
    % default: false
volumeFiles         = fullfile(subjectDirectory, tvm_getOption(configuration, 'o_OutputVolumes'));
    %no default
    
%%
if isempty(coregistrationFile)
    coregistrationMatrix = eye(4);
else
    coregistrationFile = fullfile(subjectDirectory, coregistrationFile);
    load(coregistrationFile, 'coregistrationMatrix');
    if inverseRegistration
        coregistrationMatrix = inv(coregistrationMatrix);
    end
end

reference = spm_vol(referenceVolumeFile);

files = spm_vol(moveFiles);
for i = 1:length(files)
    files{i}.mat = coregistrationMatrix \ files{i}.mat;
end
files = [reference, files{:}];
cfg = [];
switch interpolationMethod
    case 'NearestNeighbour'
        cfg.interp = 0;
    otherwise
        cfg.interp = 1;
end
spm_reslice(files, cfg);

for i = 1:length(moveFiles)
    [root, file, extension] = fileparts(moveFiles{i});
    movefile(fullfile(root, ['r', file, extension]), volumeFiles{i});
end

end %end function







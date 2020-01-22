function tvm_mixVolumes(configuration)
% TVM_MIXVOLUMES
%   TVM_MIXVOLUMES(configuration)
%   @todo Add description
%
% Input:
%   i_SubjectDirectory
%   i_ReferenceVolume
%   i_Mixture
% Output:
%   o_MixtureVolume
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
subjectDirectory        = tvm_getOption(configuration, 'i_SubjectDirectory', pwd());
    % default: current working directory
referenceVolume         = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_ReferenceVolume'));
    %no default
mixture                 = tvm_getOption(configuration, 'i_Mixture');
    %no default
mixtureFile             = fullfile(subjectDirectory, tvm_getOption(configuration, 'o_MixtureVolume'));
    %no default

definitions = tvm_definitions();

%%
ref = spm_vol(referenceVolume);
referenceVolume = spm_read_vols(ref);

mixtureVolume = zeros([ref(1).dim, size(mixture, 1)]);
m = zeros([1, 1, size(mixture)]);
m(1, 1, :, :) = mixture;
for i = 1:size(mixture, 1);
    mixtureVolume(:, :, :, i) = sum(bsxfun(@times, referenceVolume, m(:, :, i, :)), 4);
end
tvm_write4D(ref, mixtureVolume, mixtureFile);

end %end function











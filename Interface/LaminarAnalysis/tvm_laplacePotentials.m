function tvm_laplacePotentials(configuration)
% TVM_LAPLACEPOTENTIALS 
%   TVM_LAPLACEPOTENTIALS(configuration)
%   @todo Add description
%
% Input:
%   i_SubjectDirectory
%   i_White
%   i_Pial
%   i_B0
%   i_B1
% Output:
%   o_LaplacePotential
%

%
%   Copyright (C) Martin Havlicek 2015, Maastricht University, Tim van 
%   Mourik, 2016, DCCN
%   Original function written by Martin Havlicek, 2015
%   Vectorised and speed-optimised by Tim van Mourik, 2016, DCCN
%   Modified to fit this toolbox by Tim van Mourik, 2016, DCCN
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
white                   = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_White'));
    %no default
pial                    = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_Pial'));
    %no default
b0                      = tvm_getOption(configuration, 'i_B0', 0);
    %no default
b1                      = tvm_getOption(configuration, 'i_B1', 1);
    %no default
potentialFile           = fullfile(subjectDirectory, tvm_getOption(configuration, 'o_LaplacePotential'));
    %no default
    
%%
whiteLevelSet = spm_vol(white);
whiteLevelSet.volume = spm_read_vols(whiteLevelSet);

pialLevelSet = spm_vol(pial);
pialLevelSet.volume = spm_read_vols(pialLevelSet);

potential                            = -inf(whiteLevelSet.dim);
u_to_w                               = zeros(whiteLevelSet.dim);
potential(whiteLevelSet.volume < 0)  = b1;
potential(pialLevelSet.volume  >  0) = b0;
potential([1, end], :, :) = NaN;
potential(:, [1, end], :) = NaN;
potential(:, :, [1, end]) = NaN;

greyMatter          = find(potential == -Inf);
N                   = length(greyMatter);
u_to_w(greyMatter)  = 1:N;
[x, y, z]           = ind2sub(size(potential), greyMatter);
w_to_u              = [x, y, z];

XYZ = repmat(w_to_u, [1, 1, 6]);
XYZ(:, 1, 1) = XYZ(:, 1, 1) - 1;
XYZ(:, 1, 2) = XYZ(:, 1, 2) + 1;
XYZ(:, 2, 3) = XYZ(:, 2, 3) - 1;
XYZ(:, 2, 4) = XYZ(:, 2, 4) + 1;
XYZ(:, 3, 5) = XYZ(:, 3, 5) - 1;
XYZ(:, 3, 6) = XYZ(:, 3, 6) + 1;

mi          = squeeze(u_to_w(sub2ind(size(potential),    XYZ(:, 1, :), XYZ(:, 2, :), XYZ(:, 3, :))));
kind        = squeeze(potential(sub2ind(size(potential), XYZ(:, 1, :), XYZ(:, 2, :), XYZ(:, 3, :))));

indices     = kind == -Inf & mi > 0;
k           = mod(find(indices), N);
k(k == 0)   = N;

i = [(1:N)'; k(:)];
j = [(1:N)'; mi(indices)];
v = [-6 * ones(N, 1) + sum(isnan(kind), 2); ones(length(k), 1)];
M = sparse(i, j, v, N, N);

kind(kind == -Inf)  = 0;
kind(isnan(kind))   = 0;
b                   = -sum(kind, 2);  

% Solve the Laplace equation
potential(sub2ind(size(potential), w_to_u(:, 1), w_to_u(:, 2), w_to_u(:, 3))) = M \ b;

% In order to smoothen the transition at the borders for the subsequent
% gradient and curvature steps
slope = mean(whiteLevelSet.volume(:) - pialLevelSet.volume(:));
inside = whiteLevelSet.volume < 0;
potential(inside) = 1 - whiteLevelSet.volume(inside) / (slope * 2);
outside = pialLevelSet.volume > 0;
potential(outside) =  - pialLevelSet.volume(outside) / (slope * 3);

whiteLevelSet.fname = potentialFile;
spm_write_vol(whiteLevelSet, potential);

end %end function











function tvm_antsRegistration(configuration)
% TVM_ANTSREGISTRATION
%   TVM_ANTSREGISTRATION(configuration)
%   @todo Add description
%
% Input:
%   i_SubjectDirectory
%   i_ReferenceVolume
%   i_Boundaries
%   i_Mask
%   i_MinimumVoxels
%   i_MinimumVertices
%   i_CuboidElements
%   i_Tetrahedra
%   i_NeighbourSmoothing
%
% Output:
%   o_Boundaries
%   o_DisplacementMap
%

%   Copyright (C) Tim van Mourik, 2014-2018, DCCN
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
referenceFile           = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_ReferenceVolume'));
    %no default
moveFile                = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_MoveVolume'));
    %no default
rigidBody               = tvm_getOption(configuration, 'i_RigidBody', false);
    %no default
affine                  = tvm_getOption(configuration, 'i_Affine', false);
    %no default
nonLinear               = tvm_getOption(configuration, 'i_NonLinear', false);
    %no default
synParameters           = tvm_getOption(configuration, 'i_SynParameters', [0.1,  3, 0]);
    %no default
outputFilesPrefix       = fullfile(subjectDirectory, tvm_getOption(configuration, 'o_OutputFilesPrefix'));
    % default: empty
warpedVolume            = fullfile(subjectDirectory, tvm_getOption(configuration, 'o_WarpedVolume'));
    % default: empty

definitions = tvm_definitions();

%% Just loading data

% https://github.com/ANTsX/ANTs/wiki/Anatomy-of-an-antsRegistration-call
registrationCommand = ['antsRegistration', ...
                       ' --dimensionality 3', ... %3D image
                       ' --float 0', ... % double for internal computations
                       ' --output [' outputFilesPrefix ' , ' warpedVolume ']', ...
                       ' --interpolation BSpline[5]', ...
                       ' --winsorize-image-intensities [0.005,0.995]', ... %voxel outlier removal
                       ' --use-histogram-matching 0', ... %zero for accross modalities
                       '--initial-moving-transform [' moveFile ',' referenceFile ',1]']; %unsure

if rigidBody
    % default parameters:
    registrationCommand = [registrationCommand, ...
                            ' --transform Rigid[0.1]', ...
                            ' --metric MI[' moveFile ',' referenceFile ',1,32,Regular,0.25]', ...
                            ' --convergence [1000x500x250x100,1e-6,10]', ...
                            ' --shrink-factors 12x8x4x2', ...
                            ' --smoothing-sigmas 4x3x2x1vox'];
end
if affine 
    % default parameters:
    registrationCommand = [registrationCommand, ...
                            ' --transform Affine[0.1]', ...
                            ' --metric MI[' moveFile ',' referenceFile ',1,32,Regular,0.25]', ...
                            ' --convergence [1000x500x250x100,1e-6,10]', ...
                            ' --shrink-factors 12x8x4x2', ...
                            ' --smoothing-sigmas 4x3x2x1vox'];
end
if nonLinear
    registrationCommand = [registrationCommand, ...
                            ' --transform SyN', sprintf('[%f,%f,%f]', synParameters), ...
                            ' --metric CC[' moveFile ',' referenceFile ',1,4]', ...
                            ' --convergence [100x100x70x50x20,1e-6,10]', ...
                            ' --shrink-factors 10x6x4x2x1 ', ...
                            ' --smoothing-sigmas 5x3x2x1x0vox'];
end

%%
unix(registrationCommand);

end %end function













function voxelGrid = nonLinearRegistration(voxelGrid, verticesOld, verticesNew, configuration)
%NONLINEARREGISTRATION resamples the images using the shifted vertices.
%   VOLUME = NONLINEARREGISTRATION(VOLUME, VERTICESOLD, VERTICESNEW,{OPTIONS})
%   By creating a displacement field from the old and new vertices, the
%   original volume data is resampled. The displacement field is created by
%   means of a convolution of the vertex displacement by a Gaussian kernel.
%
%   Possible options:
%   option:                     default
%   'RegistrationDirection'     'xyz'
%
%   'RegistrationDirection' is the resample direction given by 'x', 'y',
%   'z' or any combination of these directions. 
%
%   Copyright (C) 2012-2013, Tim van Mourik, DCCN

if nargin < 4 
    configuration = [];
end

if ~isfield(configuration, 'RegistrationDirection')
    configuration.RegistrationDirection = 'xyz';
end
direction = configuration.RegistrationDirection;

if iscell(verticesOld)
    %concatenate vertices from both hemispheres
    verticesOld = vertcat(verticesOld{1}, verticesOld{2});
    verticesNew = vertcat(verticesNew{1}, verticesNew{2});
end

%% The gradient at the positions of the new vertices
gradient = verticesNew - verticesOld;
roundedVertices = round(verticesOld);
roundedVertices(roundedVertices(:, 1) > size(voxelGrid, 1) - 1, 1) = size(voxelGrid, 1) - 1;
roundedVertices(roundedVertices(:, 2) > size(voxelGrid, 2) - 1, 2) = size(voxelGrid, 2) - 1;
roundedVertices(roundedVertices(:, 3) > size(voxelGrid, 3) - 1, 3) = size(voxelGrid, 3) - 1;
roundedVertices(roundedVertices(:, 1) < 1, 1) = 1;
roundedVertices(roundedVertices(:, 2) < 1, 2) = 1;
roundedVertices(roundedVertices(:, 3) < 1, 3) = 1;

%% Create a normalised Gaussian kernel
x = normpdf(-10:2:10);
y = x;
z = x;
gaussianKernel = repmat(x' * y, [1, 1, size(x, 2)]);
for i = 1:size(x, 2)
    gaussianKernel(:, :, i) = gaussianKernel(:, :, i) * z(i);
end
gaussianKernel = gaussianKernel / sum(gaussianKernel(:));

%% Create the gradient field
gradientField = zeros([size(voxelGrid), 3]);
indices = sub2ind(size(voxelGrid), roundedVertices(:,1), roundedVertices(:,2), roundedVertices(:,3));
if any(direction == 'x')
    shiftsX = zeros(size(voxelGrid));
    shiftsX(indices) = gradient(:, 1);
    shiftsX = convn(shiftsX, gaussianKernel, 'same');
    gradientField(:, :, :, 1) = shiftsX;
end
if any(direction == 'y')
    shiftsY = zeros(size(voxelGrid));
    shiftsY(indices) = gradient(:, 2);
    shiftsY = convn(shiftsY, gaussianKernel, 'same');
    gradientField(:, :, :, 2) = shiftsY;
end
if any(direction == 'z')
    shiftsZ = zeros(size(voxelGrid));
    shiftsZ(indices) = gradient(:, 3);
    shiftsZ = convn(shiftsZ, gaussianKernel, 'same');
    gradientField(:, :, :, 3) = shiftsZ;
end

%% Resample by the volume data by means of the gradient field
indices = zeros([size(voxelGrid), 3]);
[x, y, z] = ind2sub(size(voxelGrid), 1:numel(voxelGrid));
indices(:) = [x, y, z]; 

sampleField = indices + gradientField;
sampleX = sampleField(:, :, :, 1);
sampleY = sampleField(:, :, :, 2);
sampleZ = sampleField(:, :, :, 3);

voxelGrid(:) = tvm_sampleVoxels(voxelGrid, [sampleX(:), sampleY(:), sampleZ(:)], {'InterpolationMethod', 'Trilinear'});

end %end function
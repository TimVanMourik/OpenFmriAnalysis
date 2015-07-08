function gradientField = makeGradientField(voxelGrid, verticesOld, verticesNew)
%MAKEGRADIENTFIELD produces a gradientfield, using the shifted vertices
%
%   Copyright (C) 2012-2013, Tim van Mourik, DCCN

% The gradient at the positions of the new vertices
gradient = verticesNew - verticesOld;
roundedVertices = round(verticesOld);
roundedVertices(roundedVertices(:, 1) > size(voxelGrid, 1) - 1, 1) = size(voxelGrid, 1) - 1;
roundedVertices(roundedVertices(:, 2) > size(voxelGrid, 2) - 1, 2) = size(voxelGrid, 2) - 1;
roundedVertices(roundedVertices(:, 3) > size(voxelGrid, 3) - 1, 3) = size(voxelGrid, 3) - 1;
roundedVertices(roundedVertices(:, 1) < 1, 1) = 1;
roundedVertices(roundedVertices(:, 2) < 1, 2) = 1;
roundedVertices(roundedVertices(:, 3) < 1, 3) = 1;

% Create a normalised Gaussian kernel
x = normpdf(-10:2:10);
y = x;
z = x;
gaussianKernel = repmat(x' * y, [1, 1, size(x, 2)]);
for i = 1:size(x, 2)
    gaussianKernel(:, :, i) = gaussianKernel(:, :, i) * z(i);
end
gaussianKernel = 1.7 * gaussianKernel / sum(gaussianKernel(:));

% Create the gradient field
gradientField = zeros([size(voxelGrid), 3]);
indices = sub2ind(size(voxelGrid), roundedVertices(:, 1), roundedVertices(:, 2), roundedVertices(:, 3));

shiftsX = zeros(size(voxelGrid));
shiftsX(indices) = gradient(:, 1);
shiftsX = convn(shiftsX, gaussianKernel, 'same');
gradientField(:, :, :, 1) = shiftsX;

shiftsY = zeros(size(voxelGrid));
shiftsY(indices) = gradient(:, 2);
shiftsY = convn(shiftsY, gaussianKernel, 'same');
gradientField(:, :, :, 2) = shiftsY;

shiftsZ = zeros(size(voxelGrid));
shiftsZ(indices) = gradient(:, 3);
shiftsZ = convn(shiftsZ, gaussianKernel, 'same');
gradientField(:, :, :, 3) = shiftsZ;

end %end function


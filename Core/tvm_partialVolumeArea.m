function distance = tvm_partialVolumeArea(distance, method, normals)
% The mode needs to be added as soon a different method is implementedy
% function distance = partialVolumeArea(distance, mode)
%
% The integral of a partial volume kernel from negative infinity to [input]
% Starting at zero, going to 1
%
% NB. distance is in voxels

switch method
    case 'rectangle'
        distance = distance + 1/2;
        distance(distance < 0) = 0;
        distance(distance > 1) = 1;
        
    case 'cubic'
        %% An approximation of a PVE kernel by means of a cubic function:
        %for      distance <= -1,   area = 0, 
        %for -1 < distance <= 0,    area = 0, 1 - 3 * x ^ 2 - 2 * x ^3
        %for  0 < distance <  1,    area = 0, 1 - 3 * x ^ 2 + 2 * x ^3
        %for      distance >= 1,    area = 0
        
        %first scale it to a kernel from -1 to 1
        distance = distance * 2 / sqrt(3);
        
        %for memory friendliness, the same array is returned. This creates
        %the necessity to be careful with the order of the operations.
        zeroIndices = distance == 0;
        
        distance(distance >= 1) = 1;
        distance(distance <= -1) = 0;
        
        indices = distance > 0  & distance < 1;
        distance(indices) = 1 / 2 + distance(indices) - distance(indices) .^ 3 + distance(indices) .^ 4 / 2;
        
        indices = distance > -1 & distance < 0;
        distance(indices) = 1 / 2 + distance(indices) - distance(indices) .^ 3 - distance(indices) .^ 4 / 2;
        
        distance(zeroIndices) = 1 /2;
        
    case 'gradient'
        if nargin < 3
            error('Please provide normals for the image');
        end
        %@todo make this properly N-dimensional
        sizeNormals = size(normals);
        sizeVolume = size(distance);
        numberOfVoxels = prod(sizeVolume(1:end - 1));
        assert(all(sizeNormals(1:end - 1) == sizeVolume(1:end - 1)));
        assert(sizeNormals(end) == 3, 'Normals need to have three dimensions'); %@todo to be expanded to N dimensions
        normals = abs(normals);
        
        normals = reshape(normals, [numberOfVoxels, sizeNormals(end)]);
        distance = reshape(distance, [numberOfVoxels, sizeVolume(end)]);
        
        % The normalisation factor can't handle NaNs, Infs and zeros
        epsilon = 0.001;
        noGradient = any(isnan(normals) | isinf(normals) | abs(normals) < epsilon, 2);
        distanceNoGradient = tvm_partialVolumeArea(distance(noGradient, :), 'cubic');
        
        kernelSize = sum(normals, 2);
        farDistance = bsxfun(@gt, distance,  kernelSize / 2);
        farBehind   = bsxfun(@lt, distance, -kernelSize / 2);
        distance = bsxfun(@plus, distance, kernelSize / 2);
        
        %% zeroth term
        cumulativeArea = distance .^ 3;
        
        %% single terms
        indices = find(bsxfun(@gt, distance, normals(:, 1)));
        normalIndices = mod(indices, numberOfVoxels);
        normalIndices(normalIndices == 0) = normalIndices(normalIndices == 0) + numberOfVoxels;
        cumulativeArea(indices) = cumulativeArea(indices) - (distance(indices) - normals(normalIndices, 1)) .^ 3;
        
        indices = find(bsxfun(@gt, distance, normals(:, 2)));
        normalIndices = mod(indices, numberOfVoxels);
        normalIndices(normalIndices == 0) = normalIndices(normalIndices == 0) + numberOfVoxels;
        cumulativeArea(indices) = cumulativeArea(indices) - (distance(indices) - normals(normalIndices, 2)) .^ 3;
        
        indices = find(bsxfun(@gt, distance,  normals(:, 3)));
        normalIndices = mod(indices, numberOfVoxels);
        normalIndices(normalIndices == 0) = normalIndices(normalIndices == 0) + numberOfVoxels;
        cumulativeArea(indices) = cumulativeArea(indices) - (distance(indices) - normals(normalIndices, 3)) .^ 3;
        
        %% double terms
        indices = find(bsxfun(@gt, distance,  normals(:, 1) + normals(:, 2)));
        normalIndices = mod(indices, numberOfVoxels);
        normalIndices(normalIndices == 0) = normalIndices(normalIndices == 0) + numberOfVoxels;
        cumulativeArea(indices) = cumulativeArea(indices) + (distance(indices) - normals(normalIndices, 1) - normals(normalIndices, 2)) .^ 3;
        
        indices = find(bsxfun(@gt, distance,  normals(:, 2) + normals(:, 3)));
        normalIndices = mod(indices, numberOfVoxels);
        normalIndices(normalIndices == 0) = normalIndices(normalIndices == 0) + numberOfVoxels;
        cumulativeArea(indices) = cumulativeArea(indices) + (distance(indices) - normals(normalIndices, 2) - normals(normalIndices, 3)) .^ 3;
        
        indices = find(bsxfun(@gt, distance,  normals(:, 3) + normals(:, 1)));
        normalIndices = mod(indices, numberOfVoxels);
        normalIndices(normalIndices == 0) = normalIndices(normalIndices == 0) + numberOfVoxels;
        cumulativeArea(indices) = cumulativeArea(indices) + (distance(indices) - normals(normalIndices, 3) - normals(normalIndices, 1)) .^ 3;
        
        %% triple terms
        indices = find(bsxfun(@gt, distance,  normals(:, 1) + normals(:, 2) + normals(:, 3)));
        normalIndices = mod(indices, numberOfVoxels);
        normalIndices(normalIndices == 0) = normalIndices(normalIndices == 0) + numberOfVoxels;
        cumulativeArea(indices) = cumulativeArea(indices) - (distance(indices) - normals(normalIndices, 1) - normals(normalIndices, 2) - normals(normalIndices, 3)) .^ 3;
        
        %% 
        normalisationFactor = 6 * prod(normals, 2);
        distance                = bsxfun(@rdivide, cumulativeArea, normalisationFactor);
        distance(farBehind)     = 0;
        distance(farDistance)   = 1;
        distance(noGradient, :) = distanceNoGradient;
        distance = reshape(distance, sizeVolume);
end

end %end function


function test %#ok<DEFNU>
%%
ph = 0:pi/32:pi;
th = 0:pi/32:2*pi;
[phi, theta] = meshgrid(ph, th);

x = cos(phi(:)) .* cos(theta(:));
y = sin(phi(:)) .* cos(theta(:));
z = sin(theta(:));

gradient = [x, y, z];
gradient = repmat(gradient, [2, 1]);
r = -1:0.01:1;
figure();
plot(r, tvm_partialVolumeArea(repmat(r, [size(gradient, 1), 1]), 'gradient', gradient));
figure();
plot(r, tvm_partialVolumeArea(repmat(r, [size(gradient, 1), 1]), 'rectangle', gradient));
figure();
plot(r, tvm_partialVolumeArea(repmat(r, [size(gradient, 1), 1]), 'cubic', gradient));



end %end function





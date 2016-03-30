function coordinates = tvm_getBokCoordinates(coordinatesW, coordinatesP, curvature, volumeFraction, normals, thickness)
%GETBOKCOORDINATES finds interpolated coordinates between two surfaces,
%given a certain curvature (Bok, 1929)
%   COORDINATES = GETBOKCOORDINATES(ARRAYW, ARRAYP, CURV, VOLUMEDRACTION, NORMALS, THICKNESS)
%   ARRAYW the primary boundary [N x 3] or [N x 4]
%   ARRAYP the secondary boundary [N x 3] or [N x 4]
%   CURV is the curvature at ARRAYW [N x 1]
%   VOLUMEDRACTION is a vector of fractions 0 <= f <= 1 that indicates at
%   which volume fraction the required layer had to be. 
%
%   The returned matrix contains the COORDINATES of the layers at the
%   requested volume fraction. Its size will be [size(ARRAYW) x length(VOLUMEFRACTION)]

if nargin < 6
    thickness = findThickness(coordinatesW, coordinatesP);
end
if nargin < 5
    normals = findNormals(coordinatesW, coordinatesP);
end

numberOfSurfaces = length(volumeFraction);

numberOfVertices = size(coordinatesW, 1);

%threshold below which equidistant sampling will be used
%WATCH OUT, FreeSurfer's convention differs with a minus sign from the code
%below, so if FreeSurfer curvatures are used, add a minus sign to it.
R = 1 ./ curvature; 
thresholdCurvature = 0.01;
R(abs(curvature) < thresholdCurvature) = 0;

%list of all volume percentages
% volumePercentage = -extraSampling:(1 + 2 * extraSampling) / (numberOfSurfaces - 1): 1 + extraSampling; 
volumePercentage = volumeFraction; 

%three different cases need to be treated separately: positive, negative
%and zero curvature
radiusPositive = R > 0;
radiusNegative = R < 0;
radiusZero = R == 0;

coordinates = zeros(numberOfVertices * numberOfSurfaces, size(coordinatesW, 2));

%for the positive radius
if any(radiusPositive)
    %volume preservation function:
    rCubed = bsxfun(@plus, bsxfun(@times, repmat(volumePercentage, sum(radiusPositive), 1), (R(radiusPositive) + thickness(radiusPositive)) .^ 3 - R(radiusPositive) .^ 3), R(radiusPositive) .^ 3);
    r = bsxfun(@minus, nthroot(rCubed, 3), R(radiusPositive)); %in percentage times thickness
    samplingCoordinatesPositive = repmat(coordinatesW(radiusPositive, :), [numberOfSurfaces, 1]) + bsxfun(@times, r(:), repmat(normals(radiusPositive, :), [numberOfSurfaces, 1]));
    radiusPositive = repmat(find(radiusPositive), [1, numberOfSurfaces]) + repmat(0:numberOfVertices:(numberOfSurfaces - 1) * numberOfVertices, sum(radiusPositive), 1);
    coordinates(radiusPositive(:), :) = samplingCoordinatesPositive;
end

%for the negative radius
if any(radiusNegative)
    %volume preservation function:
    rCubed = bsxfun(@plus, bsxfun(@times, repmat(volumePercentage, sum(radiusNegative), 1), (thickness(radiusNegative) - R(radiusNegative)) .^ 3 + R(radiusNegative) .^ 3), -R(radiusNegative) .^ 3);
    r = fliplr(bsxfun(@plus, nthroot(rCubed, 3), R(radiusNegative))); %in percentage times thickness
    samplingCoordinatesNegative = repmat(coordinatesP(radiusNegative, :), [numberOfSurfaces, 1]) - bsxfun(@times, r(:), repmat(normals(radiusNegative, :), [numberOfSurfaces, 1]));
    radiusNegative = repmat(find(radiusNegative), [1, numberOfSurfaces]) + repmat(0:numberOfVertices:(numberOfSurfaces - 1) * numberOfVertices, sum(radiusNegative), 1);
    coordinates(radiusNegative(:), :) = samplingCoordinatesNegative;
end

%for no curvature
if any(radiusZero)
    %equidistant sampling
    T = thickness(radiusZero) * volumePercentage;
    samplingCoordinatesZero = repmat(coordinatesW(radiusZero, :), [numberOfSurfaces, 1]) + bsxfun(@times, T(:), repmat(normals(radiusZero, :), [numberOfSurfaces, 1]));
    radiusZero = repmat(find(radiusZero), [1, numberOfSurfaces]) + repmat(0:numberOfVertices:(numberOfSurfaces - 1) * numberOfVertices, sum(radiusZero), 1);
    coordinates(radiusZero(:), :) = samplingCoordinatesZero;
end

coordinates = reshape(coordinates, [numberOfVertices, numberOfSurfaces, size(coordinatesW, 2)]);
coordinates = permute(coordinates, [1, 3, 2]);

end %end function




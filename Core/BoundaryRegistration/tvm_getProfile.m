function profiles = tvm_getProfile(arrayW, arrayP, volume, configuration)
%GETPROFILE gets an intensity profile around and in between two vertices
%   P = GETPROFILE(A1, A2, VOLUME, CFG)
%   The profile P is produces from the input arrays of vertices A1 and A2.
%   The profile is computed in the input VOLUME.
%   The length of the profile is given by CFG.Steps
%   CFG.Steps = 300;
%
%   Copyright (C) 2012-2013, Tim van Mourik, DCCN

if nargin < 4
    configuration =[];
end

numberOfSteps = tvm_getOption(configuration, 'Steps', 301);
bok = tvm_getOption(configuration, 'Bok', false);
extraSampling = tvm_getOption(configuration, 'OutsideGreyMatter', 0);

thickness = findThickness(arrayW, arrayP);
normals = findNormals(arrayW, arrayP);

if bok
    curvature = configuration.Curvature;
    coordinates = getBokCoordinates(arrayW, arrayP, curvature, numberOfSteps, normals, thickness, extraSampling);
    coordinates = permute(coordinates, [1, 3, 2]);
    coordinates = reshape(coordinates, [size(arrayW, 1) *  numberOfSteps, 4]);
else
    %From the middle points, sample 1.5 thickness to the right and 1.5
    %thickneses to the left in equal steps.
    locationsMiddle  = (arrayW + arrayP) / 2;
    steps  = repmat((-0.5 - extraSampling):((1 + 2 * extraSampling) / (numberOfSteps - 1)):(0.5 + extraSampling), [length(arrayW), 1]);
    offset = repmat(bsxfun(@times, normals, thickness), [numberOfSteps, 1]);
    offset = bsxfun(@times, offset, steps(:));

    coordinates = repmat(locationsMiddle, [numberOfSteps, 1]) + offset;
end

profiles = zeros(length(arrayW), numberOfSteps);
profiles(:) = tvm_sampleVoxels(volume, coordinates(:, 1:3), configuration);


end %end function
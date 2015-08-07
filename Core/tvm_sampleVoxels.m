function voxelValues = tvm_sampleVoxels(voxelgrid, x, y, z, configuration)
%SAMPLEVOXELS Gives the voxel values for an input array of coordinates
%   V = SAMPLEVOXELS(VOXELGRID, X, Y, Z)
%   The method uses linear interpolation to come to the right voxel values
%   in V, given a list of coordinates X, Y, Z.
%   All error checking has been removed from this file, because the speed of
%   this file is the limiting factor for the  whole program
%
%   Copyright (C) 2012-2013, Tim van Mourik, DCCN
% @todo, implement other sampling methods, e.g. http://paulbourke.net/miscellaneous/interpolation

%% Parse configuration
if nargin < 5
    configuration = [];
end

interpolationMethod = tvm_getOption(configuration, 'InterpolationMethod', 'Trilinear');

%%
%preallocate output
voxelValues = nan(size(x));

switch interpolationMethod
    case 'Trilinear'
        %the integer parts of the coordinates
        allValues = [x, y, z];
        integerParts = floor(allValues);

        insideVolume = ~any(integerParts < 1 | bsxfun(@gt, integerParts, size(voxelgrid) - 1), 2);
        %Makes sure that the integer part are larger than 0...

        integerParts = integerParts(insideVolume, :);
        %The decimal parts on all sidesof the voxel
        decimalParts = allValues(insideVolume, :) - integerParts;
        oneMinusDecimal = 1 - decimalParts;

        %interpolates the voxels
        s = size(voxelgrid);
        voxelValues(insideVolume) = voxelgrid(sub2ind(s, integerParts(:, 1)    , integerParts(:, 2)    , integerParts(:, 3))) .*     oneMinusDecimal(:, 1) .* oneMinusDecimal(:, 2) .* oneMinusDecimal(:, 3) + ...
                                    voxelgrid(sub2ind(s, integerParts(:, 1)    , integerParts(:, 2)    , integerParts(:, 3) + 1)) .* oneMinusDecimal(:, 1) .* oneMinusDecimal(:, 2) .* decimalParts(:, 3)    + ...
                                    voxelgrid(sub2ind(s, integerParts(:, 1)    , integerParts(:, 2) + 1, integerParts(:, 3))) .*     oneMinusDecimal(:, 1) .* decimalParts(:, 2) .*    oneMinusDecimal(:, 3) + ...
                                    voxelgrid(sub2ind(s, integerParts(:, 1)    , integerParts(:, 2) + 1, integerParts(:, 3) + 1)) .* oneMinusDecimal(:, 1) .* decimalParts(:, 2) .*    decimalParts(:, 3)    + ...
                                    voxelgrid(sub2ind(s, integerParts(:, 1) + 1, integerParts(:, 2)    , integerParts(:, 3))) .*     decimalParts(:, 1) .*    oneMinusDecimal(:, 2) .* oneMinusDecimal(:, 3) + ...
                                    voxelgrid(sub2ind(s, integerParts(:, 1) + 1, integerParts(:, 2)    , integerParts(:, 3) + 1)) .* decimalParts(:, 1) .*    oneMinusDecimal(:, 2) .* decimalParts(:, 3)    + ...
                                    voxelgrid(sub2ind(s, integerParts(:, 1) + 1, integerParts(:, 2) + 1, integerParts(:, 3))) .*     decimalParts(:, 1) .*    decimalParts(:, 2) .*    oneMinusDecimal(:, 3) + ...
                                    voxelgrid(sub2ind(s, integerParts(:, 1) + 1, integerParts(:, 2) + 1, integerParts(:, 3) + 1)) .* decimalParts(:, 1) .*    decimalParts(:, 2) .*    decimalParts(:, 3);

                                %No need for setting the rest to NaN, as it was NaN-preallocated
%         voxelValues(~insideVolume) = NaN;
    case 'NearestNeighbour'
        %Roughly 4 times faster than 'Trilinear'
        %the integer parts of the coordinates
        nearestNeighbours = round([x, y, z]);
        insideVolume = ~any(nearestNeighbours < 1 | bsxfun(@gt, nearestNeighbours, size(voxelgrid)), 2);

        %interpolates the voxels
        voxelValues(insideVolume) = voxelgrid(sub2ind(size(voxelgrid), nearestNeighbours(insideVolume, 1), nearestNeighbours(insideVolume, 2), nearestNeighbours(insideVolume, 3)));

        %No need for setting the rest to NaN, as it was NaN-preallocated
%         voxelValues(~insideVolume) = NaN;
    otherwise
        error('TVM:voxelInterpolate:InvalidMode','The given interpolation method is invalid');
end

end % end function













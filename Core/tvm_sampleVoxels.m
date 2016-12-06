function voxelValues = tvm_sampleVoxels(voxelgrid, coordinates, configuration)
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
voxelValues = nan([size(coordinates, 1), 1]);

switch interpolationMethod
    case 'Trilinear'
        %the integer parts of the coordinates
        integerParts = floor(coordinates);

        volumeSize = size(voxelgrid);
        insideVolume = ~any(integerParts < 1 | bsxfun(@gt, integerParts, volumeSize(1:3) - 1) | isnan(integerParts), 2);
        %Makes sure that the integer part are larger than 0...
        if ~any(insideVolume)
            return
%             error('None of the sampled voxels are inside the volume');
        end

        integerParts = integerParts(insideVolume, :);
        %The decimal parts on all sidesof the voxel
        decimalParts = coordinates(insideVolume, :) - integerParts;
        oneMinusDecimal = 1 - decimalParts;
        
        if length(volumeSize) == 4 %4D file
            index4D         = repmat(1:volumeSize(4), [sum(insideVolume), 1]);
            index4D         = index4D(:);
            insideVolume    = repmat(insideVolume, [volumeSize(4), 1]);
            integerParts    = repmat(integerParts, [volumeSize(4), 1]);
            decimalParts    = repmat(decimalParts, [volumeSize(4), 1]);
            oneMinusDecimal = repmat(oneMinusDecimal, [volumeSize(4), 1]);
            voxelValues     = repmat(voxelValues, [1, volumeSize(4)]);
        else
            index4D         = ones([sum(insideVolume), 1]);
        end

        %interpolates the voxels
        voxelValues(insideVolume) = voxelgrid(sub2ind(volumeSize, integerParts(:, 1)    , integerParts(:, 2)    , integerParts(:, 3)        , index4D)) .* oneMinusDecimal(:, 1) .* oneMinusDecimal(:, 2) .* oneMinusDecimal(:, 3) + ...
                                    voxelgrid(sub2ind(volumeSize, integerParts(:, 1)    , integerParts(:, 2)    , integerParts(:, 3) + 1    , index4D)) .* oneMinusDecimal(:, 1) .* oneMinusDecimal(:, 2) .* decimalParts(:, 3)    + ...
                                    voxelgrid(sub2ind(volumeSize, integerParts(:, 1)    , integerParts(:, 2) + 1, integerParts(:, 3)        , index4D)) .* oneMinusDecimal(:, 1) .* decimalParts(:, 2) .*    oneMinusDecimal(:, 3) + ...
                                    voxelgrid(sub2ind(volumeSize, integerParts(:, 1)    , integerParts(:, 2) + 1, integerParts(:, 3) + 1    , index4D)) .* oneMinusDecimal(:, 1) .* decimalParts(:, 2) .*    decimalParts(:, 3)    + ...
                                    voxelgrid(sub2ind(volumeSize, integerParts(:, 1) + 1, integerParts(:, 2)    , integerParts(:, 3)        , index4D)) .* decimalParts(:, 1) .*    oneMinusDecimal(:, 2) .* oneMinusDecimal(:, 3) + ...
                                    voxelgrid(sub2ind(volumeSize, integerParts(:, 1) + 1, integerParts(:, 2)    , integerParts(:, 3) + 1    , index4D)) .* decimalParts(:, 1) .*    oneMinusDecimal(:, 2) .* decimalParts(:, 3)    + ...
                                    voxelgrid(sub2ind(volumeSize, integerParts(:, 1) + 1, integerParts(:, 2) + 1, integerParts(:, 3)        , index4D)) .* decimalParts(:, 1) .*    decimalParts(:, 2) .*    oneMinusDecimal(:, 3) + ...
                                    voxelgrid(sub2ind(volumeSize, integerParts(:, 1) + 1, integerParts(:, 2) + 1, integerParts(:, 3) + 1    , index4D)) .* decimalParts(:, 1) .*    decimalParts(:, 2) .*    decimalParts(:, 3);

                                %No need for setting the rest to NaN, as it was NaN-preallocated
%         voxelValues(~insideVolume) = NaN;
    case 'NearestNeighbour'
        %Roughly 4 times faster than 'Trilinear'
        %the integer parts of the coordinates
        nearestNeighbours = round(coordinates);
        insideVolume = ~any(nearestNeighbours < 1 | bsxfun(@gt, nearestNeighbours, size(voxelgrid)), 2);

        %interpolates the voxels
        voxelValues(insideVolume) = voxelgrid(sub2ind(size(voxelgrid), nearestNeighbours(insideVolume, 1), nearestNeighbours(insideVolume, 2), nearestNeighbours(insideVolume, 3)), :);

        %No need for setting the rest to NaN, as it was NaN-preallocated
%         voxelValues(~insideVolume) = NaN;
    otherwise
        error('TVM:voxelInterpolate:InvalidMode','The given interpolation method is invalid');
end

end % end function













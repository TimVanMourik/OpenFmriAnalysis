function [coordinates, withinRange] = withinRange(dimensions, coordinates)
%SAMPLEVOXELS Gives the voxel values for an input array of coordinates
%   Copyright (C) 2012-2014, Tim van Mourik, DCCN

x = coordinates(:, 1);
y = coordinates(:, 2);
z = coordinates(:, 3);

%the dimensions of the volume
xMax = dimensions(1);
yMax = dimensions(2);
zMax = dimensions(3);

%outside the volume
outsideRange = x < 1 |  y < 1 |  z < 1 | x > xMax | y > yMax | z > zMax;
withinRange = ~outsideRange;

coordinates = coordinates(withinRange, :);

end % end function


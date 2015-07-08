function normals = findNormals(array1, array2)
%FINDNORMALS Finds the vertex normals
%   N = FINDNORMALS(INNERBOUNDARY, OUTERBOUNDARY) 
%   Given two N-dimensional
%   arrays of equal size, INNERBOUNDARY and OUTERBOUNDARY, the normals N
%   between all points are computed
%
%   Copyright (C) 2012-2013, Tim van Mourik, DCCN

if nargin < 2
    error(message('MATLAB:findnormals:NoInputs'))
end

%subtracting the one from the other
normals = array2 - array1;

%In case of homogeneous coordinates, makes sure that the last column is
%zero (even though this should be the case with proper input)
if size(array1, 2) == 4
    normals(:, 4) = 0;
end

%normalising the new data
%First compute the squared length of the vector
sums = sqrt(sum(normals(:, 1:3) .^ 2, 2));

%Divide by the squared sum
for i = 1:3
    normals(:, i) = normals(:, i) ./ sums;
end

%All divisions by zero yield NaN. If NaN, then the normal is set to 0
normals(normals ~= normals) = 0;

end %end function

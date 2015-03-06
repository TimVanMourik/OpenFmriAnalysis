function thickness = findThickness(array1, array2)
%FINDTHICKNESS Computes the thickness between to arrays
%   T = FINDTHICKNESS(INNERBOUNDARY, OUTERBOUNDARY)
%   Given two N-dimensional arrays of equal size, the normals between all
%   points are computed
%
%   Copyright (C) 2012-2013, Tim van Mourik, DCCN

if nargin < 2
    error(message('MATLAB:findThickness:NoInputs'))
end

difference = array1 - array2;
%long live Pythagoras
thickness = sqrt(sum(difference .^ 2, 2));

end %end function
function array = normalise(array)
%NORMALISE Normalises a vector
%   NORMAL = NORMALISE(ARRAY)
%   Given an N x M matrix, the vector is normalised
%
%   Copyright (C) 2012-2013, Tim van Mourik, DCCN

sums = sqrt(sum(array .^ 2, 2));

%Divide by the squared sum
for i = 1:size(array, 2);
    array(:, i) = array(:, i) ./ sums;
end

%All zero by zero divisions yield NaN. If NaN, then the normal is set to 0
array(array ~= array) = 0;

end %end function

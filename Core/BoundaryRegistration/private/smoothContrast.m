function c = smoothContrast(contrast, neighbours, influenceNeighbours)
%SMOOTHCONTRAST Given an array with contrast values and the neighbours of all vertices,
%the contrast is smoothened
%   CO = SMOOTHCONTRAST(CI, NEIGHBOURS, INFLUENCE)
%   A weighted average of the input contrast CI is returned, using the
%   NEIGHBOURS and given an INFLUENCE.
%
%   Copyright (C) 2012-2013, Tim van Mourik, DCCN
 
if nargin < 3
    error('TVM:smoothcontrast:NoInputs',['No input arguments specified. ' ...
            'There should be exactly three input arguments.'])
end

%error checking and returning the number of vertices
l = length(neighbours);
s = size(contrast);
if ~(s(1) == l && s(2) == 1)
    error('TVM:smoothcontrast:InvalidInput','sizes of the input do not match')
end

c = zeros(l, 1);
for i = 1:l
   neighbourInfo =  neighbours(i);
   c(i) = (1 - influenceNeighbours) * contrast(i);
   for j = 1:(neighbourInfo{1}(1))
       weight = influenceNeighbours / neighbourInfo{1}(1);
       c(i) = c(i) + weight * contrast(neighbourInfo{1}(j + 1));
   end
end

end %end function

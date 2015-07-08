function mesh = smoothMesh(array, neighbours, influenceNeighbours)
%SMOOTHNESS Smoothens the mesh
%   O = SMOOTHMESH(I, NEIGHBOURS, INFLUENCE)
%   Smoothens an array of vertices I by using the positions of its
%   NEIGHBOURS, given a certain INFLUENCE between 0 and 1
%
%   Copyright (C) 2012-2013, Tim van Mourik, DCCN

if nargin < 3
    error('TVM:smoothMesh:NoInputs','No input arguments specified. There should be exactly three input arguments.')
end
l = length(neighbours);
s = size(array);
if ~(s(1) == l && (s(2) == 3 || s(2) == 4))
    error('TVM:smoothcontrast:InvalidInput','sizes of the input do not match')
end

mesh = (1 - influenceNeighbours) * array;
for i = 1:l
   neighbourInfo =  neighbours(i);
   for j = 1:(neighbourInfo{1}(1))
       weight = influenceNeighbours / neighbourInfo{1}(1);
       mesh(i, :) = mesh(i, :) + weight * array(neighbourInfo{1}(j + 1), :);
   end
end
if size(array, 2) == 4
    mesh(:, 4) = 1;
end


end %end function

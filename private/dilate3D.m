function data_in = dilate3D(data_in, radius)

if nargin < 2
    radius = 1;
end
R = ones(1, radius);
dimension = [3, 1, 2];
data_in = permute(imdilate(data_in, R), dimension);
data_in = permute(imdilate(data_in, R), dimension);
data_in = permute(imdilate(data_in, R), dimension);

end %end function

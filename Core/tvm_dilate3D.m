function data = tvm_dilate3D(data, radius)

if nargin < 2
    radius = 1;
end
R = ones(1, radius);
dimension = [3, 1, 2];
data = permute(imdilate(data, R), dimension);
data = permute(imdilate(data, R), dimension);
data = permute(imdilate(data, R), dimension);

end %end function

function mesh = transformMesh(mesh, rotation, scaling, translation, pivot)

if nargin < 2
    rotation = [0, 0, 0];
end
if nargin < 3
    scaling = [0, 0, 0];
end
if nargin < 4
    translation = [0, 0, 0];
end
if nargin < 5
    pivot = [0, 0, 0];
end

transformationMatrix = tvm_toMatrixRSTP(rotation, scaling, translation, pivot);
mesh = mesh * transformationMatrix;

end %end function

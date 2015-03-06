function matrix = tvm_dimensionsToFreesurferMatrix(voxelDimensions, numberOfVoxels)
% TVM_DIMENSIONSTOFREESURFERMATRIX 
%   TVM_DIMENSIONSTOFREESURFERMATRIX(dimension, numberOfVoxels)
%   
%
%   Copyright (C) Tim van Mourik, 2014, DCCN
%

%%
matrix =     [-voxelDimensions(1), 0,                   0,                   voxelDimensions(1) * numberOfVoxels(1) / 2;
              0,                   0,                   voxelDimensions(3), -voxelDimensions(3) * numberOfVoxels(3) / 2;
              0,                   -voxelDimensions(2), 0,                   voxelDimensions(2) * numberOfVoxels(2) / 2;
              0,                   0,                   0,                   1];

end %end function


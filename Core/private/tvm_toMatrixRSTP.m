function transformationMatrix = tvm_toMatrixRSTP(rotation, scaling, translation, pivot)
% RSTP = rotation, scaling, translation, all with respect to the pivot
%
% (C) Tim van MOurik 2015

%sets a rotation matrix, scaling matrix and translation matrix
pivotMatrixNegative = tvm_pivotChangeToMatrix(-pivot);
rotationMatrix      = tvm_toRotationMatrix(rotation);
scalingMatrix       = tvm_toScalingMatrix(scaling);
translationMatrix   = tvm_toTranslationMatrix(translation);
pivotMatrix         = tvm_pivotChangeToMatrix(pivot);

%the transformation matrix is the multiplication of the three
transformationMatrix = pivotMatrixNegative * rotationMatrix * scalingMatrix * translationMatrix * pivotMatrix;

end %end function
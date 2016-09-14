function [newMatrix, newDimensions] = tvm_getResampledMatrix(oldMatrix, oldDimensions, resampleFactor)

%@todo this is totally wrong, but at least it sets the dimensions right.
newMatrix = oldMatrix * spm_matrix([0, 0, 0, ...
                        0, 0, 0, ...
                        resampleFactor, resampleFactor, resampleFactor, ...
                        0, 0, 0]);

newDimensions = oldDimensions / resampleFactor;
return


resampleMatrix = eye(4);
resampleMatrix([1, 6, 11]) = resampleFactor;
shiftByHalf = [1, 0, 0, 1/2; 0, 1, 0, 1/2; 0, 0, 1, 1/2; 0, 0, 0, 1];

% load transformation information
oldTransformation       = reshape(spm_imatrix(oldMatrix), [3, 4]);

% convert transformation in seperate transformations
translation = oldTransformation(:, 1)';
rotation    = oldTransformation(:, 2)';
scale       = oldTransformation(:, 3)';
shear       = oldTransformation(:, 4)';

% these are the inner/outer points of the described box
x0 = translation - scale / 2;
x1 = oldDimensions .* scale + x0;

% these are the new dimensions...
newDimensions   = oldDimensions * upsampleFactor;
newScale        = scale / upsampleFactor;
newTranslation  = (x1 - x0) / 2 - newScale / 2;

% ...that make the new matrix
newMatrix = spm_matrix([newTranslation, ...
                        rotation, ...
                        newScale, ...
                        shear]) / shiftByHalf ^ 2;

end %end function











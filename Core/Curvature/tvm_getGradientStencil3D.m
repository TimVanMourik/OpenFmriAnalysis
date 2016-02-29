function fullStencil3D = tvm_getGradientStencil3D(order, a, b, c)

%These are the weights for the cross terms (Kowalczyk & Van Walstijn 2011)
if nargin < 2
    a = 1;
    b = 0;
    c = 0;
end
% order should be an even number
h           = 1;
dx          = order * h / 2;
midPoint    = order / 2 + 1;

%% 1D
coefficients    = repmat(0:order  , [order + 1, 1]);
coefficients    = coefficients' .^ coefficients;
invX            = diag(1 ./ (repmat(h, [1, order + 1]) .^ (0:order)));
invM            = invX / coefficients;

% derivative
xPart   = diag((0:order) .* repmat(dx, [1, order + 1]) .^ [1, 0:(order - 1)]);
GPrime  = xPart * invM;
derivative1D = ones(1, order + 1) * GPrime;

%% 2D
stencilCrossTerms2D = derivative1D' * derivative1D;

%% 3D
stencilSingleTerms3D = zeros(order + 1, order + 1, order + 1);
stencilSingleTerms3D(:, midPoint, midPoint) = derivative1D;
stencilSingleTerms3D(midPoint, :, midPoint) = derivative1D;
stencilSingleTerms3D(midPoint, midPoint, :) = derivative1D;

stencilCrossTerms3D = zeros(order + 1, order + 1, order + 1);
stencilCrossTerms3D(midPoint, :, :) = stencilCrossTerms2D;
stencilCrossTerms3D(:, midPoint, :) = stencilCrossTerms2D;
stencilCrossTerms3D(:, :, midPoint) = stencilCrossTerms2D;

stencilTripleTerms3D = zeros(order + 1, order + 1, order + 1);
[x,y,z] = meshgrid(1:order + 1, 1:order + 1, 1:order + 1);
entries = derivative1D(x(:)) .* derivative1D(y(:)) .* derivative1D(z(:));
stencilTripleTerms3D(:) = entries(:);

fullStencil3D = a * stencilSingleTerms3D + b * stencilCrossTerms3D + c * stencilTripleTerms3D;

end %end function
function fullStencil2D = tvm_getGradientStencil2D(order)

% order should be an even number
h           = 1;
dx          = order * h / 2;
midPoint    = order / 2 + 1;

%% 1D
coefficients    = repmat(0:order  , [order + 1, 1]);
coefficients    = coefficients' .^ coefficientsa;
invX            = diag(1 ./ (repmat(h, [1, order + 1]) .^ (0:order)));
invM            = invX / coefficients;

% derivative
xPart   = diag((0:order) .* repmat(dx, [1, order + 1]) .^ [1, 0:(order - 1)]);
GPrime  = xPart * invM;
derivative1D = ones(1, order + 1) * GPrime;

%% 2D
stencilSingleTerms2D = zeros(order + 1, order + 1);
stencilSingleTerms2D(midPoint, :) = derivative1D;
stencilSingleTerms2D(:, midPoint) = derivative1D;
stencilCrossTerms2D = derivative1D' * derivative1D;

a = 1/2;
b = 1/2;
% 
fullStencil2D = a * stencilSingleTerms2D + b * stencilCrossTerms2D;

end %end function
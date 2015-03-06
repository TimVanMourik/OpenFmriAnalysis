function matrix = tvm_toRotationMatrix(rotation)
%sets the rotation angles
alpha = rotation(1);
beta  = rotation(2);
gamma = rotation(3);

%computes the sine and cosine of the angle
sinAlpha = sin(alpha);
sinBeta  = sin(beta);
sinGamma = sin(gamma);
cosAlpha = cos(alpha);
cosBeta  = cos(beta);
cosGamma = cos(gamma);

matrix =    [cosBeta * cosGamma, cosGamma * sinAlpha * sinBeta + cosAlpha * sinGamma, -cosAlpha * cosGamma * sinBeta + sinAlpha * sinGamma, 0; ...
             -cosAlpha * sinGamma, cosAlpha * cosGamma - sinAlpha * sinBeta * sinGamma, cosGamma * sinAlpha + cosAlpha * sinBeta * sinGamma, 0; ...
             sinBeta, -cosBeta * sinAlpha, cosAlpha * cosBeta, 0; ...
             0, 0, 0, 1];
end
function filter = tvm_getGradientFilter3D(order)

[x,y,z] = meshgrid(-order / 2:order / 2, -order / 2:order / 2, -order / 2:order / 2);
phi     = atan(y ./ x);
theta   = acos(z ./ sqrt(x .^ 2 + y .^ 2 + z .^ 2));

% a filter for all three dimensions 
filter = zeros(order + 1, order + 1, order + 1, 3);
filter(:, :, :, 1)      = sin(theta) .* sin(phi);
filter(:, :, :, 2)      = sin(theta) .* cos(phi);
filter(:, :, :, 3)      = cos(theta);

filter = abs(filter);
filter(isnan(filter)) = 0;

end %end function
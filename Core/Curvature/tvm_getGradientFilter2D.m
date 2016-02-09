function filter = tvm_getGradientFilter2D(order)

[x,y] = meshgrid(-order / 2:order / 2, -order / 2:order / 2);
phi     = atan(y ./ x);

% a filter for all three dimensions 
filter = zeros(order + 1, order + 1, order + 1, 2);
filter(:, :, :, 1)      = sin(phi);
filter(:, :, :, 2)      = cos(phi);

filter = abs(filter);
filter(isnan(filter)) = 0;

end %end function
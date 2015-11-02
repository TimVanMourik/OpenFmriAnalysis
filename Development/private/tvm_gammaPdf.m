function f = tvm_gammaPdf(x, k, theta)

% f = 1 ./ (gamma(k) .* theta .^ k) .* x .^ (k - 1) .* exp(-x ./ theta);
f = exp((k-1) .* log(x) + k .* log(theta) - theta .* x - gammaln(k));

end %end function

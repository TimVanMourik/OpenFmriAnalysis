function hrfValue = tvm_hrf(timePoints, p, durations)

if nargin < 3
    hrfValue = tvm_gammaPdf(timePoints, p(1) / p(3), 1 / p(3)) - tvm_gammaPdf(timePoints, p(2) / p(4), 1 / p(4)) / p(5);
    return
end

post = gamcdf(timePoints, p(1) / p(3), 1 / p(3)) - gamcdf(timePoints, p(2) / p(4), 1 / p(4)) / p(5);
pre  = gamcdf(timePoints - durations, p(1) / p(3), 1 / p(3)) - gamcdf(timePoints - durations, p(2) / p(4), 1 / p(4)) / p(5);
hrfValue = post - pre;

end %end function


function f = tvm_gammaPdf(x, k, theta)

%both are identical (to each other and to gampdf() ), but the first one is
%faster. Gampdf is rewritten as it is in the stats toolbox.
f = exp((k-1) .* log(x) + k .* log(theta) - theta .* x - gammaln(k));
% f = 1 ./ (gamma(k) .* theta .^ k) .* x .^ (k - 1) .* exp(-x ./ theta);

end %end function



function f = tvm_gammaCdf(x, durations, k, theta)
% @todo write a cumulative gamma function, such that the stats toolbox does
% not need to be used. 

% f = exp((k-1) .* log(x) + k .* log(theta) - theta .* x - gammaln(k));

end %end function





function f = tvm_gammaCdf(x, k, theta)
% the integral of the Gamma function is the incomplete upper gamma function 

f = 1 - gammainc(x .* theta, k, 'upper');

end %end function

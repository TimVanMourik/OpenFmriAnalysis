function hrfValue = tvm_hrf(timePoints, p)

hrfValue = spm_Gpdf(timePoints, p(1) / p(3), 1 / p(3)) - spm_Gpdf(timePoints, p(2) / p(4), 1 / p(4)) / p(5);

end %end function
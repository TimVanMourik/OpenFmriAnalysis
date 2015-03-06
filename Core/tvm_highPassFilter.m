function timecourses = tvm_highPassFilter(timecourses, TR, cutOff)
%TVM_HIGHPASSFILTER 
%	F = TVM_HIGHPASSFILTER(DATA, TR, U)
%   DATA = [timepoints X voxels]
%   Copyright (C) 2013, Tim van Mourik, DCCN

[numberOfTimepoints, numberOfVoxels]= size(timecourses);
if mod(numberOfTimepoints, 2) == 0
    frequencies = [0:(numberOfTimepoints / 2), (numberOfTimepoints / 2 - 1):-1:1]';
else
    frequencies = [0:((numberOfTimepoints - 1) / 2), ((numberOfTimepoints - 1) / 2):-1:1]';
end
frequencies = frequencies / (max(frequencies) * 2 * TR);
filter = zeros(size(frequencies));
filter(frequencies >= cutOff) = 1;
filter(1) = 1;
filter = repmat(filter, [1, numberOfVoxels]);

timecourses = fft(timecourses, [], 1);
timecourses = timecourses .* filter;
timecourses = real(ifft(timecourses, [], 1));

end %end function
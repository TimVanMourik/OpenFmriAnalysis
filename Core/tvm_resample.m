function outputMatrix = tvm_resample(inputMatrix, outputSize, isReal)
%
% updownsample - up-sample or down-sample an input series using fourier domain
%                input series needs to be continuous of a high degree
%
% format:   out_m = updownsample( in_m,out_x_sz,out_y_sz,is_fourier_flag,is_real_flag )
%
% input:    in_m                - input matrix for up/down sampling. can be in
%                                 space domain OR in fourier domain, in such
%                                 case, needs to be in matlab format !!!
%                                 (matlab-format = the save as given from fft/fft2)
%           out_x_sz,out_y_sz   - desired number of pixels in the output image
%           is_fourier_flag     - 1: the input is given in the fourier domain
%                                 0: the input is given in the space domain
%                                    (we need to use fft2 to convert to fourier domain)
%           is_real_flag        - 0: the input is a complex matrix -> don't use
%                                    abs() at the output, perform complex
%                                    up/down sampling
%                                 1: the input is real BUT has negative values ->
%                                    use real() at the output
%                                 2: the input is real and positive -> using
%                                    abs() at the output 
%
% output:   out_m               - up/down sampled image 
%
% NOTE: it is important to specify if the image is REAL or COMPLEX, since
%       if the image is REAL -> we have to use ABS() on the inverse fourier
%       transform (because of roundoff errors of the transform).
%
% NOTE: since a desired amount of pixels is needed at the output, there is
%       no attempt to use matrices which are in size of power of 2. this
%       optimization can not be used in this case
%
% NOTE: input series needs to be CONTINUOUS OF A HIGH DEGREE, since the
%       upsampling is done in the frequency domain, which samples the output
%       grid with SINE-like (harmonic) functions
%
% 


% 
% Theory:   the upsampling is done by zero-padding in the input domain BETWEEN the samples,
%           then at the fourier domain, taking the single spectrum (out of the repetition of spectrums)
%           i.e. low pass with Fcutoff=PI/upsample_factor, zeroing the rest of the spectrum
%           and then doing ifft to the distribution.
%           since we have a zero padding operation in time, we need to multiply by the fourier gain.
%
%              +-----------+     +-------+     +---------+     +--------+     +--------+
%   y[n,m] --> | up-sample | --> |  FFT  | --> |   LPF   | --> | * Gain | --> |  IFFT  | --> interpolated 
%              | factor M  |     +-------+     | Fc=PI/M |     +--------+     +--------+
%              +-----------+                   +---------+
%
%           this operation is the same as the following one (which has less operations):
%
%              +-------+     +--------+     +--------------+     +--------+
%   y[n,m] --> |  FFT  | --> | * Gain | --> | Zero Padding | --> |  IFFT  | --> interpolated 
%              +-------+     +--------+     +--------------+     +--------+
%
%           NOTE THAT, the zero-padding must be such that the D.C. ferquency remains the D.C. frequency
%           and that the zero padding is applied to both positive and negative frequencies. 
%           The zero padding actually condences the frequency -> which yields a longer series in the 
%           image domain, but without any additional information, thus the operation must be an interpolation.
%
%
% Thoroughly modified by Tim van Mourik to make it work in 3D (or n-D), 
% (C) 2016 

if nargin < 3
    isReal = 0;
end

% ==============================================
% get input image size, and calculate the gain
% ==============================================
inputSize =  size( inputMatrix );
gain = outputSize ./ inputSize;

% build grid vectors for the up/down sampling
% ============================================
% if the input is even & output is odd-> use floor for all
% if the output is even & input is odd -> use ceil for all
% other cases - don't care
% for downsampling -> the opposite
numberOfDimensions = length(outputSize);
output_space = cell(1, numberOfDimensions);
input_space  = cell(1, numberOfDimensions);

inputMatrix = fftn(inputMatrix);

for i = 1:numberOfDimensions

    if (~mod( inputSize(i), 2 ) && (outputSize(i)>inputSize(i))) || (mod( inputSize(i),2 ) && (outputSize(i)<inputSize(i)))
        output_space{i}  = max(floor((outputSize(i)-inputSize(i))/2),0) + (1:min(inputSize(i),outputSize(i)));
        input_space{i}   = max(floor((inputSize(i)-outputSize(i))/2),0) + (1:min(inputSize(i),outputSize(i)));
    else
        output_space{i}  = max(ceil((outputSize(i)-inputSize(i))/2),0) + (1:min(inputSize(i),outputSize(i)));
        input_space{i}   = max(ceil((inputSize(i)-outputSize(i))/2),0) + (1:min(inputSize(i),outputSize(i)));
    end

end

% perform the up/down sampling
paddedMatrix    = zeros(outputSize);
inputMatrix     = fftshift(inputMatrix);

% padded_out_m(output_space{:}) = inputMatrix(input_space{:}); %no window
% paddedMatrix(output_space{:}) = inputMatrix(input_space{:}) .* hammingWindow(outputSize); %hamming window
paddedMatrix(output_space{:}) = inputMatrix(input_space{:}) .* tukeyWindow(outputSize); %tukey window
outputMatrix           = prod(gain) * ifftn(ifftshift(paddedMatrix));   

switch isReal
    case 0, % do nothing
    case 1, outputMatrix   = real(outputMatrix);
    case 2, outputMatrix   = abs( outputMatrix);
end

end %end function


function window = hammingWindow(windowSize)

numberOfDimensions = length(windowSize);
window1D = cell(numberOfDimensions, 1);
for i = 1:numberOfDimensions
    window1D{i} = hamming(windowSize(i));
end
[window1D{:}] = meshgrid(window1D{:});
window = reshape([window1D{:}], [windowSize(2), windowSize(1), length(windowSize), windowSize(3)]);
window = prod(permute(window, [2, 1, 4, 3]), 4);

end %end function


function window = tukeyWindow(windowSize)

r = 0.5;
numberOfDimensions = length(windowSize);
window1D = cell(numberOfDimensions, 1);
for i = 1:numberOfDimensions
    window1D{i} = tukeywin(windowSize(i) + mod(windowSize(i), 2), r);
    window1D{i} = window1D{i}(1:end - mod(windowSize(i), 2));
end
[window1D{:}] = meshgrid(window1D{:});
window = reshape([window1D{:}], [windowSize(2), windowSize(1), length(windowSize), windowSize(3)]);
window = prod(permute(window, [2, 1, 4, 3]), 4);

end %end function



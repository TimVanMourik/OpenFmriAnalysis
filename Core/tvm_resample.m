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
in_sz =  size( inputMatrix );
gain = outputSize ./ in_sz;

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

    if (~mod( in_sz(i), 2 ) && (outputSize(i)>in_sz(i))) || (mod( in_sz(i),2 ) && (outputSize(i)<in_sz(i)))
        output_space{i}  = max(floor((outputSize(i)-in_sz(i))/2),0) + (1:min(in_sz(i),outputSize(i)));
        input_space{i}   = max(floor((in_sz(i)-outputSize(i))/2),0) + (1:min(in_sz(i),outputSize(i)));
    else
        output_space{i}  = max(ceil((outputSize(i)-in_sz(i))/2),0) + (1:min(in_sz(i),outputSize(i)));
        input_space{i}   = max(ceil((in_sz(i)-outputSize(i))/2),0) + (1:min(in_sz(i),outputSize(i)));
    end

end

% perform the up/down sampling
padded_out_m    = zeros(outputSize);
inputMatrix            = fftshift(inputMatrix);

padded_out_m(output_space{:}) = inputMatrix(input_space{:});
outputMatrix           = prod(gain) * ifftn(ifftshift(padded_out_m));   

switch isReal
    case 0, % do nothing
    case 1, outputMatrix   = real(outputMatrix);
    case 2, outputMatrix   = abs( outputMatrix);
end

end %end function



%@todo think about Tukey filering before resampling
function window = filterWindow(windowLength, samplingRate)

% w = 1D zero-padded nn-point Tukey filter window matched to the sampling ratio
% 
% Filter window is defined in three sections: taper, constant, taper
% Period of the taper is defined as 1/2 period of a sine wave.

if samplingRate < 1.25
	window = ones(windowLength, 1);			% No filtering if we do no (or hardly any) downsampling
	return
end

% Constants
per = 0.25;					% = r/2, r=0.5 (= 1/4 taper + 1/2 constant + 1/4 taper)

m = round(windowLength / samplingRate);			% Size of resampling (Src) window (must be < nn)
if rem(m, 2) == 0;
	n = m + 1;				% Make sure the Tukey window is symmetric, i.e. has an odd length 'n'
else
	n = m;
end

% Create the Tukey filter window of length n
t   = linspace(0, 1, n)';
tl  = floor(per * (n - 1)) + 1;
th  = n - tl + 1;
tw  = [((1 + cos(pi / per * (t(1:tl) - per))) / 2);  ones(th - tl - 1, 1); ((1 + cos(pi / per * (t(th:end) - 1 + per))) / 2)];

% Zero-pad the filter window to the full (length nn) k-space
window   = ifftshift([zeros(ceil((windowLength - n) / 2), 1); tw; zeros(floor((windowLength - n) / 2), 1)]);

end %end function


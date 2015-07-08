function regressor = tvm_hrf(timePoints, stimulusOnsets, stimulusDurations, hrfParameters)
%
% For duration = 0 an impuls response is taken and a regular HRF is used.
%
% Example:
% timePoints = 0:0.2:20; 
% onsetTimes = [2, 8];
% durations  = [0, 0];
% convolution = tvm_hrf(timePoints, onsetTimes, durations);
% plot(timePoints, convolution);
%
% Note that the area under the HRF curve is computed for a given time step.
% This will be small for small duration. Only when duration = 0, an impuls
% response is used. This may result in unexpected behaviour when using zero
% and non-zero durations for a single regressor.

if nargin < 4
    hrfParameters = [6, 16, 1, 1, 6, 0, 32];
end

regressor = zeros(size(timePoints));
for i = 1:length(stimulusOnsets)
    regressor = regressor + tvm_sampleHrf(timePoints, stimulusOnsets(i), stimulusDurations(i), hrfParameters);
end

end %end function


function hrfValues = tvm_sampleHrf(timePoints, t0, duration, hrfParameters)
%  
% t0 is a single stimulus
%

k1 = hrfParameters(1) / hrfParameters(3);
theta1 = 1 / hrfParameters(3);
k2 = hrfParameters(2) / hrfParameters(4);
theta2 = 1 / hrfParameters(4);

hrfValues = zeros(size(timePoints));

if duration == 0
    indices = timePoints > t0;
    %centre time around onset time
    timePoints = timePoints - t0;
    hrfValues(indices) = tvm_gammaPdf(timePoints(indices), k1, theta1) - tvm_gammaPdf(timePoints(indices), k2, theta2) / hrfParameters(5);
    
    %normalisation:
    hrfValues = hrfValues / (1 - 1 / hrfParameters(5));
else
    t1 = t0 + duration;

    indices = timePoints <= t0;
    hrfValues(indices)      = 0;

    indices = timePoints > t0;
    hrfValues(indices) = tvm_gammaCdf(timePoints(indices) - t0, k1, theta1) - tvm_gammaCdf(timePoints(indices) - t0, k2, theta2) / hrfParameters(5);

    indices = timePoints > t1;
    hrfValues(indices) = hrfValues(indices) - (tvm_gammaCdf(timePoints(indices) - t1, k1, theta1) - tvm_gammaCdf(timePoints(indices) - t1, k2, theta2) / hrfParameters(5));

    %normalisation:
    hrfValues = hrfValues / (1 - 1 / hrfParameters(5));
end

end %end function


function f = tvm_gammaPdf(x, k, theta)

% f = 1 ./ (gamma(k) .* theta .^ k) .* x .^ (k - 1) .* exp(-x ./ theta);
f = exp((k-1) .* log(x) + k .* log(theta) - theta .* x - gammaln(k));

end %end function


function f = tvm_gammaCdf(x, k, theta)
% the integral of the Gamma function is the incomplete upper gamma function 

f = 1 - gammainc(x .* theta, k, 'upper');

end %end function


function test

%%
hrfParameters = [6, 16, 1, 1, 6, 0, 32];
timePoints = 0:1:300;
stimulus = [20, 120, 220];
duration = [60, 0, 60];

% dt = 0.001;
% timePoints = 0:dt:60;
% stimulus = 0;
% duration = 20;
% hrfParameters = [6, 16, 1, 1, 6, 0, 32];

figure;
regressor = tvm_sampleHrf(timePoints, stimulus, duration, hrfParameters);
plot(timePoints, regressor);

% hold on;
% plot(spm_hrf(dt, hrfParameters));

end %end function














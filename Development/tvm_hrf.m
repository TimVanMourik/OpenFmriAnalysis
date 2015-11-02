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
if nargin < 3
    stimulusDurations = zeros(size(stimulusOnsets));
end

regressor = zeros(size(timePoints));
for i = 1:length(stimulusOnsets)
%     regressor = regressor + tvm_sampleHrf(timePoints, stimulusOnsets(i), stimulusDurations(i), hrfParameters);
    regressor = regressor + tvm_sampleHrfTemporalDerivative(timePoints, stimulusOnsets(i), stimulusDurations(i), hrfParameters);
%     regressor = regressor + tvm_sampleHrfDispersionDerivative(timePoints, stimulusOnsets(i), stimulusDurations(i), hrfParameters);
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

function hrfValues = tvm_sampleHrfTemporalDerivative(timePoints, t0, duration, hrfParameters)
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
    hrfValues(indices) = tvm_gammaPdf(timePoints(indices), k1, theta1) .* ((k1 -1) ./  timePoints(indices) - 1 / theta1)...
        - tvm_gammaPdf(timePoints(indices), k2, theta2) .* ((k2 - 1)  ./ timePoints(indices) - 1 / theta2) / hrfParameters(5);
    
    orthogonalisation = ((4 ^ (k1 + -1) * exp(-2 * timePoints(indices))/ theta1) * (timePoints(indices) / theta1) .^ (2 * k) * theta1 * gamma(2 * k1 - 1)) / (timePoints(indices) .^ 2 * gammainc((2 * timePoints(indices)) / theta1, 2 * k1 - 1, 'upper'));

%     hrfValues(indices) = hrfValues(indices) - orthogonalisation;
    
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

function hrfValues = tvm_sampleHrfDispersionDerivative(timePoints, t0, duration, hrfParameters)
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
%     hrfValues(indices) = tvm_gammaPdf(timePoints(indices), k1, theta1) .* (log(timePoints(indices) / theta1) + psi(timePoints(indices))) - ...
%         tvm_gammaPdf(timePoints(indices), k2, theta2) .* (log(timePoints(indices) / theta2) + psi(timePoints(indices))) / hrfParameters(5);
%     
    hrfValues(indices) = tvm_gammaPdf(timePoints(indices), k1, theta1) .* (- k1 / theta1 - timePoints(indices) * log(theta1)) - ...
        tvm_gammaPdf(timePoints(indices), k2, theta2) .* (- k2 / theta2 - timePoints(indices) * log(theta2)) / hrfParameters(5);
    
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

function test

%%
% hrfParameters = [6, 16, 1, 1, 6, 0, 32];
% timePoints = 0:1:300;
% stimulus = [20, 120, 220];
% duration = [60, 0, 60];

dt = 0.001;
timePoints = 0:dt:30;
stimulus = 0;
duration = 0;
hrfParameters = [6, 16, 1, 1, 6, 0, 32];

% figure;
regressor = tvm_hrf(timePoints, stimulus, duration, hrfParameters);
plot(timePoints, regressor);

% hold on;
% plot(spm_hrf(dt, hrfParameters));

end %end function














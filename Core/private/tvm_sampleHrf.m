function regressor = tvm_sampleHrf(timePoints, stimulusOnsets, stimulusDurations, hrfParameters, type)
%
% For duration = 0 an impuls response is taken and a regular HRF is used.
%
% Note that the area under the HRF curve is computed for a given time step.
% This will be small for small duration. Only when duration = 0, an impuls
% response is used. This may result in unexpected behaviour when using zero
% and non-zero durations for a single regressor.
%
%   Copyright (C) Tim van Mourik, 2015, DCCN

regressor = zeros(size(timePoints));
switch type
    case 'Regular'
        for i = 1:length(stimulusOnsets)
            regressor = regressor + regularHrf(timePoints, stimulusOnsets(i), stimulusDurations(i), hrfParameters);
        end
    case 'TemporalDerivative'
        for i = 1:length(stimulusOnsets)
            regressor = regressor + temporalDerivative(timePoints, stimulusOnsets(i), stimulusDurations(i), hrfParameters);
        end
    case 'DispersionDerivative'
        for i = 1:length(stimulusOnsets)
            regressor = regressor + dispersionDerivative(timePoints, stimulusOnsets(i), stimulusDurations(i), hrfParameters);
        end
end

end %end function


function hrfValues = regularHrf(timePoints, t0, duration, hrfParameters)
%  
% t0 is a single stimulus
%

% delay of response = k / theta
k1 = hrfParameters(1) / hrfParameters(3);
theta1 = 1 / hrfParameters(3);
k2 = hrfParameters(2) / hrfParameters(4);
theta2 = 1 / hrfParameters(4);
peakRatio = hrfParameters(5);

hrfValues = zeros(size(timePoints));

if duration == 0
    indices = timePoints > t0;
    %centre time around onset time
    timePoints = timePoints - t0;
    hrfValues(indices) = tvm_gammaPdf(timePoints(indices), k1, theta1) - tvm_gammaPdf(timePoints(indices), k2, theta2) / peakRatio;
    
    %normalisation:
    hrfValues = hrfValues / (1 - 1 / peakRatio);
else
    t1 = t0 + duration;

    indices = timePoints <= t0;
    hrfValues(indices)      = 0;

    indices = timePoints > t0;
    hrfValues(indices) = tvm_gammaCdf(timePoints(indices) - t0, k1, theta1) - tvm_gammaCdf(timePoints(indices) - t0, k2, theta2) / peakRatio;

    indices = timePoints > t1;
    hrfValues(indices) = hrfValues(indices) - (tvm_gammaCdf(timePoints(indices) - t1, k1, theta1) - tvm_gammaCdf(timePoints(indices) - t1, k2, theta2) / peakRatio);

    %normalisation:
    hrfValues = hrfValues / (1 - 1 / peakRatio);
end

end %end function

function hrfValues = temporalDerivative(timePoints, t0, duration, hrfParameters)
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
        
    %normalisation:
    hrfValues = hrfValues / (1 - 1 / hrfParameters(5));
else
    t1 = t0 + duration;

    indices = timePoints <= t0;
    hrfValues(indices)      = 0;

    indices = timePoints > t0;
    hrfValues(indices) = tvm_gammaPdf(timePoints(indices) - t0, k1, theta1) - tvm_gammaPdf(timePoints(indices) - t0, k2, theta2) / hrfParameters(5);

    indices = timePoints > t1;
    hrfValues(indices) = hrfValues(indices) - (tvm_gammaPdf(timePoints(indices) - t1, k1, theta1) - tvm_gammaPdf(timePoints(indices) - t1, k2, theta2) / hrfParameters(5));

    %normalisation:
    hrfValues = hrfValues / (1 - 1 / hrfParameters(5));
end


end %end function

function hrfValues = dispersionDerivative(timePoints, t0, duration, hrfParameters)
%  
% t0 is a single stimulus
%

% The spm way: approximating by incrementing the dispersion a little bit. 
% The analytical integrals are nasty... 
hrfValues1 = regularHrf(timePoints, t0, duration, hrfParameters);
hrfParameters(3) = hrfParameters(3) + 0.001;
hrfValues2 = regularHrf(timePoints, t0, duration, hrfParameters);

hrfValues = hrfValues1 - hrfValues2;

end %end function


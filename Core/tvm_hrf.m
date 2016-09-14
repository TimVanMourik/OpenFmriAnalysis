function stimulusRegressors = tvm_hrf(configuration)
%
% For duration = 0 an impuls response is taken and a regular HRF is used.
%
% Note that the area under the HRF curve is computed for a given time step.
% This will be small for small duration. Only when duration = 0, an impuls
% response is used. This may result in unexpected behaviour when using zero
% and non-zero durations for a single regressor.
%
%   Copyright (C) Tim van Mourik, 2015, DCCN

%% Parse configuration
timePoints              = tvm_getOption(configuration, 'Timepoints');
    % 
stimulusOnsets          = tvm_getOption(configuration, 'Stimuli');
    %
stimulusDurations       = tvm_getOption(configuration, 'Durations', []);
    % if no durations are given, event related design is assumed
hrfParameters           = tvm_getOption(configuration, 'HrfParameters', [6, 16, 1, 1, 6, 0, 32]);
    % default HRF parameters, same as in SPM
regularHrf              = tvm_getOption(configuration, 'Regular', true);
    % by default, no temporal derivative is included
temporalDerivative      = tvm_getOption(configuration, 'TemporalDerivative', false);
    % by default, no temporal derivative is included
dispersionDerivative    = tvm_getOption(configuration, 'DispersionDerivative', false);
    % by default, no dispersion derivative is included
demean                  = tvm_getOption(configuration, 'DeMean', false);
    % by default, no dispersion derivative is included
    
%%
if isempty(stimulusDurations)
    stimulusDurations = zeros(size(stimulusOnsets));
end

stimulusRegressors = [];
if regularHrf
    regressor = tvm_sampleHrf(timePoints, stimulusOnsets, stimulusDurations, hrfParameters, 'Regular');
    %scale by the height of an isolated two second event (Mumford,
    %http://mumford.bol.ucla.edu/perchange_guide.pdf)
    regressor = regressor / max(tvm_sampleHrf(0:0.01:16, 0, 2, hrfParameters, 'Regular'));
    stimulusRegressors = [stimulusRegressors; regressor];
end
if temporalDerivative
    regressor = tvm_sampleHrf(timePoints, stimulusOnsets, stimulusDurations, hrfParameters, 'TemporalDerivative');
    stimulusRegressors = [stimulusRegressors; regressor];
end
if dispersionDerivative
    regressor = tvm_sampleHrf(timePoints, stimulusOnsets, stimulusDurations, hrfParameters, 'DispersionDerivative');
    stimulusRegressors = [stimulusRegressors; regressor];
end

if demean
    stimulusRegressors = bsxfun(@minus, stimulusRegressors, mean(stimulusRegressors, 2));
end

% Orthogonalise derivatives wrt the main
stimulusRegressors = spm_orth(stimulusRegressors')';
% in case you want to pursue a Calhoun 2004 strategy:
% stimulusRegressors = bsxfun(@rdivide, stimulusRegressors, sqrt(sum(stimulusRegressors .^ 2, 2)));

end %end function



function test

%%
dt              = 0.1;
timePoints      = 0:dt:30;
stimulus        = 0;
duration        = 0;

% timePoints    = 0:1:130;
% stimulus      = [20, 50, 100];
% duration      = [3, 2, 4];

configuration = [];
configuration.Timepoints            = timePoints;
configuration.Stimuli               = stimulus;
configuration.Durations             = duration;
configuration.HrfParameters         = [6, 16, 1, 1, 6, 0, 32];
configuration.TemporalDerivative    = true;
configuration.DispersionDerivative  = true;

% figure;
regressor = tvm_hrf(configuration);
plot(timePoints, regressor);


end %end function














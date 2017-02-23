function [phase, phaseKnown] = tvm_getPhase(physioTrigger, acquisitionTimes)
% TVM_GETPHASE
%   [phase, phaseKnown] = TVM_GETPHASE(physioTrigger, acquisitionTimes)
%   Computes the phase at of the phsyiological cycle at given points
%   @todo Expand description
%
%   Copyright (C) Tim van Mourik, 2015-2016, DCCN
%

numberOfVolumes             = length(acquisitionTimes);
lowerBound                  = sum(bsxfun(@lt, repmat(physioTrigger, [numberOfVolumes, 1]), acquisitionTimes'), 2);
% in case last trigger is before last acquisition
phaseKnown                  = lowerBound + 1 <= length(physioTrigger);
phaseKnown(lowerBound == 0) = false;
phase                       = nan(1, numberOfVolumes);
phase(phaseKnown)           = (acquisitionTimes(phaseKnown) - physioTrigger(lowerBound(phaseKnown))) ./ (physioTrigger(lowerBound(phaseKnown) + 1) - physioTrigger(lowerBound(phaseKnown)));

end
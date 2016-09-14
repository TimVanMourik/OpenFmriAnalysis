function [phase, phaseKnown] = tvm_getPhase(physioTrigger, acquisitionTimes)

numberOfVolumes             = length(acquisitionTimes);
lowerBound                  = sum(bsxfun(@lt, repmat(physioTrigger, [numberOfVolumes, 1]), acquisitionTimes'), 2);
% in case last trigger is before last acquisition
phaseKnown                  = lowerBound + 1 <= length(physioTrigger);
phaseKnown(lowerBound == 0) = false;
phase                       = nan(1, numberOfVolumes);
phase(phaseKnown)           = (acquisitionTimes(phaseKnown) - physioTrigger(lowerBound(phaseKnown))) ./ (physioTrigger(lowerBound(phaseKnown) + 1) - physioTrigger(lowerBound(phaseKnown)));

end
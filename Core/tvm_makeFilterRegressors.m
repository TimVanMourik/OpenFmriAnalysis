function designMatrix = tvm_makeFilterRegressors(numberOfVolumes, TR, cutOff)
%HIGHPASS 
%	F = BANDPASSASS(DATA, TR, L, U)
%   DATA = [timepoints X voxels]
%   Copyright (C) 2013, Tim van Mourik, DCCN

designLength = sum(numberOfVolumes);
startOfRun = [0, cumsum(numberOfVolumes)'] + 1;
designMatrix = [];
for session = 1:length(numberOfVolumes)
    timePoints = startOfRun(session):startOfRun(session + 1) - 1;
    numberOfTimepoints = length(timePoints);
    if mod(numberOfTimepoints, 2) == 0
        frequencies = 0:(numberOfTimepoints / 2);
    else
        frequencies = 0:((numberOfTimepoints - 1) / 2);
    end
    frequencies = frequencies / (max(frequencies) * 2 * TR);
    frequencies = frequencies(frequencies <= cutOff);
    for f = frequencies
        time = TR *(0:(numberOfVolumes(session) - 1));
        
        if f ~= 0
            regressor = zeros(designLength, 1);
            sines = sin(time * f * 2 * pi);
            regressor(timePoints) = sines;
            designMatrix = [designMatrix, regressor];
            
            regressor = zeros(designLength, 1);
            cosines = cos(time * f * 2 * pi);
            regressor(timePoints) = cosines;
            designMatrix = [designMatrix, regressor];
        end
    end

end

end %end function






function regressorMatrix =  tvm_constructFirModel(configuration)
%   
%   Make sure the segment spacing, time points and stimulus have the same
%   time units.
%
%   Copyright (C) Tim van Mourik, 2014, DCCN
%

%% Parse configuration
segmentSpacing =        tvm_getOption(configuration, 'SegmentSpacing', 1);
    %no default
numberOfSegments =      tvm_getOption(configuration, 'NumberOfSegments', 16);
    %no default
timePoints =            tvm_getOption(configuration, 'TimePoints');
    %no default
stimulus =              tvm_getOption(configuration, 'Stimulus');
    %no default    
   
%%
segments = 0:segmentSpacing:(segmentSpacing * numberOfSegments - 1);
regressorMatrix = zeros(length(timePoints), numberOfSegments);
for i = 1:length(timePoints)
    withinRange = timePoints(i) >= stimulus & timePoints(i) < stimulus + segments(end);
    for j = find(withinRange)
        t = timePoints(i) - stimulus(j);
        index = find(t <= segments);
        if index(1) == 1 %equivalent to t == 0
            regressorMatrix(i, index(1))        =       1;
        else
            weight = (t - segments(index(1) - 1)) / segmentSpacing;
            regressorMatrix(i, index(1) - 1)    = 1 - weight;
            regressorMatrix(i, index(1))        = weight;
        end
    end
end  


end %end function

%%
function test
%%
configuration = [];
configuration.SegmentSpacing = 0.5;
configuration.NumberOfSegments = 20;
configuration.TimePoints = 1:100;
configuration.Stimulus = [5.3, 7.4, 38.38, 70];
regressorMatrix = tvm_constructFirModel(configuration);
%  imagesc(regressorMatrix)
end



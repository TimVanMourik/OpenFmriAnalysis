function regressor = tvm_sampleHrf(timePoints, stimulus, hrfParameters)

maxTime = hrfParameters(7);

regressor = zeros(length(timePoints), 1);
for i = 1:length(timePoints)
    activityRange = stimulus(stimulus > timePoints(i) - maxTime & stimulus < timePoints(i));
    for j = 1:length(activityRange)
        regressor(i) = regressor(i) + tvm_hrf(timePoints(i) - activityRange(j), hrfParameters);
    end
end

end %end function

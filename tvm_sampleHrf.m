function regressor = tvm_sampleHrf(timePoints, stimulusOnset, hrfParameters, stimulusDuration)

if nargin < 4
    stimulusDuration = zeros(size(stimulusOnset));
end

maxTime = hrfParameters(7);

regressor = zeros(length(timePoints), 1);
for i = 1:length(timePoints)
    activityRange = stimulusOnset < timePoints(i) & timePoints(i) < stimulusOnset + stimulusDuration + maxTime;
    if any(activityRange)
        onsets = stimulusOnset(activityRange);
        durations = stimulusDuration(activityRange);
        for j = 1:length(activityRange)
            regressor(i) = regressor(i) + tvm_hrf(timePoints(i) - onsets(j), hrfParameters);
        end
    end
end

end %end function


function test
%%
hrfParameters = [6    16     1     1     6     0    32];

timePoints = [...
    1.6800    5.0400    8.4000   11.7600   15.1200   18.4800   21.8400   25.2000   28.5600   31.9200   35.2800   38.6400   42.0000   45.3600   48.7200   52.0800   55.4400   58.8000   62.1600, ...
   65.5200   68.8800   72.2400   75.6000   78.9600   82.3200   85.6800   89.0400   92.4000   95.7600   99.1200  102.4800  105.8400  109.2000  112.5600  115.9200  119.2800  122.6400  126.0000, ...
  129.3600  132.7200  136.0800  139.4400  142.8000  146.1600  149.5200  152.8800  156.2400  159.6000  162.9600  166.3200  169.6800  173.0400  176.4000  179.7600  183.1200  186.4800  189.8400, ...
  193.2000  196.5600  199.9200  203.2800  206.6400  210.0000  213.3600  216.7200  220.0800  223.4400  226.8000  230.1600];
stimulus = [6.5667   12.3333   23.6500   32.5000   55.7833   89.1833   99.1500  128.4500  158.2667  163.2167  184.9667];

regressor = tvm_sampleHrf(timePoints, stimulus, hrfParameters);

end %end function
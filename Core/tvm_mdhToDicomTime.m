% convert the volume acquisition time stamps of dicom files to MDH time
% stamps (msec after midnight)

function trueTime = tvm_mdhToDicomTime(msTimestamp)

microSeconds    = mod(msTimestamp, 1000);
trueTime        = (msTimestamp - microSeconds) / 1000;
seconds         = mod(trueTime, 60);
trueTime        = (trueTime - seconds) / 60;
minutes         = mod(trueTime, 60);
hours           = (trueTime - minutes) / 60;
% trueTime = sprintf('%02d%02d%02d%02d', hours, minutes, seconds, microSeconds);
trueTime = sprintf('%02d:%02d:%02d.%02d', hours, minutes, seconds, round(microSeconds));

end


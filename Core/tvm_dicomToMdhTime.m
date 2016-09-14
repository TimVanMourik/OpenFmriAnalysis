% convert the volume acquisition time stamps of dicom files to MDH time
% stamps (msec after midnight)

function msTimestamp = tvm_dicomToMdhTime(time)

time            = str2double(time);
hours           = fix(time / 10000);
time            = time - hours * 10000;
minutes      	= fix(time / 100);
time            = time - minutes*100;
seconds      	= fix(time);
time            = time - seconds;
microSeconds    = round(time * 1000); % microseconds

msTimestamp = (((hours * 60) + minutes) * 60 + seconds) * 1000 + microSeconds;

end


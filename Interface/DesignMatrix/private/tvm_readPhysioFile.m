function [triggerTimes, rejectionWindows] = tvm_readPhysioFile(filename)
% TVM_READPHYSIOFILE
%   [triggerTimes, rejectionWindows] = TVM_READPHYSIOFILE(filename)
%   Reads the physiological triggers from Siemens files or Hera preocessed 
%   mat files
%   @todo Expand description
%
%   Copyright (C) Tim van Mourik, 2015-2016, DCCN
%

[~, ~, extension] = fileparts(filename);

switch extension
    case {'.ecg', '.ext', '.puls', '.resp'}
        peakMarker = 5000; %    Siemens default
        samplingRate = 50; %Hz, Siemens default

        f = fopen(filename);
        physioData = textscan(f, '%d');
        physioData = physioData{1};
        timingText= textscan(f, '%s', 'Headerlines', 9);
        timingText = timingText{1};
        fclose(f);

        %in Siemens files, the first 4 numbers and the last seem to be rubbish
        physioData = physioData(5:end - 1);

        % "The MDH time-stamp values are to be preferred as they are derived from 
        % the same clock used to time-stamp the DICOM images." (Geoffrey Aguirre Lab)
        startTime = str2double(timingText{2});

        triggers = find(physioData == peakMarker);
        triggerTimes = 1000 * (triggers' - (1:length(triggers))) / samplingRate + startTime;
        rejectionWindows = cell(1, 0);
    case '.mat'
        load(filename, 'matfile');
        withinReject = false(size(matfile.prepeakTimes));
        for i = 1:length(matfile.prereject)
            withinReject = withinReject | (matfile.prepeakTimes > matfile.prereject{i}(1) & matfile.prepeakTimes < matfile.prereject{i}(2));
        end
        triggerTimes = matfile.prepeakTimes(~withinReject) * 1000 + double(matfile.startTime);
        if isempty(matfile.prereject)
            rejectionWindows = cell(1, 0);
        else
            rejectionWindows = cellfun(@times, matfile.prereject, repmat({[1000, 1000]}, [1, length(matfile.prereject)]), 'UniformOutput', false);
            rejectionWindows = cellfun(@plus, rejectionWindows, repmat({[double(matfile.startTime), double(matfile.startTime)]}, [1, length(matfile.prereject)]), 'UniformOutput', false);
        end
end
end


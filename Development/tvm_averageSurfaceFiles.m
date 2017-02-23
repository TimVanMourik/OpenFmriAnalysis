function tvm_averageSurfaceFiles(configuration)
% TVM_PROJECTVOLUMETOSURFACE
%   TVM_PROJECTVOLUMETOSURFACE(configuration)
%   
%
%   Copyright (C) Tim van Mourik, 2014, DCCN
%
%   configuration.SubjectDirectory
%   configuration.LabelFiles
%   configuration.Hemisphere
%   configuration.VolumeFiles
%   configuration.ReferenceVolume
%   configuration.Boundaries
%

%% Parse configuration
subjectDirectory 	= tvm_getOption(configuration, 'i_SubjectDirectory', pwd());
    %no default
volumeFiles         = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_SurfaceFiles'));
    %no default
outputFile          = fullfile(subjectDirectory, tvm_getOption(configuration, 'o_MeanSurface'));
    %no default
    
%%

surfaceValues = cell(size(volumeFiles));
indices = cell(size(volumeFiles));
for i = 1:length(volumeFiles)
    if ~exist(volumeFiles{i}, 'file')
        volumeFiles(i) = [];
        surfaceValues(i) = [];
        indices(i) = [];
        break
    end
    [surfaceValues{i}, indices{i}] = freesurfer_read_wfile(volumeFiles{i});
end
uniqueIndices = unique(vertcat(indices{:}));
meanValues = zeros(size(uniqueIndices));
for i = 1:length(volumeFiles)
    idx = ismember(uniqueIndices, indices{i});
    meanValues(idx) = meanValues(idx) + surfaceValues{i};
end
meanValues = meanValues / length(volumeFiles);

freesurfer_write_wfile(outputFile, meanValues, uniqueIndices);

end %end function







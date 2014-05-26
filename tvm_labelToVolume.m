function output = tvm_labelToVolume(configuration)

memtic
subjectDirectory = configuration.SubjectDirectory;
labels           = configuration.LabelFiles;

hemisphereList = getHemispheres(configuration.Hemisphere, configuration.LabelFiles);

% 2 because there are two hemispheres
verticesOfInterest = cell([length(labels), 2]);
%loops over all separate volumes-to-be
for i = 1:length(labels)
    %loops over all labels within the new volume
    for j = 1:length(labels{i})
        verticesOfInterest{i, hemisphereList{i}{j}} = [verticesOfInterest{i, hemisphereList{i}{j}}; importLabelFile([subjectDirectory configuration.LabelFiles{i}{j}])];
    end
end

%load reference volume
referenceVolume = spm_vol([subjectDirectory configuration.ReferenceVolume]);

%import the labels and boundaries
load([subjectDirectory configuration.Boundaries], 'wSurface', 'pSurface');
%convert labels to coordinates
for i = 1:length(labels)
    %loops over all labels within the new volume
    coordinates = [];
    for hemisphere = 1:2
        coordinates = [coordinates; pSurface{hemisphere}(verticesOfInterest{i, hemisphere}, :)];
        coordinates = [coordinates; wSurface{hemisphere}(verticesOfInterest{i, hemisphere}, :)];
    end
    %find the unique rounded coordinates in the volume
    coordinates = unique(round(withinRange(referenceVolume.dim, coordinates)), 'rows');
    
    %convert coordinates to volume
    indices = sub2ind(referenceVolume.dim, coordinates(:, 1), coordinates(:, 2), coordinates(:, 3));
    regionOfInterest = referenceVolume;
    regionOfInterest.dt = [2, 0];
    regionOfInterest.fname = [subjectDirectory configuration.VolumeFiles{i}];
    regionOfInterest.volume = false(referenceVolume.dim);
    regionOfInterest.volume(indices) = true;
    %grow selection
    regionOfInterest.volume = dilate3D(regionOfInterest.volume, 3);
    
    %save the volume
    spm_write_vol(regionOfInterest, regionOfInterest.volume);
    
end

output = memtoc;

end %end function














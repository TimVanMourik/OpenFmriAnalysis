function output = tvm_labelToTimecourse4D(configuration)

memtic
subjectDirectory    = configuration.SubjectDirectory;

functionalScan = spm_vol([subjectDirectory configuration.MeanFunctional]);    
allVolumes = spm_vol([subjectDirectory configuration.FunctionalFiles]);

if ~exist([subjectDirectory configuration.Atlas(1:(end-4)) '.nii'], 'file')
    unix(['mri_convert ' subjectDirectory configuration.Atlas ' ' subjectDirectory configuration.Atlas(1:(end-4)) '.nii']);
end
labelledVolume = spm_vol([subjectDirectory configuration.Atlas(1:(end-4)) '.nii']);
labelledVolume.volume = spm_read_vols(labelledVolume);

load([subjectDirectory configuration.CoregistrationMatrix], 'coregistrationMatrix')
transformation = coregistrationMatrix * functionalScan.mat \ labelledVolume.mat;
transformation = transformation';

numberOfLabels = length(configuration.Labels);
timecourses = cell(numberOfLabels, 1);
for label = 1:numberOfLabels
    labelled = find(ismember(labelledVolume.volume, configuration.Labels{label}));

    [x, y, z] = ind2sub(labelledVolume.dim, labelled);
    coordinates = [x, y, z, ones(size(x))];
    %remove duplicates
    coordinates = unique(round(coordinates * transformation), 'rows');
    %remove coordinates outside the volume
    coordinates = coordinates(all(~bsxfun(@gt, coordinates(:, 1:3), functionalScan.dim), 2), :);
    coordinates = coordinates(all(bsxfun(@gt, coordinates(:, 1:3), [0, 0, 0]), 2), :);

%     timecourses{label} = nanmean(spm_get_data(allVolumes, coordinates(:, 1:3)'), 2);
    timecourses{label} = nanmean(getData(allVolumes, coordinates(:, 1:3)'), 2);
    
%         volume = spm_read_vols(spm_vol([subjectDirectory configuration.FunctionalFolder functionalScans{scan}]));
%         volume = functionalScans(scan).private.dat(:, :, :, scan);
end

save([subjectDirectory configuration.Timecourse], 'timecourses');

output = memtoc;

end %end function



function data = getData(allVolumes, coordinates)

numberOfCoordinates = size(coordinates, 2);
numberOfVolumes = length(allVolumes);

if prod(allVolumes(1).dim) * numberOfVolumes * 8 > 4 * 1024 ^ 3
    volumeCoordinates = repmat(1:numberOfVolumes, [numberOfCoordinates, 1]);
    volumeCoordinates = [repmat(coordinates, [1, numberOfVolumes])' volumeCoordinates(:)];
    volume = allVolumes(1).private.dat;
    indices = sub2ind(size(volume), volumeCoordinates(:, 1), volumeCoordinates(:, 2), volumeCoordinates(:, 3), volumeCoordinates(:, 4));
    data = volume(indices);
    data = reshape(data, [numberOfCoordinates, numberOfVolumes])';
else
    data = spm_get_data(allVolumes, coordinates);
end





end %end function









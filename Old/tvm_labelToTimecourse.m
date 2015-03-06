function output = tvm_labelToTimecourse(configuration)

memtic
subjectDirectory    = configuration.SubjectDirectory;

functionalScan = spm_vol([subjectDirectory configuration.MeanFolder configuration.MeanName]);    
allVolumes = dir([subjectDirectory configuration.FunctionalFolder '*.nii']);
allVolumes = [repmat([subjectDirectory configuration.FunctionalFolder], [length(allVolumes), 1]), char({allVolumes.name})];

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

    timecourses{label} = mean(spm_get_data(allVolumes, coordinates(:, 1:3)'), 2);
end
clear x y z selectionGrid

save([subjectDirectory configuration.Timecourse], 'timecourses');

output = memtoc;

end %end function






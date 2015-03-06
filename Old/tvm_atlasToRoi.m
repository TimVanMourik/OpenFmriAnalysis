function output = tvm_atlasToRoi(configuration)

memtic
subjectDirectory    = configuration.SubjectDirectory;

referenceVolume = spm_vol([subjectDirectory configuration.MeanFolder configuration.MeanName]);

if ~exist([subjectDirectory configuration.Atlas(1:(end-4)) '.nii'], 'file')
    unix(['mri_convert ' subjectDirectory configuration.Atlas ' ' subjectDirectory configuration.Atlas(1:(end-4)) '.nii']);
end
labelledVolume = spm_vol([subjectDirectory configuration.Atlas(1:(end-4)) '.nii']);
labelledVolume.volume = spm_read_vols(labelledVolume);

load([subjectDirectory configuration.CoregistrationMatrix], 'coregistrationMatrix')
transformation = coregistrationMatrix * referenceVolume.mat \ labelledVolume.mat;
transformation = transformation';

labelled = find(ismember(labelledVolume.volume, configuration.LabelOfInterest));

[x, y, z] = ind2sub(labelledVolume.dim, labelled);
coordinates = [x, y, z, ones(size(x))];
%bring coordinates to the correct space
coordinates = coordinates * transformation;
%make sure they correspond to volume indices
coordinates = round(coordinates);
%remove duplicates
coordinates = unique(coordinates, 'rows');
%remove coordinates outside the volume
coordinates = coordinates(all(~bsxfun(@gt, coordinates(:, 1:3), referenceVolume.dim), 2), :);
coordinates = coordinates(all(bsxfun(@gt, coordinates(:, 1:3), [0, 0, 0]), 2), :);

indices = sub2ind(referenceVolume.dim, coordinates(1, :), coordinates(2, :), coordinates(3, :));
referenceVolume.volume = false(referenceVolume.dim);
referenceVolume.volume(indices) = true;
referenceVolume.dt = [1, 0];
referenceVolume.fname = configuration.LabelFile;

spm_write_vol(referenceVolume, referenceVolume.volume);

clear x y z labelledVolume timecourses

output = memtoc;

end %end function






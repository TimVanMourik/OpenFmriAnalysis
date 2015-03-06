function output = tvm_correlations(configuration)

memtic
subjectDirectory    = configuration.SubjectDirectory;

functionalScan = spm_vol([subjectDirectory configuration.MeanFolder configuration.MeanName]);    
allVolumes = dir([subjectDirectory configuration.SmoothingFolder 's*.nii']);
allVolumes = [repmat([subjectDirectory configuration.SmoothingFolder], [length(allVolumes), 1]), char({allVolumes.name})];

if ~exist([subjectDirectory 'FreeSurfer/mri/' configuration.Atlas(1:(end-4)) '.nii'], 'file')
    unix(['mri_convert ' subjectDirectory 'FreeSurfer/mri/' configuration.Atlas ' ' subjectDirectory 'FreeSurfer/mri/' configuration.Atlas(1:(end-4)) '.nii']);
end
labelledVolume = spm_vol([subjectDirectory 'FreeSurfer/mri/' configuration.Atlas(1:(end-4)) '.nii']);
labelledVolume.volume = spm_read_vols(labelledVolume);

load([subjectDirectory configuration.CoregistrationMatrix], 'coregistrationMatrix')
transformation = coregistrationMatrix * functionalScan.mat \ labelledVolume.mat;
transformation = transformation';

motionFile = strrep(ls([subjectDirectory configuration.MotionFile]), '\t', '');
motionParameters = importdata(motionFile(1:end - 1));
%Upon inspection of the motion parameters, the fluctuations were
%unrealistically large. Therefore it is bandpassed.
% motionParameters = bandpass(motionParameters, configuration.TR, 0, 0.05);

numberOfNuisance = length(configuration.NuisanceLabels);
nuisanceTimeCourses = zeros(length(allVolumes), numberOfNuisance);
for label = 1:numberOfNuisance
    labelled = find(ismember(labelledVolume.volume, configuration.NuisanceLabels(label)));

    [x, y, z] = ind2sub(labelledVolume.dim, labelled);
    coordinates = [x, y, z, ones(size(x))];
    %remove duplicates
    coordinates = unique(round(coordinates * transformation), 'rows');
    %remove coordinates outside the volume
    coordinates = coordinates(all(~bsxfun(@gt, coordinates(:, 1:3), functionalScan.dim), 2), :);
    coordinates = coordinates(all(bsxfun(@gt, coordinates(:, 1:3), [0, 0, 0]), 2), :);
    %if there are more than a million voxels, then a tenth of all voxels
    %will probably suffice.
%     if length(coordinates) > 10 ^ 6
%         coordinates = coordinates(1:10:length(coordinates), :);
%     end
    
    nuisanceTimeCourses(:, label) = sum(spm_get_data(allVolumes, coordinates(:, 1:3)'), 2);
end
clear x y z 

nuisance = [motionParameters nuisanceTimeCourses ones(length(allVolumes), 1)];

numberOfLabels = length(configuration.InterestLabels);
interestTimecourses = zeros(length(allVolumes), numberOfLabels);

for label = 1:numberOfLabels
    labelled = find(ismember(labelledVolume.volume, configuration.InterestLabels(label)));

    [x, y, z] = ind2sub(labelledVolume.dim, labelled);
    coordinates = [x, y, z, ones(size(x))];
    %remove duplicates
    coordinates = unique(round(coordinates * transformation), 'rows');
    %remove coordinates outside the volume
    coordinates = coordinates(all(~bsxfun(@gt, coordinates(:, 1:3), functionalScan.dim), 2), :);
    coordinates = coordinates(all(bsxfun(@gt, coordinates(:, 1:3), [0, 0, 0]), 2), :);
    %if there are more than a million voxels, then a tenth of all voxels
    %will probably suffice.
    if length(coordinates) > 10 ^ 6
        coordinates = coordinates(1:10:length(coordinates), :);
    end

    timecourses = spm_get_data(allVolumes, coordinates(:, 1:3)');

    A = nuisance \ timecourses;
    interestTimecourses(:, label) = bandpass(sum(timecourses - nuisance * A, 2), configuration.TR, configuration.BandpassLower, configuration.BandpassUpper);
end
clear x y z labelledVolume timecourses

correlations = cell(length(configuration.InterestLabels), 1);

for i = 1:length(correlations)
    correlations{i}  = zeros(functionalScan.dim);
end

numberOfVoxels = prod(functionalScan.dim);
voxelsPerSlice = numberOfVoxels / functionalScan.dim(3);
for i = 1:functionalScan.dim(3)
    indexRange = voxelsPerSlice * (i - 1) + (1:voxelsPerSlice);
    [x, y, z] = ind2sub(functionalScan.dim, indexRange);
    sliceTimeValues = spm_get_data(allVolumes, [x; y; z]);
    for j = 1:length(correlations)
        A = nuisance \ sliceTimeValues;
        correlations{j}(indexRange) = corr(interestTimecourses(:, j), bandpass(sliceTimeValues - nuisance * A, configuration.TR, configuration.BandpassLower, configuration.BandpassUpper));
    end
end

for i = 1:length(correlations)
    correlations{i}(isnan(correlations{i})) = 0;
    correlationVolume = functionalScan;
    correlationVolume.descrip = configuration.Descriptions{i};
    correlationVolume.dt = [16, 0];
    correlationVolume.fname = [subjectDirectory configuration.FileNames{i}];
    spm_write_vol(correlationVolume, correlations{i});
end

output = memtoc;

end %end function






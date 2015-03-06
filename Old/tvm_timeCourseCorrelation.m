function output = tvm_timeCourseCorrelation(configuration)

memtic
subjectDirectory    = configuration.SubjectDirectory;

functionalScan = spm_vol([subjectDirectory configuration.MeanFolder configuration.MeanName]);    
allVolumes = dir([subjectDirectory configuration.FunctionalFolder '*.nii']);
allVolumes = [repmat([subjectDirectory configuration.FunctionalFolder], [length(allVolumes), 1]), char({allVolumes.name})];

if ~exist([subjectDirectory 'FreeSurfer/mri/' configuration.Atlas(1:(end-4)) '.nii'], 'file')
    unix(['mri_convert ' subjectDirectory 'FreeSurfer/mri/' configuration.Atlas ' ' subjectDirectory 'FreeSurfer/mri/' configuration.Atlas(1:(end-4)) '.nii']);
end
labelledVolume = spm_vol([subjectDirectory 'FreeSurfer/mri/' configuration.Atlas(1:(end-4)) '.nii']);
labelledVolume.volume = spm_read_vols(labelledVolume);

load([subjectDirectory configuration.CoregistrationMatrix], 'coregistrationMatrix')
transformation = coregistrationMatrix * functionalScan.mat \ labelledVolume.mat;
transformation = transformation';

%% Load Nuisance
load([subjectDirectory configuration.Nuisance], 'timecourses');
nuisanceTimeCourses = [timecourses{:}]; %#ok<NODEF>
motionFile = strrep(ls([subjectDirectory configuration.MotionFile]), '\t', '');
motionParameters = importdata(motionFile(1:end - 1));

load([subjectDirectory configuration.Timecourses], 'timecourses');
nuisance = [motionParameters nuisanceTimeCourses ones(size(motionParameters, 1), 1)];

%% Bandpass input time course
load([subjectDirectory configuration.Timecourses], 'timecourses');
inputTimeCourses = timecourses;
for i = 1:length(inputTimeCourses)
    A = nuisance \ inputTimeCourses{i};
    inputTimeCourses{i} = bandpass(inputTimeCourses{i} - nuisance * A, configuration.TR, configuration.BandpassLower, configuration.BandpassUpper); %#ok<AGROW>
end

numberOfLabels = length(configuration.Labels);
timecourses = cell(numberOfLabels, 1);
correlations = cell(numberOfLabels, length(inputTimeCourses));
correlationVolume = cell(numberOfLabels, length(inputTimeCourses));
for label = 1:numberOfLabels
    labelled = find(ismember(labelledVolume.volume, configuration.Labels{label}));

    [x, y, z] = ind2sub(labelledVolume.dim, labelled);
    coordinates = [x, y, z, ones(size(x))];
    %remove duplicates
    coordinates = unique(round(coordinates * transformation), 'rows');
    %remove coordinates outside the volume
    coordinates = coordinates(all(~bsxfun(@gt, coordinates(:, 1:3), functionalScan.dim), 2), :);
    coordinates = coordinates(all(bsxfun(@gt, coordinates(:, 1:3), [0, 0, 0]), 2), :);
    %these coordinates are the [N X 4] coordinates in the functional volume
    %that are labelled with the input label
    
    
    timecourses{label} = spm_get_data(allVolumes, coordinates(:, 1:3)');

    A = nuisance \ timecourses{label};
    timecourses{label} = bandpass(timecourses{label} - nuisance * A, configuration.TR, configuration.BandpassLower, configuration.BandpassUpper); %#ok<AGROW>

    for i = 1:length(inputTimeCourses)
        correlations{label, i} = corr(timecourses{label}, inputTimeCourses{i});
        correlationVolume{label, i} = zeros(functionalScan.dim);
        indices = sub2ind(functionalScan.dim, coordinates(:, 1), coordinates(:, 2), coordinates(:, 3));
        correlationVolume{label, i}(indices) = correlations{label, i};
    end
    
end

clear x y z selectionGrid

save([subjectDirectory configuration.ROI], 'correlationVolume');

output = memtoc;

end %end function






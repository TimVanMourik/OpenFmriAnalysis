function output = tvm_smoothEpis(configuration)

memtic
subjectDirectory    = configuration.SubjectDirectory;

allVolumes = dir([subjectDirectory configuration.RealignmentFolder '*.nii']);
allVolumes = char({allVolumes.name});
numberOfVolumes = length(allVolumes);
newVolumes = allVolumes;
newVolumes(:, 1) = 's';
allVolumes = [repmat([subjectDirectory configuration.RealignmentFolder], [length(allVolumes), 1]), char(allVolumes)];
newVolumes = [repmat([subjectDirectory configuration.SmoothingFolder], [length(newVolumes), 1]), char(newVolumes)];
for i = 1:numberOfVolumes
    spm_smooth(allVolumes(i, :), newVolumes(i, :), configuration.SmoothingKernel);
end

output = memtoc;

end %end function






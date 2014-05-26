function output = tvm_designMatrixToTimeCourse(configuration)

memtic

subjectDirectory = configuration.SubjectDirectory;
%save design matrix
load([subjectDirectory configuration.DesignMatrix], 'design');

allVolumes = dir([subjectDirectory configuration.FunctionalFolder '*.nii']);
allVolumes = char({allVolumes.name});
allVolumes = [repmat([subjectDirectory configuration.FunctionalFolder], [length(allVolumes), 1]), char(allVolumes)];

timeCourses = zeros(size(design.DesignMatrix, 2), size(allVolumes, 1));
for layer = 1:size(allVolumes, 1)
    volume = spm_read_vols(spm_vol(allVolumes(layer, :)));
    voxelValues = volume(design.Indices);
    timeCourses(: ,layer) = design.DesignMatrix \ voxelValues;
end

output = memtoc;

end %end function

%%
% 
% v = zeros(size(volume));
% v(design.Indices) = design.DesignMatrix * timeCourses(:, layer);
% a = spm_vol(allVolumes(layer, :))
% a.fname = 'Test12.nii';
% spm_write_vol(a, v);
% 


















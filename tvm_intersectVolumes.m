function output = tvm_intersectVolumes(configuration)

memtic
%Load the volume data
subjectDirectory = configuration.SubjectDirectory;

for i = 1:length(configuration.Input)
    inputVolume = spm_vol([subjectDirectory configuration.Input{i}]);
    inputVolume.volume = spm_read_vols(inputVolume);
    for j = 1:length(configuration.IntersectVolumes);
        intersectVolume = spm_vol([subjectDirectory configuration.IntersectVolumes{j}]);
        intersectVolume.volume = spm_read_vols(intersectVolume);
        inputVolume.volume = inputVolume.volume & intersectVolume.volume;
    end
    inputVolume.fname = [subjectDirectory configuration.Output{i}];
    spm_write_vol(inputVolume, inputVolume.volume);
end

output = memtoc;

end %end function
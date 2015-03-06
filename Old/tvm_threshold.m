function output = tvm_threshold(configuration)

memtic
subjectDirectory    = configuration.SubjectDirectory;

folderContent = dir([subjectDirectory configuration.CorrelationFolder '*.nii']);
folderContent = {folderContent.name};
for volume = 1:length(folderContent)
    correlationVolume = spm_vol([subjectDirectory configuration.CorrelationFolder folderContent{volume}]);
    [folder, fileName, extension] = fileparts(correlationVolume.fname);
    if stringEndsWith(fileName, configuration.Suffix) 
        continue;
    end
    correlationVolume.volume = spm_read_vols(correlationVolume);
    correlationVolume.fname = [folder '/' fileName configuration.Suffix extension];
    correlationVolume.volume(abs(correlationVolume.volume) < configuration.Threshold) = 0;
    correlationVolume.descrip = [correlationVolume.descrip ' thresholded'];
    spm_write_vol(correlationVolume, correlationVolume.volume);    
end

output = memtoc;

end %end function

function boolean = stringEndsWith(someString, ending)

boolean = all(someString((end - length(ending) + 1):end) == ending);

end %end function




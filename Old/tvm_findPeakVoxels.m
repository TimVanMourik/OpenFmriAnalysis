function output = tvm_findPeakVoxels(configuration)

memtic
subjectDirectory    = configuration.SubjectDirectory;

peaks = cell(size(configuration.Peaks));

mniTemplate = spm_vol('/home/common/matlab/spm8/templates/T1.nii');
structural = spm_vol([subjectDirectory configuration.Structural]);
meanFunctional = spm_vol([subjectDirectory configuration.Functional]);

templateMatrix = spm_matrix(spm_coreg(mniTemplate, structural));
coregistrationMatrix = spm_matrix(spm_coreg(meanFunctional, structural));

for volume = 1:length(configuration.FileNames)
    peaks{volume} = zeros(size(configuration.Peaks{volume}, 1), 3);
    correlationVolume = spm_vol([subjectDirectory configuration.CorrelationFolder configuration.FileNames{volume}]);
    %load volume
    correlationVolume.volume = spm_read_vols(correlationVolume);
    %threshold volume
    correlationVolume.volume(abs(correlationVolume.volume) < configuration.Threshold) = 0;
    %find peaks in the volume
    [x, y, z] = ind2sub(correlationVolume.dim, find(imregionalmax(correlationVolume.volume) == 1));
    for i = 1:size(configuration.Peaks{volume}, 1)
        coordinate = configuration.Peaks{volume}(i, :);
        coordinate = coordinate * templateMatrix' / coregistrationMatrix' / meanFunctional.mat';
        allPeaks = [x, y, z];
        [~, index] = min(sum(bsxfun(@minus, allPeaks, coordinate(1:3)) .^ 2, 2));
        peaks{volume}(i, :) = allPeaks(index, :);
    end
end
save([subjectDirectory configuration.CorrelationFolder configuration.PeakFile], 'peaks')

output = memtoc;

end %end function










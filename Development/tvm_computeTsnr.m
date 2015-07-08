function tvm_computeTsnr(configuration)
% TVM_COMPUTETSNR
%   TVM_COMPUTETSNR(configuration)
%   
%
%   Copyright (C) Tim van Mourik, 2014, DCCN
%
%   configuration.SubjectDirectory
%   configuration.FunctionalDirectory

%% Parse configuration
subjectDirectory =      tvm_getOption(configuration, 'SubjectDirectory');
    %no default
functionalDirectory =   fullfile(subjectDirectory, tvm_getOption(configuration, 'FunctionalDirectory'));
    %no default
maskFile =              fullfile(subjectDirectory, tvm_getOption(configuration, 'Mask'));
    %no default

%%
allVolumes = dir(fullfile(functionalDirectory, '*.nii'));
allVolumes = char({allVolumes.name});
% numberOfVolumes = size(allVolumes, 1);
allVolumes = [repmat(functionalDirectory, [size(allVolumes, 1), 1]), char(allVolumes)];
allVolumes = spm_vol(allVolumes);

mask = spm_vol(maskFile);
mask.volume = spm_read_vols(mask);

temporalMean = zeros(mask.dim);
temporalStd = zeros(mask.dim);

numberOfVoxels = prod(mask.dim);
voxelsPerSlice = numberOfVoxels / mask.dim(3);


for slice = 1:mask.dim(3)
    indexRange = voxelsPerSlice * (slice - 1) + (1:voxelsPerSlice);
%     indexRange = indexRange(mask.volume(indexRange) == true);
    [x, y, z] = ind2sub(mask.dim, indexRange);
    
    sliceTimeValues = spm_get_data(allVolumes, [x; y; z]);
%     if highPass ~= 0
%         sliceTimeValues = tvm_highPassFilter(sliceTimeValues, tr, highPass);
%     end

  	temporalMean(indexRange) = mean(sliceTimeValues, 1);
    temporalStd(indexRange)  = std(sliceTimeValues, [], 1);
end


tSNR = (temporalMean ./ temporalStd);
tSNR(isnan(tSNR)) = 0;

mask.dt = [64, 0];
mask.fname = 'tSNR.nii';
spm_write_vol(mask, tSNR);

tSNR = sum(tSNR(:) .* mask.volume(:)) / sum(mask.volume(:));

end %end function

%tsnr Subject01 = 8.1979
%tsnr Subject02 = 21.4666




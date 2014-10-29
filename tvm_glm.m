function tvm_glm(configuration)
% TVM_GLM
%   TVM_GLM(configuration)
%   
%
%   Copyright (C) Tim van Mourik, 2014, DCCN
%
%   configuration.SubjectDirectory
%   configuration.Design
%   configuration.ReferenceVolume
%   configuration.FunctionalFolder
%   configuration.Mask
%   configuration.GlmOutput
%   configuration.ResidualSumOfSquares


%% Parse configuration
subjectDirectory =      tvm_getOption(configuration, 'SubjectDirectory');
    %no default
designFile =            fullfile(subjectDirectory, tvm_getOption(configuration, 'Design'));
    %no default
referenceVolumeFile =   fullfile(subjectDirectory, tvm_getOption(configuration, 'ReferenceVolume'));
    %no default
functionalFolder =      fullfile(subjectDirectory, tvm_getOption(configuration, 'FunctionalFolder'));
    %no default
glmFile =               fullfile(subjectDirectory, tvm_getOption(configuration, 'GlmOutput'));
    %no default
resVarFile =            fullfile(subjectDirectory, tvm_getOption(configuration, 'ResidualSumOfSquares'));
    %no default
highPass =              tvm_getOption(configuration, 'HighPass', 0);
    %no default
tr =                    tvm_getOption(configuration, 'TR', 1);
    %no default
roiMask =               tvm_getOption(configuration, 'Mask', []);
    %empty by default
if ~isempty(roiMask)
    roiMask = fullfile(subjectDirectory, roiMask);
end

    
%%
referenceVolume = spm_vol(referenceVolumeFile);
referenceVolume.dt = [16, 0];
load(designFile, 'design');
gmlOutput = zeros([referenceVolume.dim, size(design.DesignMatrix, 2)]);
residualSumOfSquares = zeros(referenceVolume.dim);
numberOfVoxels = prod(referenceVolume.dim);
voxelsPerSlice = numberOfVoxels / referenceVolume.dim(3);

allVolumes = dir([functionalFolder '*.nii']);
allVolumes = [repmat(functionalFolder, [length(allVolumes), 1]), char({allVolumes.name})];

if isempty(roiMask)
    mask = true(referenceVolume.dim);
else
    %double negation to make sure the mask is binary.
    mask = ~~spm_read_vols(spm_vol(roiMask));
end
% This is done per slice, otherwise you're loading in ALL functional data 
% at once. Computers don't like.
for slice = 1:referenceVolume.dim(3)
    indexRange = voxelsPerSlice * (slice - 1) + (1:voxelsPerSlice);
    indexRange = indexRange(mask(indexRange) == true);
    [x, y, z] = ind2sub(referenceVolume.dim, indexRange);
    
    sliceTimeValues = spm_get_data(allVolumes, [x; y; z]);
%     if highPass ~= 0
%         sliceTimeValues = tvm_highPassFilter(sliceTimeValues, tr, highPass);
%     end
    for i = 1:size(sliceTimeValues, 2)
        gmlOutput(x(i), y(i), z(i), :) = design.DesignMatrix \ sliceTimeValues(:, i);
        residualSumOfSquares(x(i), y(i), z(i)) = sum((sliceTimeValues(:, i) - design.DesignMatrix * squeeze(gmlOutput(x(i), y(i), z(i), :))) .^ 2);
    end
end

tvm_write4D(referenceVolume, gmlOutput, glmFile);

referenceVolume.fname = resVarFile;
spm_write_vol(referenceVolume, residualSumOfSquares);

end %end function








function tvm_glm(configuration)
% TVM_GLM
%   TVM_GLM(configuration)
%   @todo Add description
%
%   Copyright (C) Tim van Mourik, 2014-2017, DCCN
%
% Input:
%   i_SubjectDirectory
%   i_DesignMatrix
%   i_ReferenceVolume
%   i_SourceDirectory
%   i_FunctionalFiles
%   i_Mask
%   i_FunctionalSelection
% Output:
%   o_Betas
%   o_ResidualSumOfSquares


%% Parse configuration
subjectDirectory            = tvm_getOption(configuration, 'i_SubjectDirectory', pwd());
    % default: current working directory
designFile                  = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_DesignMatrix'));
    %no default
referenceVolumeFile         = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_ReferenceVolume'));
    %no default
functionalFolder            = tvm_getOption(configuration, 'i_SourceDirectory', '');
    % default: empty
functionalFiles             = tvm_getOption(configuration, 'i_FunctionalFiles', '');
    % default: empty
roiMask                     = tvm_getOption(configuration, 'i_Mask', []);
    %default: empty
functionalIndices           = tvm_getOption(configuration, 'i_FunctionalSelection', []);
    % default: empty
glmFile                     = fullfile(subjectDirectory, tvm_getOption(configuration, 'o_Betas'));
    %no default
resVarFile                  = fullfile(subjectDirectory, tvm_getOption(configuration, 'o_ResidualSumOfSquares'));
    %no default
if ~isempty(roiMask)
    roiMask = fullfile(subjectDirectory, roiMask);
end

definitions = tvm_definitions();  
    
%%
referenceVolume = spm_vol(referenceVolumeFile);
referenceVolume.dt = [16, 0];
load(designFile, definitions.GlmDesign);
design = eval(definitions.GlmDesign);

numberOfRegressors = size(design.DesignMatrix, 2);
gmlOutput = zeros([referenceVolume.dim, numberOfRegressors]);
residualSumOfSquares = zeros(referenceVolume.dim);
numberOfVoxels = prod(referenceVolume.dim);
voxelsPerSlice = numberOfVoxels / referenceVolume.dim(3);

if ~isempty(functionalFolder)
    if functionalFolder(end) ~= filesep()
        functionalFolder = [fullfile(subjectDirectory, functionalFolder), filesep()];
    end
    allVolumes = dir(fullfile(subjectDirectory, functionalFolder, '*.nii'));
    allVolumes = fullfile(subjectDirectory, functionalFolder, {allVolumes.name});
elseif ~isempty(functionalFiles)
    allVolumes = dir(fullfile(subjectDirectory, functionalFiles));
    [path, file, extension] = fileparts(functionalFiles);
    allVolumes = fullfile(subjectDirectory, path, {allVolumes.name});
end

if isempty(functionalIndices)
	functionalIndices = 1:size(allVolumes, 2);
end
allVolumes = spm_vol(allVolumes(functionalIndices));
allVolumes = vertcat(allVolumes{:});

if isempty(roiMask)
    mask = true(referenceVolume.dim);
else
    %double negation to make sure the mask is binary.
    mask = ~~spm_read_vols(spm_vol(roiMask));
end

% This is done per slice, otherwise you're loading in ALL functional data 
% at once. Computers don't like.
pseudoInverse = pinv(design.DesignMatrix);
for slice = 1:referenceVolume.dim(3)
    indexRange = voxelsPerSlice * (slice - 1) + (1:voxelsPerSlice);
    indexRange = indexRange(mask(indexRange) == true);
    [x, y, z] = ind2sub(referenceVolume.dim, indexRange);
    
    sliceTimeValues = spm_get_data(allVolumes, [x; y; z]);

    betas = pseudoInverse * sliceTimeValues;
    indices = repmat(indexRange, [numberOfRegressors, 1]);
    indices = bsxfun(@plus, indices, ((1:numberOfRegressors) - 1)' * prod(referenceVolume.dim));
    gmlOutput(indices) = betas(:);
    residualSumOfSquares(indexRange) = sum((sliceTimeValues - design.DesignMatrix * betas) .^ 2);
end

tvm_write4D(referenceVolume, gmlOutput, glmFile);

referenceVolume.fname = resVarFile;
spm_write_vol(referenceVolume, residualSumOfSquares);

end %end function








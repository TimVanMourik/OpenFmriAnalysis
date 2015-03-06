function tvm_filterFunctionals(configuration)
% TVM_SMOOTHFUNCTIONALS 
%   TVM_SMOOTHFUNCTIONALS(configuration)
%   
%
%   Copyright (C) Tim van Mourik, 2014, DCCN
%
%   configuration.SubjectDirectory
%   configuration.FunctionalDirectory
%   configuration.SmoothingDirectory
%   configuration.SmoothingKernel

%% Parse configuration
subjectDirectory =      tvm_getOption(configuration, 'i_SubjectDirectory');
    %no default
functionalDirectory =   fullfile(subjectDirectory, tvm_getOption(configuration, 'i_FunctionalDirectory'));
    %no default
smoothingDirectory =    fullfile(subjectDirectory, tvm_getOption(configuration, 'i_FilterDirectory'));
    % []
lowerCutOff =       tvm_getOption(configuration, 'p_LowPass', []);
    %no default
higherCutOff =       tvm_getOption(configuration, 'p_HighPass', []);
    % []
tr =       tvm_getOption(configuration, 'p_TR', 1);
    % []
    
%%
if isempty(lowerCutOff)
    lowerCutOff = -1;
else
    lowerCutOff = 1 / lowerCutOff / tr;   %Lower cut-off measured in volumes
end

if isempty(higherCutOff)
    higherCutOff = -1;
else
    higherCutOff = 1 / higherCutOff / tr; %Upper cut-off measured in volumes
end

allVolumes = dir(fullfile(functionalDirectory, '*.nii'));
allVolumes = char({allVolumes.name});
numberOfVolumes = size(allVolumes, 1);
newVolumes = allVolumes;
allVolumes = [repmat(functionalDirectory, [size(allVolumes, 1), 1]), char(allVolumes)];
newVolumes = [repmat(fullfile(smoothingDirectory, 'f'), [size(newVolumes, 1), 1]), char(newVolumes)];
zipVolumes = [newVolumes, repmat('.gz', [size(newVolumes, 1), 1])];
for i = 1:numberOfVolumes
    unix(sprintf('fslmaths %s -bptf %f %f %s; gunzip -f %s', allVolumes(i, :), higherCutOff, lowerCutOff, newVolumes(i, :), zipVolumes(i, :)));
end

end %end function






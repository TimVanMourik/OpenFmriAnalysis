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
subjectDirectory =      tvm_getOption(configuration, 'SubjectDirectory');
    %no default
functionalDirectory =   fullfile(subjectDirectory, tvm_getOption(configuration, 'FunctionalDirectory'));
    %no default
smoothingDirectory =    fullfile(subjectDirectory, tvm_getOption(configuration, 'FilterDirectory'));
    % []
lowerCutOff =       tvm_getOption(configuration, 'LowPass', []);
    %no default
higherCutOff =       tvm_getOption(configuration, 'HighPass', []);
    % []
tr =       tvm_getOption(configuration, 'TR', 1);
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
for i = 1:numberOfVolumes
    unix(sprintf('fslmaths %s -bptf %f %f %s', allVolumes(i, :), higherCutOff, lowerCutOff, newVolumes(i, :)));
    unix(sprintf('gunzip %s', newVolumes(i, :)));
end

end %end function






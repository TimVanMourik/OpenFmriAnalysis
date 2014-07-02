function tvm_smoothFunctionals(configuration)
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
smoothingDirectory =    fullfile(subjectDirectory, tvm_getOption(configuration, 'SmoothingDirectory'));
    %no default
smoothingKernel =       tvm_getOption(configuration, 'SmoothingKernel', [6, 6, 6]);
    %'[6, 6, 6]
    
%%
allVolumes = dir(fullfile(functionalDirectory, '*.nii'));
allVolumes = char({allVolumes.name});
numberOfVolumes = size(allVolumes, 1);
newVolumes = allVolumes;
allVolumes = [repmat(functionalDirectory, [size(allVolumes, 1), 1]), char(allVolumes)];
newVolumes = [repmat(fullfile(smoothingDirectory, 's'), [size(newVolumes, 1), 1]), char(newVolumes)];
for i = 1:numberOfVolumes
    spm_smooth(allVolumes(i, :), newVolumes(i, :), smoothingKernel);
end

end %end function






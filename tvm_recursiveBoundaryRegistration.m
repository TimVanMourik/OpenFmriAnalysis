function tvm_recursiveBoundaryRegistration(configuration, registrationConfiguration)
% TVM_RECURSIVEBOUNDARYREGISTRATION 
%   TVM_RECURSIVEBOUNDARYREGISTRATION(configuration)
%   
%
%   Copyright (C) Tim van Mourik, 2014, DCCN
%
%   configuration.SubjectDirectory
%   configuration.FunctionalDirectory
%   configuration.SmoothingDirectory
%   configuration.SmoothingKernel

%% Parse configuration
subjectDirectory =      	tvm_getOption(configuration, 'i_SubjectDirectory');
    %no default
referenceFile =             fullfile(subjectDirectory, tvm_getOption(configuration, 'i_ReferenceVolume'));
    %no default
boundariesFile =            fullfile(subjectDirectory, tvm_getOption(configuration, 'i_Boundaries'));
    %no default
registeredBoundaries =   	fullfile(subjectDirectory, tvm_getOption(configuration, 'o_Registered'));
    %no default
maskFile =                  tvm_getOption(configuration, 'p_Mask', '');
    %no default
 
%%
referenceVolume = spm_read_vols(spm_vol(referenceFile));
load(boundariesFile, 'wSurface', 'pSurface', 'faceData');


if isempty(maskFile)
    mask = true(size(referenceVolume));
else
    maskFile = fullfile(subjectDirectory, maskFile);
    mask = ~~spm_read_vols(spm_vol(maskFile));
end

for hemisphere = 1:2
    [~, selectedVerticesW] = selectVertices(wSurface{hemisphere}, mask);
    [~, selectedVerticesP] = selectVertices(pSurface{hemisphere}, mask);
    selectedVertices = selectedVerticesW | selectedVerticesP;

    [wSurface{hemisphere}(selectedVertices, :), pSurface{hemisphere}(selectedVertices, :)] = boundaryRegistration(wSurface{hemisphere}(selectedVertices, :), pSurface{hemisphere}(selectedVertices, :), referenceVolume, registrationConfiguration);  %#ok<AGROW>
end

save(registeredBoundaries, 'wSurface', 'pSurface', 'faceData');


end %end function














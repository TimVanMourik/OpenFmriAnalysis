function tvm_recursiveBoundaryRegistration(configuration, registrationConfiguration)
% TVM_RECURSIVEBOUNDARYREGISTRATION 
%   TVM_RECURSIVEBOUNDARYREGISTRATION(configuration)
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
registeredBoundaries =   	fullfile(subjectDirectory, tvm_getOption(configuration, 'o_Boundaries'));
    %no default
maskFile =                  tvm_getOption(configuration, 'p_Mask', '');
    %no default
    
definitions = tvm_definitions();
%%
referenceVolume = spm_read_vols(spm_vol(referenceFile));
load(boundariesFile, definitions.WhiteMatterSurface, definitions.PialSurface, definitions.FaceData);
wSurface = eval(definitions.WhiteMatterSurface);
pSurface = eval(definitions.PialSurface);
faceData = eval(definitions.FaceData);

if isempty(maskFile)
    mask = true(size(referenceVolume));
else
    maskFile = fullfile(subjectDirectory, maskFile);
    mask = ~~spm_read_vols(spm_vol(maskFile));
end

transformStack = cell(size(wSurface)); 
for hemisphere = 1:2
    [~, selectedVerticesW] = selectVertices(wSurface{hemisphere}, mask);
    [~, selectedVerticesP] = selectVertices(pSurface{hemisphere}, mask);
    selectedVertices = selectedVerticesW | selectedVerticesP;

    [wSurface{hemisphere}(selectedVertices, :), pSurface{hemisphere}(selectedVertices, :), transformStack{hemisphere}] = tvm_recursiveRegistration(wSurface{hemisphere}(selectedVertices, :), pSurface{hemisphere}(selectedVertices, :), referenceVolume, registrationConfiguration);  
end

eval(tvm_changeVariableNames(definitions.WhiteMatterSurface, wSurface));
eval(tvm_changeVariableNames(definitions.PialSurface, pSurface));
eval(tvm_changeVariableNames(definitions.FaceData, faceData));
eval(tvm_changeVariableNames(definitions.TransformStack, transformStack));

save(registeredBoundaries, definitions.WhiteMatterSurface, definitions.PialSurface, definitions.FaceData, definitions.TransformStack);

end %end function










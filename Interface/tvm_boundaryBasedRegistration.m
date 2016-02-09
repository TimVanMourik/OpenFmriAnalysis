function tvm_boundaryBasedRegistration(configuration, registrationConfiguration)
% TVM_BOUNDARYBASEDREGISTRATION 
%   TVM_BOUNDARYBASEDREGISTRATION(configuration)
%   
%   configuration.SubjectDirectory
%   configuration.FunctionalDirectory
%   configuration.SmoothingDirectory
%   configuration.SmoothingKernel
%
%   Copyright (C) Tim van Mourik, 2014, DCCN
%

%% Parse configuration
subjectDirectory =      tvm_getOption(configuration, 'i_SubjectDirectory', pwd());
    %no default
referenceFile =         fullfile(subjectDirectory, tvm_getOption(configuration, 'i_ReferenceVolume'));
    %no default
coregistrationFileIn =  tvm_getOption(configuration, 'i_CoregistrationMatrix', []);
    %no default
coregistrationFileOut = tvm_getOption(configuration, 'o_CoregistrationMatrix', []);
    %no default
boundariesFileIn =      fullfile(subjectDirectory, tvm_getOption(configuration, 'i_Boundaries'));
    %no default
boundariesFileOut =     fullfile(subjectDirectory, tvm_getOption(configuration, 'o_Boundaries'));
    %no default
maskFile =              tvm_getOption(configuration, 'p_Mask', '');
    %no default

definitions = tvm_definitions();
    
%%
referenceVolume = spm_read_vols(spm_vol(referenceFile));

if isempty(maskFile)
    mask = true(size(referenceVolume));
else
    maskFile = fullfile(subjectDirectory, maskFile);
    mask = ~~spm_read_vols(spm_vol(maskFile));
end

load(boundariesFileIn, definitions.WhiteMatterSurface, definitions.PialSurface, definitions.FaceData);
wSurface = eval(definitions.WhiteMatterSurface);
pSurface = eval(definitions.PialSurface);
faceData = eval(definitions.FaceData);

for hemisphere = 1:2
    if size(wSurface{hemisphere}, 2) == 3
        wSurface{hemisphere} = [wSurface{hemisphere}, ones(size(wSurface{hemisphere}, 1), 1)]; 
        pSurface{hemisphere} = [pSurface{hemisphere}, ones(size(pSurface{hemisphere}, 1), 1)]; 
    end
end

registereSurfaceW = [wSurface{1}; wSurface{2}];
registereSurfaceP = [pSurface{1}; pSurface{2}];
[~, selectedVerticesW] = selectVertices(registereSurfaceW, mask);
[~, selectedVerticesP] = selectVertices(registereSurfaceP, mask);
selectedVertices = selectedVerticesW | selectedVerticesP;

[t, p] = tvm_BoundaryBasedRegistration(registereSurfaceW(selectedVertices, :), registereSurfaceP(selectedVertices, :), referenceVolume, registrationConfiguration);

for hemisphere = 1:2
    wSurface{hemisphere} = wSurface{hemisphere} * t;
    pSurface{hemisphere} = pSurface{hemisphere} * t;
end
eval(tvm_changeVariableNames(definitions.WhiteMatterSurface, wSurface));
eval(tvm_changeVariableNames(definitions.PialSurface, pSurface));
eval(tvm_changeVariableNames(definitions.FaceData, faceData));
save(boundariesFileOut, definitions.WhiteMatterSurface, definitions.PialSurface, definitions.FaceData);


if ~isempty(coregistrationFileOut)
    if ~isempty(coregistrationFileIn)
        load(fullfile(subjectDirectory, coregistrationFileIn), definitions.CoregistrationMatrix, definitions.RegistrationParameters);
        
        coregistrationMatrix = eval(definitions.CoregistrationMatrix);
        registrationParameters = eval(definitions.RegistrationParameters);

        coregistrationMatrix = coregistrationMatrix * t'; 
        if exist(definitions.RegistrationParameters, 'var')
            registrationParameters = registrationParameters + p; 
            
            eval(tvm_changeVariableNames(definitions.CoregistrationMatrix, coregistrationMatrix));
            eval(tvm_changeVariableNames(definitions.RegistrationParameters, registrationParameters));
            save(fullfile(subjectDirectory, coregistrationFileOut), definitions.CoregistrationMatrix, definitions.RegistrationParameters);
        else
            eval(tvm_changeVariableNames(definitions.CoregistrationMatrix, coregistrationMatrix));
            save(fullfile(subjectDirectory, coregistrationFileOut), definitions.CoregistrationMatrix);
        end      
    else
        coregistrationMatrix = t'; 
        registrationParameters = p; 
        eval(tvm_changeVariableNames(definitions.CoregistrationMatrix, coregistrationMatrix));
        eval(tvm_changeVariableNames(definitions.RegistrationParameters, registrationParameters));
        save(fullfile(subjectDirectory, coregistrationFileOut), definitions.CoregistrationMatrix, definitions.RegistrationParameters);
    end
end

end %end function






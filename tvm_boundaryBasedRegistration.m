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
subjectDirectory =      tvm_getOption(configuration, 'i_SubjectDirectory');
    %no default
referenceFile =         fullfile(subjectDirectory, tvm_getOption(configuration, 'i_ReferenceVolume'));
    %no default
coregistrationFile =    tvm_getOption(configuration, 'io_CoregistrationMatrix', []);
    %no default
boundariesFile =        fullfile(subjectDirectory, tvm_getOption(configuration, 'io_Boundaries'));
    %no default
maskFile =              tvm_getOption(configuration, 'p_Mask', '');
    %no default
    
%%
referenceVolume = spm_read_vols(spm_vol(referenceFile));

if isempty(maskFile)
    mask = true(size(referenceVolume));
else
    maskFile = fullfile(subjectDirectory, maskFile);
    mask = ~~spm_read_vols(spm_vol(maskFile));
end


backup(boundariesFile);
load(boundariesFile, 'wSurface', 'pSurface');

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

[t, p] = boundaryBasedRegistration(registereSurfaceW(selectedVertices, :), registereSurfaceP(selectedVertices, :), referenceVolume, registrationConfiguration);

for hemisphere = 1:2
    wSurface{hemisphere} = wSurface{hemisphere} * t;
    pSurface{hemisphere} = pSurface{hemisphere} * t;
end
save(boundariesFile, 'wSurface', 'pSurface');

backup(coregistrationFile);
if isempty(coregistrationFile)
    coregistrationMatrix = t;
    registrationParameters = p;
    save(coregistrationFile, 'coregistrationMatrix', 'registrationParameters');
else
    coregistrationFile = fullfile(subjectDirectory, coregistrationFile);
    if exist(coregistrationFile, 'file')
        load(coregistrationFile, 'coregistrationMatrix', 'registrationParameters');
        registrationParameters = registrationParameters + p; %#ok
        coregistrationMatrix = coregistrationMatrix * t'; %#ok
    else
        coregistrationMatrix = t'; %#ok
    end
    save(coregistrationFile, 'coregistrationMatrix', 'registrationParameters');
end

end %end function

function backup(backupFile)
if exist(backupFile, 'file')
    [root, file, extension] = fileparts(backupFile);
    copyfile(backupFile, fullfile(root, [file '_backup' extension]));
end
end %end function








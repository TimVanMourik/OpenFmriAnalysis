function tvm_boundaryBasedRegistration(configuration, registrationConfiguration)
% TVM_BOUNDARYBASEDREGISTRATION 
%   TVM_BOUNDARYBASEDREGISTRATION(configuration)
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
registeredBoundaries =   fullfile(subjectDirectory, tvm_getOption(configuration, 'Registered'));
    %no default
referenceFile =    fullfile(subjectDirectory, tvm_getOption(configuration, 'ReferenceVolume'));
    %no default
    
if isfield(configuration, 'Boundaries')
    boundaryMode = 'matFile';
    boundariesFile = fullfile(subjectDirectory, tvm_getOption(configuration, 'Boundaries'));
elseif isfield(configuration, 'BoundariesW') && isfield(configuration, 'BoundariesP')
    boundaryMode = 'FreeSurfer';
    boundaryWFile = fullfile(subjectDirectory, tvm_getOption(configuration, 'BoundariesW'));
    boundaryPFile = fullfile(subjectDirectory, tvm_getOption(configuration, 'BoundariesP'));
else
    error('TVM:tvm_createFigures:NoSurface', 'No surface specified');
end   
    
%%
referenceVolume = spm_read_vols(spm_vol(referenceFile));
switch boundaryMode
    case 'matFile';
       load(boundariesFile, 'wSurface', 'pSurface');
    case 'FreeSurfer'
        fileNames.SurfaceWhite	= boundaryWFile;
        fileNames.SurfacePial 	= boundaryPFile;
        [wSurface, pSurface] = tvm_loadFreeSurferAsciiFile(fileNames);
        wSurface = changeDimensions(wSurface, [256, 256, 256], size(referenceVolume));
        pSurface = changeDimensions(pSurface, [256, 256, 256], size(referenceVolume));
    otherwise
        error('TVM:tvm_createFigures:NoSurface', 'No surface specified');
end

for hemisphere = 1:2
    t = boundaryBasedRegistration(wSurface{hemisphere}, pSurface{hemisphere}, referenceVolume, registrationConfiguration);
    if size(wSurface{hemisphere}, 2) == 3
        wSurface{hemisphere} = [wSurface{hemisphere}, ones(size(wSurface{hemisphere}, 1), 1)];
        pSurface{hemisphere} = [pSurface{hemisphere}, ones(size(pSurface{hemisphere}, 1), 1)];
    end
    wSurface{hemisphere} = wSurface{hemisphere} * t;
    pSurface{hemisphere} = pSurface{hemisphere} * t;
end

save(registeredBoundaries, 'wSurface', 'pSurface');

end %end function










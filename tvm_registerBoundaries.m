function output = tvm_registerBoundaries(configuration, registrationConfiguration)

memtic
subjectDirectory    = configuration.SubjectDirectory;
volume              = spm_read_vols(spm_vol([subjectDirectory configuration.Functional]));

if isfield(configuration, 'Boundaries')
    load([subjectDirectory configuration.Boundaries], 'wSurface', 'pSurface');
elseif isfield(configuration, 'BoundariesW') && isfield(configuration, 'BoundariesP')
    fileNames.SurfaceWhite	= [subjectDirectory configuration.BoundariesW];
    fileNames.SurfacePial 	= [subjectDirectory configuration.BoundariesP];
    [wSurface, pSurface] = loadFreeSurferAsciiFile(fileNames);
    wSurface = changeDimensions(wSurface, [256, 256, 256], size(volume));
    pSurface = changeDimensions(pSurface, [256, 256, 256], size(volume));
else
    error('TVM:tvm_createFigures:NoSurface', 'No surface specified');
end

for hemisphere = 1:2
    [wSurface{hemisphere}, pSurface{hemisphere}] = boundaryRegistration(wSurface{hemisphere}, pSurface{hemisphere}, volume, registrationConfiguration); 
end

save([subjectDirectory configuration.Registered], 'wSurface', 'pSurface');

output = memtoc;

end %end function
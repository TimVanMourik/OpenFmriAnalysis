function output = tvm_registerBoundaries(configuration, registrationConfiguration)

memtic
subjectDirectory    = configuration.SubjectDirectory;
volume              = spm_read_vols(spm_vol([subjectDirectory configuration.Functional]));

if isfield(configuration, 'Boundaries')
    load([subjectDirectory configuration.Boundaries], 'wSurface', 'pSurface');
else
    error('TVM:tvm_createFigures:NoSurface', 'No surface specified');
end

for hemisphere = 1:2
    [wSurface{hemisphere}, pSurface{hemisphere}] = boundaryRegistration(wSurface{hemisphere}, pSurface{hemisphere}, volume, registrationConfiguration); 
end

save([subjectDirectory configuration.Registered], 'wSurface', 'pSurface');

output = memtoc;

end %end function
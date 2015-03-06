function output = tvm_createFigures(configuration)

memtic
subjectDirectory    = configuration.SubjectDirectory;
volume              = spm_read_vols(spm_vol([subjectDirectory configuration.Volume]));

if isfield(configuration, 'Boundaries')
    load([subjectDirectory configuration.Boundaries], 'w', 'p');
elseif isfield(configuration, 'BoundariesW') && isfield(configuration, 'BoundariesP')
    fileNames.SurfaceWhite	= [subjectDirectory configuration.BoundariesW];
    fileNames.SurfacePial 	= [subjectDirectory configuration.BoundariesP];
    [w, p] = loadFreeSurferAsciiFile(fileNames);
    w = changeDimensions(w, [256, 256, 256], size(volume));
    p = changeDimensions(p, [256, 256, 256], size(volume));
else
    error('TVM:tvm_createFigures:NoSurface', 'No surface specified');
end

if isfield(configuration, 'LabelLeft') && isfield(configuration, 'LabelRight')
    indicesLeft  = importLabelFile([configuration.SubjectDirectory configuration.LabelLeft]);
    indicesRight = importLabelFile([configuration.SubjectDirectory configuration.LabelRight]);
    
    w{1} = w{1}(indicesRight, :);
    p{1} = p{1}(indicesRight, :);
    w{2} = w{2}(indicesLeft, :);
    p{2} = p{2}(indicesLeft, :);
end

for slice = configuration.Slices
    showSlice(volume, slice, w, p, 'z');
    saveas(gca, sprintf('%s%s%s_slice%02d.fig', subjectDirectory, configuration.ImageFolder, configuration.ImageName, slice));
end

output = memtoc;

end %end function
function output = tvm_surfacesToBlender(configuration)

memtic

subjectDirectory = configuration.SubjectDirectory;
%%
l = strrep(configuration.Boundaries, '?', 'l');
unix(['fs2obj ' subjectDirectory l]);
[~, file, extension] = fileparts(l);
unix(['mv ' subjectDirectory, l, '.obj ', subjectDirectory, configuration.Blender, file, extension '.obj']);
unix(['facesFromObj ' subjectDirectory, configuration.Blender, file, extension '.obj ', subjectDirectory, configuration.Blender, file, extension '.faces']);
r = strrep(configuration.Boundaries, '?', 'r');
unix(['fs2obj ' subjectDirectory r]);
[~, file, extension] = fileparts(r);
unix(['mv ' subjectDirectory, r, '.obj ', subjectDirectory, configuration.Blender, file, extension '.obj']);
unix(['facesFromObj ' subjectDirectory, configuration.Blender, file, extension '.obj ', subjectDirectory, configuration.Blender, file, extension '.faces']);

%verticesFromObj rh.pial rh.pial.faces


output = memtoc;

end %end function







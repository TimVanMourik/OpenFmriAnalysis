function output = tvm_computeCurvature(configuration)

memtic

subjectDirectory = configuration.SubjectDirectory;

computeCurvature([subjectDirectory configuration.White], [subjectDirectory configuration.WhiteCurvature1], [subjectDirectory configuration.WhiteCurvature2]);
computeCurvature([subjectDirectory configuration.Pial], [subjectDirectory configuration.PialCurvature1], [subjectDirectory configuration.PialCurvature2]);

output = memtoc;

end %end function











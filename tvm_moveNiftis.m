function output = tvm_moveNiftis(configuration)

memtic;

subjectDirectory = configuration.SubjectDirectory;
dicoms = [subjectDirectory configuration.SourceDicoms];

definitions = tvm_definitions;

anatomicalData = definitions.anatomicalData;
anatomicals = [];
for i = 1:length(anatomicalData)
   folders = dir([dicoms anatomicalData{i}]);
   folders = folders([folders.isdir]);
   anatomicals = [anatomicals; {folders.name}];
end
destinationAnatomicals = [subjectDirectory configuration.DestinationAnatomicals];
for i = 1:length(anatomicals)
    movefile([dicoms anatomicals{i}], destinationAnatomicals);
end

functionalData = definitions.functionalData;
functionals=[];
for i = 1:length(functionalData)
    folders = dir([dicoms functionalData{i}]);
    folders = folders([folders.isdir]);
    functionals = [functionals; {folders.name}];
end
destinationFunctionals = [subjectDirectory configuration.DestinationFunctionals];
for i = 1:length(functionals)
    movefile([dicoms functionals{i} '/' '*.nii'], destinationFunctionals);  %to move functional folders remome '/' '*.nii'
end

output=memtoc;

end %end function
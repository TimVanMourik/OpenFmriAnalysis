function output = tvm_normaliseTimeCourse(configuration)

memtic

subjectDirectory = configuration.SubjectDirectory;
%save design matrix
for i = 1:length(configuration.TimeCourse)
    load([subjectDirectory configuration.TimeCourse{i}], 'timeCourses');

    for j = 1:length(timeCourses)
        timeCourses{j} = bsxfun(@rdivide, timeCourses{j}, mean(timeCourses{j}, 2));
    end

    save([subjectDirectory configuration.NormalisedTimeCourse{i}], 'timeCourses');
end
    
output = memtoc;

end %end function


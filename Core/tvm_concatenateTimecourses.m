function tvm_concatenateTimecourses(configuration)
% TVM_CONCATENATETIMECOURSES
%   TVM_CONCATENATETIMECOURSES(configuration)
%   
%
%   Copyright (C) Tim van Mourik, 2019, DCCN
%

%% Parse configuration
subjectDirectory        = tvm_getOption(configuration, 'i_SubjectDirectory', pwd());
    %no default
timeCourseFileInput     = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_TimeCourse'));
    %no default
timeCourseFileOutput    = fullfile(subjectDirectory, tvm_getOption(configuration, 'o_TimeCourse'));
    %no default

    
%%

load(timeCourseFileInput{1}, 'timeCourses');

concatenated = timeCourses;
for i = 2:length(timeCourseFileInput)
    if exist(timeCourseFileInput{i}, 'file')
        load(timeCourseFileInput{i}, 'timeCourses');
        for j = 1:length(timeCourses)
            concatenated{j} = [concatenated{j}, timeCourses{j}];
        end
        timeCourses = concatenated;
    end
end
save(timeCourseFileOutput, 'timeCourses');


end %end function








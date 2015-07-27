function tvm_design_timeCourse(configuration)
%   
%
%   Copyright (C) Tim van Mourik, 2015, DCCN
%

%% Parse configuration
subjectDirectory        = tvm_getOption(configuration, 'i_SubjectDirectory', '.');
    %no default
designFileIn            = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_Design'));
    %no default
designFileOut           = fullfile(subjectDirectory, tvm_getOption(configuration, 'o_Design'));
    %no default
    
definitions = tvm_definitions();

%%

tvm_workInProgress();

end %end function
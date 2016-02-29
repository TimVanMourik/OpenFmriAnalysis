function tvm_design_retroicor(configuration)
%   
%
%   Copyright (C) Tim van Mourik, 2015, DCCN
%

%% Parse configuration
subjectDirectory        = tvm_getOption(configuration, 'i_SubjectDirectory', '.');
    %no default
designFileOut           = fullfile(subjectDirectory, tvm_getOption(configuration, 'o_DesignMatrix'));
    %no default
  
definitions = tvm_definitions();

%%
tvm_workInProgress();
%not yet implemented

end %end function



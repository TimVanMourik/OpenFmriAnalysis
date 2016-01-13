function tvm_levelSetToObj(configuration)
% TVM_LEVELSETTOOBJ 
%   TVM_LEVELSETTOOBJ(configuration)
%   
%
%   Copyright (C) Tim van Mourik, 2015, DCCN
%
%   configuration.SubjectDirectory
%

%% Parse configuration
subjectDirectory        = tvm_getOption(configuration, 'i_SubjectDirectory');
    %no default
levelSetFile            = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_LevelSet'));
    %no default
objectFile              = fullfile(subjectDirectory, tvm_getOption(configuration, 'o_ObjFile'));
    %no default
    
definitions = tvm_definitions();

%%
levelSetToObj(levelSetFile, objectFile);

end










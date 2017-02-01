function tvm_levelSetToObj(configuration)
% TVM_LEVELSETTOOBJ
%   TVM_LEVELSETTOOBJ(configuration)
%   @todo Add description
%
%   Copyright (C) Tim van Mourik, 2015-2016, DCCN
%
% Input:
%   i_SubjectDirectory
%   i_LevelSet
% Output:
%   o_ObjFile
%

%% Parse configuration
subjectDirectory =      tvm_getOption(configuration, 'i_SubjectDirectory', pwd());
    % default: current working directory
levelSetFile            = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_LevelSet'));
    %no default
objectFile              = fullfile(subjectDirectory, tvm_getOption(configuration, 'o_ObjFile'));
    %no default
    
% definitions = tvm_definitions();

%%
levelSetToObj(levelSetFile, objectFile);

end










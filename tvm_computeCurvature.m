function tvm_computeCurvature(configuration)
% TVM_COMPUTECURVATURE 
%   TVM_COMPUTECURVATURE(configuration)
%   
%
%   Copyright (C) Tim van Mourik, 2014, DCCN
%
%   configuration.SubjectDirectory
%   configuration.White
%   configuration.Pial
%   configuration.WhiteCurvature1
%   configuration.WhiteCurvature2
%   configuration.PialCurvature1
%   configuration.PialCurvature2

%% Parse configuration
subjectDirectory 	= tvm_getOption(configuration, 'SubjectDirectory');
    %no default
white               = fullfile(subjectDirectory, tvm_getOption(configuration, 'White'));
    %no default
pial                = fullfile(subjectDirectory, tvm_getOption(configuration, 'Pial'));
    %no default
whiteK1             = fullfile(subjectDirectory, tvm_getOption(configuration, 'WhiteCurvature1'));
    %no default
whiteK2             = fullfile(subjectDirectory, tvm_getOption(configuration, 'WhiteCurvature2'));
    %no default
pialK1              = fullfile(subjectDirectory, tvm_getOption(configuration, 'PialCurvature1'));
    %no default
pialK2              = fullfile(subjectDirectory, tvm_getOption(configuration, 'PialCurvature2'));
    %no default
    
%%
tvm_computeCurvature(white, whiteK1, whiteK2);
tvm_computeCurvature(pial, pialK1, pialK2);

end %end function











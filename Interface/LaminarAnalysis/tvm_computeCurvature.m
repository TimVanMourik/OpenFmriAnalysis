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
subjectDirectory =      tvm_getOption(configuration, 'i_SubjectDirectory', pwd());
    %no default
white               = tvm_getOption(configuration, 'i_White');
    %no default
pial                = tvm_getOption(configuration, 'i_Pial');
    %no default
whiteK1             = tvm_getOption(configuration, 'o_WhiteCurvature1');
    %no default
whiteK2             = tvm_getOption(configuration, 'o_WhiteCurvature2');
    %no default
pialK1              = tvm_getOption(configuration, 'o_PialCurvature1');
    %no default
pialK2              = tvm_getOption(configuration, 'o_PialCurvature2');
%     %no default

%%


cfg = [];
cfg.i_SubjectDirectory = subjectDirectory;
cfg.i_SDF = white;
cfg.o_PrimaryCurvature1 = whiteK1;
cfg.o_SecondaryCurvature2 = whiteK2;
tvm_computeCurvatureFromSdf(cfg);

cfg = [];
cfg.i_SubjectDirectory = subjectDirectory;
cfg.i_SDF = pial;
cfg.o_PrimaryCurvature1 = pialK1;
cfg.o_SecondaryCurvature2 = pialK2;
tvm_computeCurvatureFromSdf(cfg);

end %end function











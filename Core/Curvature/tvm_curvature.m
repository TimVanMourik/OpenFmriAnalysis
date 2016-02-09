function tvm_curvature(order)
% TVM_COMPUTECURVATURE 
%   TVM_COMPUTECURVATURE(configuration)
%   
%
%   Copyright (C) Tim van Mourik, 2014, DCCN
%
%   configuration.SubjectDirectory
%   configuration.White
%   configuration.Pial
%   configuration.WhiteCurvature
%   configuration.PialCurvature

%% Parse configuration
subjectDirectory =      tvm_getOption(configuration, 'i_SubjectDirectory', pwd());
    %no default
white               = tvm_getOption(configuration, 'i_WhiteGradient');
    %no default
pial                = tvm_getOption(configuration, 'i_PialGradient');
    %no default
whiteK             = tvm_getOption(configuration, 'o_WhiteCurvature');
    %no default
pialK              = tvm_getOption(configuration, 'o_PialCurvature');
    %no default
order               = tvm_getOption(configuration, 'i_Order', 10);
    % 10

%%
stencil = tvm_getGradientStencil3D(order);
filter = tvm_getGradientFilter3D(order);


end %end function
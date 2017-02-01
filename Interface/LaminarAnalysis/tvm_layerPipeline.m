function tvm_layerPipeline(configuration)
% TVM_LAYERPIPELINE
%   TVM_LAYERPIPELINE(configuration)
%   Wrapper around all layering functions
%   @todo Expand description
%
%   Copyright (C) Tim van Mourik, 2014-2016, DCCN
%
% Input:
%   i_SubjectDirectory
%   ...
% Output:
%   ...
%

%%
try
    tvm_boundariesToObj(configuration);    
    configuration.i_ObjWhite        = configuration.o_ObjWhite;
    configuration.i_ObjPial         = configuration.o_ObjPial;
catch err
    warning('%s\nSkipping tvm_boundariesToObj', err.message);
end
%%
try
    tvm_makeLevelSet(configuration);
    configuration.i_White                   = configuration.o_White;
    configuration.i_Pial                    = configuration.o_Pial;
catch err
    warning('%s\nSkipping tvm_makeLevelSet', err.message);
end
%%
try
    tvm_laplacePotentials(configuration);
    configuration.i_Potential               = configuration.o_LaplacePotential;
    configuration.i_Normalise               = true;
catch err
    warning('%s\nSkipping tvm_laplacePotentials', err.message);
end
%%
try
    tvm_gradient(configuration);
    configuration.i_VectorField             = configuration.o_Gradient ;
    configuration.o_Divergence              = configuration.o_Curvature;
catch err
    warning('%s\nSkipping tvm_gradient', err.message);
end
%%
try
    tvm_computeDivergence(configuration);
    configuration.i_Curvature               = configuration.o_Curvature;
    configuration.i_Gradient                = configuration.o_Gradient;
catch err
    warning('%s\nSkipping tvm_computeDivergence', err.message);
end

%%
try
    tvm_volumetricLayering(configuration);
catch err
    warning('%s\nSkipping tvm_volumetricLayering', err.message);
end

end %end function




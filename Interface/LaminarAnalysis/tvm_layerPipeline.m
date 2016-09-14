function tvm_layerPipeline(configuration)
% TVM_LAYERPIPELINE 
%   TVM_LAYERPIPELINE(configuration)
%   
%   Copyright (C) Tim van Mourik, 2014, DCCN
%

% if isfield(configuration, 'o_ObjWhite') && ~isempty(strfind(configuration.o_ObjWhite, '?'))
%     twoHemispheres = true;
% else
%     twoHemispheres = false;
% end
% 
% if twoHemispheres
%     try
%         tvm_boundariesToObj(configuration);    
%         configuration.i_ObjWhite        = configuration.o_ObjWhite;
%         configuration.i_ObjPial         = configuration.o_ObjPial;
%     catch
%         warning('Skipping tvm_boundariesToObj');
%     end
% end

%%
try
    tvm_boundariesToObj(configuration);    
    configuration.i_ObjWhite        = configuration.o_ObjWhite;
    configuration.i_ObjPial         = configuration.o_ObjPial;
catch err
    warning([err.message '\nSkipping tvm_boundariesToObj']);
end
%%
try
    tvm_makeLevelSet(configuration);
    configuration.i_White                   = configuration.o_White;
    configuration.i_Pial                    = configuration.o_Pial;
catch err
    warning([err.message '\nSkipping tvm_makeLevelSet']);
end
%%
try
    tvm_laplacePotentials(configuration);
    configuration.i_Potential               = configuration.o_LaplacePotential;
    configuration.i_Normalise               = true;
catch err
    warning([err.message '\nSkipping tvm_laplacePotentials']);
end
%%
try
    tvm_gradient(configuration);
    configuration.i_VectorField             = configuration.o_Gradient ;
    configuration.o_Divergence              = configuration.o_Curvature;
catch err
    warning([err.message '\nSkipping tvm_gradient']);
end
%%
try
    tvm_computeDivergence(configuration);
    configuration.i_Curvature               = configuration.o_Curvature;
    configuration.i_Gradient                = configuration.o_Gradient;
catch err
    warning([err.message '\nSkipping tvm_computeDivergence']);
end

%%
try
    tvm_volumetricLayering(configuration);
catch err
    warning([err.message '\nSkipping tvm_volumetricLayering']);
end

end %end function




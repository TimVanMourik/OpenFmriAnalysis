function tvm_layerPipeline(configuration)
% TVM_LAYERPIPELINE 
%   TVM_LAYERPIPELINE(configuration)
%   
%   Copyright (C) Tim van Mourik, 2014, DCCN
%

if isfield(configuration, 'o_ObjWhite') && ~isempty(strfind(configuration.o_ObjWhite, '?'))
    twoHemispheres = true;
else
    twoHemispheres = false;
end

if twoHemispheres
    try
        tvm_boundariesToObj(configuration);    
        configuration.i_ObjWhite        = configuration.o_ObjWhite;
        configuration.i_ObjPial         = configuration.o_ObjPial;
    catch
        warning('Skipping tvm_boundariesToObj\n');
    end
    %%
    try
        tvm_makeLevelSet(configuration);
        configuration.i_White                   = configuration.o_White;
        configuration.i_Pial                    = configuration.o_Pial;
    catch
        warning('Skipping tvm_makeLevelSet\n');
    end
    %%
    try
        tvm_laplacePotentials(configuration);
        configuration.i_Potential               = configuration.o_LaplacePotential;
        configuration.i_Normalise               = true;
        configuration.i_Order                   = 2;
    catch
        warning('Skipping tvm_laplacePotentials\n');
    end
    %%
    try
        tvm_gradient(configuration);
        configuration.i_VectorField             = configuration.o_Gradient ;
        configuration.o_Divergence              = configuration.o_Curvature;
    catch
        warning('Skipping tvm_gradient\n');
    end
    %%
    try
        tvm_computeDivergence(configuration);
        configuration.i_Curvature               = configuration.o_Curvature;
        configuration.i_Gradient                = configuration.o_Gradient;
    catch
        warning('Skipping tvm_computeDivergence\n');
    end
    %%
    try
        tvm_volumetricLayering(configuration);
    catch
        warning('Skipping tvm_volumetricLayering\n');
    end
    %%
%     try
%         epsilon = 0.01;
%         configuration.i_Epsilon = epsilon;
%         tvm_leprincePotential(configuration);
%         configuration.i_Potential               = configuration.o_EquivolumePotential;
%     catch
%         warning('Skipping tvm_leprincePotential\n');
%     end
%     %%
%     try
%         tvm_potentialToLayers(configuration);
%     catch
%         warning('Skipping tvm_potentialToLayers\n');
%     end
else
    %%
    try
        tvm_boundariesToObj(configuration);    
        configuration.i_ObjWhite        = configuration.o_ObjWhite;
        configuration.i_ObjPial         = configuration.o_ObjPial;
    catch
        warning('Skipping tvm_boundariesToObj\n');
    end
    %%
    try
        tvm_makeLevelSet(configuration);
        configuration.i_White                   = configuration.o_White;
        configuration.i_Pial                    = configuration.o_Pial;
    catch
        warning('Skipping tvm_makeLevelSet\n');
    end
    %%
    try
        tvm_laplacePotentials(configuration);
        configuration.i_Potential               = configuration.o_LaplacePotential;
        configuration.i_Normalise               = true;
        configuration.i_Order                   = 2;
    catch
        warning('Skipping tvm_laplacePotentials\n');
    end
    %%
    try
        tvm_gradient(configuration);
        configuration.i_VectorField             = configuration.o_Gradient ;
        configuration.o_Divergence              = configuration.o_Curvature;
    catch
        warning('Skipping tvm_gradient\n');
    end
    %%
    try
        tvm_computeDivergence(configuration);
        configuration.i_Curvature               = configuration.o_Curvature;
        configuration.i_Gradient                = configuration.o_Gradient;
    catch
        warning('Skipping tvm_computeDivergence\n');
    end
    %%
    try
        tvm_volumetricLayering(configuration);
    catch
        warning('Skipping tvm_volumetricLayering\n');
    end
    %%
%     try
%         tvm_leprincePotential(configuration);
%         configuration.i_Potential               = configuration.o_EquivolumePotential;
%     catch
%         warning('Skipping tvm_leprincePotential\n');
%     end
%     %%
%     try
%         tvm_potentialToLayers(configuration);
%     catch
%         warning('Skipping tvm_potentialToLayers\n');
%     end
end

end %end function




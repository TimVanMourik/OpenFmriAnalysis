function tvm_layerPipeline(configuration)

tvm_boundariesToObj(configuration);
tvm_makeLevelSet(configuration);
tvm_computeCurvature(configuration);
tvm_volumetricLayering(configuration);

end %end function


























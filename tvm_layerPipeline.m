function output = tvm_layerPipeline(configuration)

memtic

tvm_boundariesToObj(configuration);
tvm_makeLevelSet(configuration);
tvm_computeCurvature(configuration);
tvm_volumetricLayering(configuration);

output = memtoc;

end %end function


























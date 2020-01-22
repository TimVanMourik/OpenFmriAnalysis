#This is a Nipype generator. Warning, here be dragons.
#!/usr/bin/env python

import sys
import nipype
import nipype.pipeline as pe


































#Create a workflow to connect all those nodes
analysisflow = nipype.Workflow('MyWorkflow')
analysisflow.connect(tvm_design_empty, "o_DesignMatrix", tvm_design_stimulus, "i_DesignMatrix")
analysisflow.connect(tvm_design_stimulus, "o_DesignMatrix", tvm_design_constant, "i_DesignMatrix")
analysisflow.connect(tvm_design_constant, "o_DesignMatrix", tvm_design_highpassFilter, "i_DesignMatrix")
analysisflow.connect(tvm_design_highpassFilter, "o_DesignMatrix", tvm_design_motionRegression, "i_DesignMatrix")
analysisflow.connect(tvm_design_motionRegression, "o_DesignMatrix", tvm_design_retroicor, "i_DesignMatrix")
analysisflow.connect(tvm_design_retroicor, "o_DesignMatrix", tvm_design_retroicor_1, "i_DesignMatrix")
analysisflow.connect(tvm_design_retroicor_1, "o_DesignMatrix", tvm_regressConfounds, "i_DesignMatrix")
analysisflow.connect(tvm_realignFunctionals, "o_OutputDirectory", tvm_regressConfounds, "i_FunctionalFolder")
analysisflow.connect(tvm_regressConfounds, "o_FilteredFolder", tvm_smoothFunctionals, "i_SourceDirectory")
analysisflow.connect(tvm_smoothFunctionals, "o_OutputDirectory", tvm_glm, "i_FunctionalFiles")
analysisflow.connect(tvm_glm, "o_Betas", tvm_glmToTMap, "i_Betas")
analysisflow.connect(tvm_design_retroicor_1, "o_DesignMatrix", tvm_retroicorBackProject, "i_DesignMatrix")
analysisflow.connect(tvm_glm, "i_DesignMatrix", tvm_glmToFMap, "i_DesignMatrix")
analysisflow.connect(tvm_glm, "o_ResidualSumOfSquares", tvm_glmToFMap, "i_ResidualSumOfSquares")
analysisflow.connect(tvm_glm, "o_Betas", tvm_glmToFMap, "i_Betas")
analysisflow.connect(tvm_glm, "o_ResidualSumOfSquares", tvm_glmToTMap, "i_ResidualSumOfSquares")
analysisflow.connect(tvm_glm, "o_Betas", tvm_retroicorBackProject, "i_Betas")
analysisflow.connect(tvm_retroicorBackProject, "o_BackProjection", tvm_movieFrom4D, "i_VolumeFile")
analysisflow.connect(tvm_realignFunctionals, "o_MeanFunctional", tvm_useBbregister, "i_RegistrationVolume")
analysisflow.connect(tvm_reconAll, "o_FreeSurferFolder", tvm_useBbregister, "i_FreeSurferFolder")
analysisflow.connect(tvm_useBbregister, "o_Boundaries", tvm_recursiveBoundaryRegistration, "i_Boundaries")
analysisflow.connect(tvm_useBbregister, "o_Boundaries", tvm_volumeWithBoundariesToMovie, "i_Boundaries")
analysisflow.connect(tvm_useBbregister, "i_RegistrationVolume", tvm_volumeWithBoundariesToMovie, "i_ReferenceVolume")
analysisflow.connect(tvm_recursiveBoundaryRegistration, "i_ReferenceVolume", tvm_volumeWithBoundariesToMovie_1, "i_ReferenceVolume")
analysisflow.connect(tvm_recursiveBoundaryRegistration, "o_Boundaries", tvm_volumeWithBoundariesToMovie_1, "i_Boundaries")
analysisflow.connect(tvm_recursiveBoundaryRegistration, "o_DisplacementMap", tvm_boundariesToObj, "i_Boundaries")
analysisflow.connect(tvm_boundariesToObj, "o_ObjWhite", tvm_makeLevelSet, "i_ObjWhite")
analysisflow.connect(tvm_boundariesToObj, "o_ObjPial", tvm_makeLevelSet, "i_ObjPial")
analysisflow.connect(tvm_makeLevelSet, "o_White", tvm_laplacePotentials, "i_White")
analysisflow.connect(tvm_makeLevelSet, "o_Pial", tvm_laplacePotentials, "i_Pial")
analysisflow.connect(tvm_laplacePotentials, "o_LaplacePotential", tvm_gradient, "i_Potential")
analysisflow.connect(tvm_gradient, "o_Gradient", tvm_computeDivergence, "i_VectorField")
analysisflow.connect(tvm_computeDivergence, "o_Divergence", tvm_volumetricLayering, "i_Curvature")
analysisflow.connect(tvm_gradient, "o_Gradient", tvm_volumetricLayering, "i_Gradient")
analysisflow.connect(tvm_laplacePotentials, "i_Pial", tvm_volumetricLayering, "i_Pial")
analysisflow.connect(tvm_laplacePotentials, "i_White", tvm_volumetricLayering, "i_White")
analysisflow.connect(tvm_volumetricLayering, "o_LevelSet", tvm_levelSetToObj, "i_LevelSet")
analysisflow.connect(tvm_levelSetToObj, "o_ObjFile", tvm_objToBoundary, "i_ObjFile")
analysisflow.connect(tvm_objToBoundary, "o_BoundaryFile", tvm_volumeWithBoundariesToMovie_2, "i_Boundaries")
analysisflow.connect(tvm_volumetricLayering, "o_Layering", tvm_roiToDesignMatrix, "i_Layers")
analysisflow.connect(tvm_roiToDesignMatrix, "o_DesignMatrix", tvm_designMatrixToTimeCourse, "i_DesignMatrix")

#Run the workflow
plugin = 'MultiProc' #adjust your desired plugin here
plugin_args = {'n_procs': 1} #adjust to your number of cores
analysisflow.write_graph(graph2use='flat', format='png', simple_form=False)
analysisflow.run(plugin=plugin, plugin_args=plugin_args)

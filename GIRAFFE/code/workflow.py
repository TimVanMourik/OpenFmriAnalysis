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

#Run the workflow
plugin = 'MultiProc' #adjust your desired plugin here
plugin_args = {'n_procs': 1} #adjust to your number of cores
analysisflow.write_graph(graph2use='flat', format='png', simple_form=False)
analysisflow.run(plugin=plugin, plugin_args=plugin_args)

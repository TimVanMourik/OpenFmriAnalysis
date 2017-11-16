# OpenFmriAnalysis toolbox. 
Many of the functions for general fMRI preprocessing are wrappers for existing well-established neuroimaging tools. The wrappers should be seen as a consistent MATLAB command line interface to these functions, not as a reimplementation.
A large part of these functions are written for my own convenience. A substantial part is new method development, mainly regarding laminar analysis.

Before you start:
- Run the MATLAB function tvm_installLaminarAnalysisToolbox.m
- SPM needs to be in your MATLAB path (used throughout the toolbox)
- FreeSurfer and dcm2nii are used sporadically.
  - dcm2nii needs to be in the .profile if you want to convert dicoms to niftis
  - FreeSurfer needs to be installed and the setup needs to be in the .profile
  - At some point with some MATLAB versions, the following line needed to be added to your .bashrc:
    - `export LD_LIBRARY_PATH=.:$LD_LIBRARY_PATH`

All functions that are part of the main pipeline can be found in the [Interface](https://github.com/TimVanMourik/OpenFmriAnalysis/tree/master/Interface) section of the toolbox and all adhere to the same structure. Every function takes a single configuration structure as input. It does not generate output to the MATLAB workspace, but instead writes output to designated files as listed in the configuration. As an example:
```
cfg = [];
cfg.i_SubjectDirectory = ...;
cfg.i_ReferenceVolume = ...;
cfg.o_OutputFile = ...;
tvm_someFunction(cfg);
```
Fields that represent input files and parameters start with an `i_`, output fields start with an `o_`. Most functions have the option of a `i_SubjectDirectory`, being the root directory to which the input and output files are relative. It defaults to the current working directory. All interface functions are added to the Graphical User Interface [Porcupine](https://github.com/TimVanMourik/Porcupine).


Copyright (C) 2013-2017, Tim van Mourik, Donders Institute for Brain, Cognition and Behaviour, Radboud University Nijmegen, The Netherlands DCCN

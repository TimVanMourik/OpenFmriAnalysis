This is the ReadMe file of the OpenFmriAnalysis toolbox. Many of the functions for general fMRI preprocessing are wrappers for existing well-established neuroimaging tools. The wrappers should be seen as a consistent MATLAB command line interface to these functions, not as a reimplementation.
A large part of these functions are written for my own convenience. A substantial part is new method development, mainly regarding laminar analysis.

Copyright (C) 2013-2017, Tim van Mourik, Donders Institute for Brain, Cognition and Behaviour, Radboud University Nijmegen, The Netherlands DCCN

Before you start:
- Run the MATLAB function tvm_installLaminarAnalysisToolbox.m
- SPM needs to be in your MATLAB path (used throughout the toolbox)
- FreeSurfer and dcm2nii are used sporadically.
  - dcm2nii needs to be in the .profile if you want to convert dicoms to niftis
  - FreeSurfer needs to be installed and the setup needs to be in the .profile
  - At some point with some MATLAB versions, the following line needed to be added to your .bashrc:
    - `export LD_LIBRARY_PATH=.:$LD_LIBRARY_PATH`

	


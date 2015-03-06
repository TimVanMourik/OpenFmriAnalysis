This is the ReadMe file of the Laminar Analysis toolbox
(C) Tim van Mourik 2013-2015

Before you start:
-Run the MATLAB function tvm_installLaminarAnalysisToolbox.m
 
-SPM needs to be in your MATLAB path
-FieldTrip needs to be in your MATLAB path
-dcm2nii needs to be in the .profile
-FreeSurfer needs to be installed and the setup needs to be in the .profile
-to your .bashrc, add:
	export LD_LIBRARY_PATH=.:$LD_LIBRARY_PATH

	

@BUGS
-MAJOR:
-makeSignedDistancefield, the matrix file is written to the output file but not incorporated in the reading of the obj-file, while making the Signed Distance Field.
-tvm_makeLevelSet: NOTE: AN INDEXING PROBLEM (BY 1) WAS FOUND IN A THE PREPARATION FOR AN ISMRM ABSTRACT. FIND OUT WHERE THIS COMES FROM!

-MINOR:
-tvm_dicomsToNifti, make sure copies are  when function is rerun.
-tvm_constructTemporalDesignMatrix (line 63), check if the correct hrf parameters are loaded in

@TODO
-tvm_dicom_sort (line 36), use fullfile instead of []
-tvm_dicomsToNifti (line 21) make sure copies are removed
-tvm_dicomsToNifti (line 22) make display optional
-tvm_(registration), add inflation of mask parameter
-tvm_volumeToLabel (toTemporaryNames) check if file exists

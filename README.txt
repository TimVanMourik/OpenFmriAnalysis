This is the ReadMe file of the Laminar Analysis toolbox. Many of the functions for general fMRI preprocessing are wrappers for existing well-established neuroimaging tools. The wrappers should be seen as a consistent MATLAB command line interface to these functions, not as a reimplementation.
A large part of these functions are written for my own convenience. Another substantial part is new method development (recursive boundary registration, laminar analysis)
(C) Tim van Mourik 2013-2017

Before you start:
-Run the MATLAB function tvm_installLaminarAnalysisToolbox.m
 
-SPM needs to be in your MATLAB path
-FieldTrip needs to be in your MATLAB path (only if you want to the use qsub functions, cluster distribution)
-dcm2nii needs to be in the .profile (only if you actually want to convert dicoms to niftis)
-FreeSurfer needs to be installed and the setup needs to be in the .profile
-[probably only at the Donders Institute] to your .bashrc, add:
	export LD_LIBRARY_PATH=.:$LD_LIBRARY_PATH

	

@BUGS
-MAJOR:
-makeSignedDistancefield, the matrix file is written to the output file but not incorporated in the reading of the obj-file, while making the Signed Distance Field.
-tvm_makeLevelSet, crashes badly when an OBJ is read in that contains vertex normals or texture coordinates with the faces
-tvm_makeLevelSet, crashes badly when OBJ file is not a proper OBJ file in general

-MINOR:
-tvm_dicomsToNifti, make sure copies are removed when function is rerun.
-tvm_constructTemporalDesignMatrix (line 63), check if the correct hrf parameters are loaded in

@TODO
-tvm_dicom_sort (line 36), use fullfile instead of []
-tvm_dicomsToNifti (line 21) make sure copies are removed
-tvm_dicomsToNifti (line 22) make display optional
-tvm_(registration), add inflation of mask parameter
-tvm_volumeToLabel (toTemporaryNames) check if file exists

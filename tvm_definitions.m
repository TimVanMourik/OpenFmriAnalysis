function definitions = tvm_definitions

%In order to process your data the following steps require one of these formats. 
%If your data differs, please add your data type here. 
definitions = [];
definitions.DicomFileTypes =    {'.ima';    '.IMA';     '.dcm'; '.DCM'};	%types of dicom files
definitions.VolumeFileTypes =   {'.nii';    '.hdr';};                  %types of volume (nifti) files
definitions.AnatomicalData =    {'mprage'; 'MPRAGE'; 'mp2rage'; 'MP2RAGE'};                 %anatomical data *mp2rage*
definitions.FunctionalData =    {'ep3d';    'EP3D';     'ep2d'; 'EP2D'};                    %3D-EPI functional data *example*

end %end function
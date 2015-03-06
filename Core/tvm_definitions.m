function definitions = tvm_definitions

%In order to process your data the following steps require one of these formats. 
%If your data differs, please add your data type here. 
definitions = [];
definitions.DicomFileTypes =    {'.ima';    '.IMA';     '.dcm'; '.DCM'};	%types of dicom files
definitions.VolumeFileTypes =   {'.nii';    '.hdr';};                  %types of volume (nifti) files
definitions.AnatomicalData =    {'mprage'; 'MPRAGE'; 'mp2rage'; 'MP2RAGE'};                 %anatomical data *mp2rage*
definitions.MP2RAGE =           {'mp2rage'; 'MP2RAGE'};                 %anatomical data *mp2rage*
definitions.FunctionalData =    {'ep3d';    'EP3D';     'ep2d'; 'EP2D'};                    %3D-EPI functional data *example*

%Variables as the are stored in mat-files:
definitions.WhiteMatterSurface =        'wSurface';
definitions.PialSurface =           	'pSurface';
definitions.FaceData =                  'faceData';
definitions.TransformStack =            'transformStack';
definitions.CoregistrationMatrix =      'coregistrationMatrix';
definitions.RegistrationParameters =	'registrationParameters';
definitions.TimeCourses =               'timeCourses';
definitions.Covariance =                'covariance';
definitions.Stimulus =                	'stimulus';
definitions.Duration =                  'duration';
definitions.HrfParameters =             'hrfParameters';

definitions.GlmDesign =              	'design';
definitions.CovarianceMatrix =          'CovarianceMatrix';

end %end function
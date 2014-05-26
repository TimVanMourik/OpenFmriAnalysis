function definitions = tvm_definitions

%In order to process your data the following steps require one of these formats. 
%If your data differs, please add your data type here. 
definitions = [];
definitions.fileTypes = {'*.ima'; '*.IMA'; '*.dcm'; '*.DCM'};   %types of dicom files
definitions.mp2rage = {'mp2rage'; 'MP2RAGE'};                   %anatomical data mp2rage
definitions.anatomicalData = {'*mp2rage*'; '*MP2RAGE*'};        %anatomical data *mp2rage*
definitions.functionalData = {'*ep3d*'; '*EP3D*'};              %3D-EPI functional data *example*

end %end function
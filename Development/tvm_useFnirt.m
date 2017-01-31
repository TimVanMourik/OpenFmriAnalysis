function tvm_useFnirt(configuration)
% TVM_USEFNIRT 
%   TVM_USEFNIRT(configuration)
%   
%
%   Copyright (C) Tim van Mourik, 2014, DCCN
%

%% Parse configuration
subjectDirectory =      tvm_getOption(configuration, 'i_SubjectDirectory');
    %no default
referenceFile =         fullfile(subjectDirectory, tvm_getOption(configuration, 'i_ReferenceVolume'));
    %no default
moveFile =              fullfile(subjectDirectory, tvm_getOption(configuration, 'i_MoveVolume'));
    %no default
warpedimage =           fullfile(subjectDirectory, tvm_getOption(configuration, 'o_WarpedImage'));
    %no default
fieldMap =              fullfile(subjectDirectory, tvm_getOption(configuration, 'o_FieldMap'));
    %no default
      
%%
unixCommand = sprintf('FSLOUTPUTTYPE=NIFTI; fnirt --ref=%s --in=%s --fout=%s --iout=%s', referenceFile, moveFile, fieldMap, warpedimage);
unix(unixCommand);

end %end function

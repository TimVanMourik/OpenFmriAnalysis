function tvm_applyRegistration(configuration)
%
%
%   Copyright (C) 2016, Tim van Mourik, DCCN

%% Parse configuration
subjectDirectory        = tvm_getOption(configuration, 'i_SubjectDirectory');
    %no default
inputfile               = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_InputData'));
    %no default
registrationParameters  = tvm_getOption(configuration, 'i_RegistrationParameters', '');
    %no default
registrationMatrix      = tvm_getOption(configuration, 'i_RegistrationMatrix', '');
    %no default
output                  = fullfile(subjectDirectory, tvm_getOption(configuration, 'o_OutputData'));
    %no default
    
%%
base            = ['-base ', inputfile];
outputFile      = ['-prefix ', output];

if ~isempty(registrationParameters)
    registrationP   = ['-1Dparam_apply ', fullfile(subjectDirectory, registrationParameters)];
else
    registrationP   = '';
end

if ~isempty(registrationMatrix)
    registrationM   = ['-1Dmatrix_apply ', fullfile(subjectDirectory, registrationMatrix)];
else
    registrationM   = '';
end

delete(output);
unixCommand = sprintf('3dAllineate %s %s %s %s %s', base, registrationM, registrationP, outputFile, inputfile);
unix(unixCommand);

unix(sprintf('fslcpgeom %s %s', inputfile, output));

end %end function


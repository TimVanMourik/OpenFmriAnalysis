function tvm_saveAsRegisterDat(registerDatFile, matrix, dimensions, name)
% TVM_SAVEASREGISTERDAT 
%   TVM_SAVEASREGISTERDAT(configuration)
%   
%
%   Copyright (C) Tim van Mourik, 2014, DCCN
%

f = fopen(registerDatFile, 'w');
fprintf(f, '%s\n',  name);
fprintf(f, '%0.6f\n',  dimensions);
fprintf(f, '%0.7f %0.7f %0.7f %0.7f\n',  matrix(1:4, 1:3));
fprintf(f, '%0.0f %0.0f %0.0f %0.0f\n',  matrix(1:4, 4));
fprintf(f, '%s\n',  'round');
fclose(f);

end %end function



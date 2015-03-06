function tvm_saveFreesurferAsciiFile(vertices, faces, fileName)
%TVM_SAVEFREESURFERASCIIFILE()
%
%   Copyright (C) Tim van Mourik, 2015, DCCN

vertices(:, 4) = 0;

f = fopen(fileName, 'w');
fprintf(f, '# This file was created by tvm_saveFreesurferAsciiFile\n');
fprintf(f, '%d %d\n', size(vertices, 1), size(faces, 1));
fprintf(f, '%3.6f\t%3.6f\t%3.6f\t%d\n', vertices');
fprintf(f, '%d %d %d 0\n', faces' - 1);
fclose(f);


end %end function









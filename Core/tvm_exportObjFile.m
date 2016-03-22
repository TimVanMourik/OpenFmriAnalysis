function tvm_exportObjFile(vertices, faces, fileName)
%TVM_EXPORTTOOBJ(VERTICES, FACES, FILENAME)
%
%   Copyright (C) Tim van Mourik, 2015, DCCN

f = fopen(fileName, 'w');
fprintf(f, '# This file was created by tvm_exportObjFile\n');
fprintf(f, 'v %3.6f\t%3.6f\t%3.6f\n', vertices(:, 1:3)');
fprintf(f, 'f %d\t%d\t%d\n', faces');
fclose(f);


end %end function









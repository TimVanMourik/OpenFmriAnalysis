function matrix = tvm_matrixFromRegisterDatFile(registerDotDat)

f = fopen(registerDotDat);
text = fread(f, 'uint8=>char')';
fclose(f);

s = strsplit(text, '\n');

matrix = zeros(4);

%name = s(1);
%voxelSize1 = s(2);
%voxelSize2 = s(3);
%voxelSize? = s(4);
matrix(1, :) = sscanf(s{5}, '%f')';
matrix(2, :) = sscanf(s{6}, '%f')';
matrix(3, :) = sscanf(s{7}, '%f')';
matrix(4, :) = sscanf(s{8}, '%f')';

end %end function


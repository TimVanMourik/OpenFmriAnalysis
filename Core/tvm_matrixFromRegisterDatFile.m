function matrix = tvm_matrixFromRegisterDatFile(registerDotDat)

f = fopen(registerDotDat);
s=textscan(f,'%s');s=s{1};
fclose(f);

matrix = zeros(4);

%name = s(1);
%voxelSize1 = s(2);
%voxelSize2 = s(3);
%voxelSize? = s(4);
matrix(1, :) = cellfun(@str2double,s(5:8))';
matrix(2, :) = cellfun(@str2double,s(9:12))';
matrix(3, :) = cellfun(@str2double,s(13:16))';
matrix(4, :) = cellfun(@str2double,s(17:20))';

end %end function
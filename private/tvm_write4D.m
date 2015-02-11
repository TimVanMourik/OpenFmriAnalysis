function tvm_write4D(VStart, matrix4D, fname)
%  tvm_write4D(img, VStart, fname)

numberOfVolumes = size(matrix4D, 4);
VStart.fname = fname;
VStart.private.dat.dim = [VStart.private.dat.dim(1:3) numberOfVolumes];
VStart.private.timing.toffset = 0;
VStart.private.timing.tspace = 1;
% VStart.descrip = 'FSL4.0';

% without this line, volumes further than the dimension of the current
% matrix will not be removed
if exist(VStart.fname, 'file')
    delete(VStart.fname);
end

VWrite = repmat(VStart, numberOfVolumes, 1);
for volume = 1:numberOfVolumes
    VWrite(volume).n(1) = volume;
    spm_write_vol(VWrite(volume), matrix4D(:, :, :, volume));
end

end %end function
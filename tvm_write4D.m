%  spmWrite4D(img, VStart, fname)
function spmWrite4D(VStart, matrix4D, fname)

numberOfVolumes = size(matrix4D, 4);
VStart.fname = fname;
VStart.private.dat.dim = [VStart.private.dat.dim(1:3) numberOfVolumes];
VStart.private.timing.toffset = 0;
VStart.private.timing.tspace = 1;
% VStart.descrip = 'FSL4.0';

VWrite = repmat(VStart, numberOfVolumes, 1);
for volume = 1:numberOfVolumes
    VWrite(volume).n(1) = volume;
    spm_write_vol(VWrite(volume), matrix4D(:, :, :, volume));
end

end %end function
function tvm_write4D(startingVolume, matrix4D, fileName)
%  TVM_WRITE4D(startingVolume, matrix4D, fileName)

numberOfVolumes = size(matrix4D, 4);
startingVolume(1).fname = fileName;

if exist(fileName, 'file')
    delete(fileName);
end

writeVolume = repmat(startingVolume(1), numberOfVolumes, 1);
for volume = 1:numberOfVolumes
    writeVolume(volume).n(1) = volume;
    spm_write_vol(writeVolume(volume), matrix4D(:, :, :, volume));
end

end %end function
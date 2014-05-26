function output = tvm_makeLevelSet(configuration)

memtic
%Load the volume data
subjectDirectory = configuration.SubjectDirectory;

load([subjectDirectory configuration.Boundaries]);

%Ugly, but I haven't found a way to load liblapack.so
functionDirectory = mfilename('fullpath');
functionDirectory = functionDirectory(1:end - length(mfilename()));
cd(functionDirectory);

referenceVolume = spm_vol([subjectDirectory configuration.ReferenceVolume]);

%shift the transofrmation matrix by one to compensate for the indexing
shiftByOne = eye(4);
shiftByOne(1, 4) = 1;
shiftByOne(2, 4) = 1;
shiftByOne(3, 4) = 1;

for hemisphere = 1:2
%1 = right
    if hemisphere == 1
        objFile = strrep([subjectDirectory configuration.ObjWhite], '?', 'r');
        sdfFile = strrep([subjectDirectory configuration.SdfWhite], '?', 'r');
    elseif hemisphere == 2
        objFile = strrep([subjectDirectory configuration.ObjWhite], '?', 'l');
        sdfFile = strrep([subjectDirectory configuration.SdfWhite], '?', 'l');
    else
            %crash
    end

    makeSignedDistanceField(objFile, sdfFile, referenceVolume.dim(1), referenceVolume.dim(2), referenceVolume.dim(3), referenceVolume.mat * shiftByOne);
    
    if hemisphere == 1
        objFile = strrep([subjectDirectory configuration.ObjPial], '?', 'r');
        sdfFile = strrep([subjectDirectory configuration.SdfPial], '?', 'r');
    elseif hemisphere == 2
        objFile = strrep([subjectDirectory configuration.ObjPial], '?', 'l');
        sdfFile = strrep([subjectDirectory configuration.SdfPial], '?', 'l');
    else
    end
    
    makeSignedDistanceField(objFile, sdfFile, referenceVolume.dim(1), referenceVolume.dim(2), referenceVolume.dim(3), referenceVolume.mat * shiftByOne);

end

%Sets the data type to float
referenceVolume.dt = [16, 0];

referenceVolume.fname = [subjectDirectory configuration.White];
referenceVolume.volume = zeros(referenceVolume.dim);
right = spm_vol(strrep([subjectDirectory configuration.SdfWhite], '?', 'r'));
right.volume = spm_read_vols(right);
left  = spm_vol(strrep([subjectDirectory configuration.SdfWhite], '?', 'l'));
left.volume  = spm_read_vols(left);
referenceVolume.volume(:) = min([right.volume(:), left.volume(:)], [], 2);
spm_write_vol(referenceVolume, referenceVolume.volume);

referenceVolume.fname = [subjectDirectory configuration.Pial];
referenceVolume.volume = zeros(referenceVolume.dim);
right = spm_vol(strrep([subjectDirectory configuration.SdfPial], '?', 'r'));
right.volume = spm_read_vols(right);
left  = spm_vol(strrep([subjectDirectory configuration.SdfPial], '?', 'l'));
left.volume  = spm_read_vols(left);
referenceVolume.volume(:) = min([right.volume(:), left.volume(:)], [], 2);
spm_write_vol(referenceVolume, referenceVolume.volume);

output = memtoc;

end %end function











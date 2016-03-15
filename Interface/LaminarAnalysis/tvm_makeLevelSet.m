function tvm_makeLevelSet(configuration)
% TVM_MAKELEVELSET 
%   TVM_MAKELEVELSET(configuration)
%   The level set is a volume that for each voxel gives the distance from
%   the centre of the voxel to the nearest point at from the input
%   boundaries.
%
%
%   Copyright (C) Tim van Mourik, 2014, DCCN
%
%   configuration.SubjectDirectory
%   configuration.Boundaries
%   configuration.ReferenceVolume
%   configuration.ObjWhite
%   configuration.ObjPial
%   configuration.SdfWhite
%   configuration.SdfPial
%   configuration.White
%   configuration.Pial
%

%% Parse configuration
subjectDirectory        = tvm_getOption(configuration, 'i_SubjectDirectory', pwd());
    %no default
referenceFile           = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_ReferenceVolume'));
    %no default
objWhite                = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_ObjWhite'));
    %no default
objPial                 = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_ObjPial'));
    %no default
objTransformationMatrix = tvm_getOption(configuration, 'i_Matrix', [1, 0, 0, -1; 0, 1, 0, -1; 0, 0, 1, -1; 0, 0, 0, 1]);
    %default: shift by -1
    %The obj.file is multiplied with this matrix. The matrix written to the
    %file is still the matrix from the reference volume
    %@todo, see if this is a logical default. It seems so, as the input is
    %delivered in Matlab space and the level set is computed in 1-indexing
    %space
sdfWhite                = fullfile(subjectDirectory, tvm_getOption(configuration, 'o_SdfWhite', ''));
    %no default
sdfPial                 = fullfile(subjectDirectory, tvm_getOption(configuration, 'o_SdfPial', ''));
    %no default
white                   = fullfile(subjectDirectory, tvm_getOption(configuration, 'o_White'));
    %no default
pial                    = fullfile(subjectDirectory, tvm_getOption(configuration, 'o_Pial'));
    %no default
    
%%
% load(boundariesFile, 'pSurface', 'wSurface');

% @todo This is ugly, but I haven't found a way to load liblapack.so
functionDirectory = mfilename('fullpath');
functionDirectory = functionDirectory(1:end - length(mfilename()));
cd(functionDirectory);

referenceVolume = spm_vol(referenceFile);

if isempty(strfind(objWhite, '?'))
    makeSignedDistanceField(objWhite, white, referenceVolume(1).dim, referenceVolume(1).mat, objTransformationMatrix);
    makeSignedDistanceField(objPial,  pial,  referenceVolume(1).dim, referenceVolume(1).mat, objTransformationMatrix);
    
else
    for hemisphere = 1:2
    %1 = right
        if hemisphere == 1
            objFile = strrep(objWhite, '?', 'r');
            sdfFile = strrep(sdfWhite, '?', 'r');
        elseif hemisphere == 2
            objFile = strrep(objWhite, '?', 'l');
            sdfFile = strrep(sdfWhite, '?', 'l');
        else
                %@todo crash properly
        end
        makeSignedDistanceField(objFile, sdfFile, referenceVolume(1).dim, referenceVolume(1).mat, objTransformationMatrix);

        if hemisphere == 1
            objFile = strrep(objPial, '?', 'r');
            sdfFile = strrep(sdfPial, '?', 'r');
        elseif hemisphere == 2
            objFile = strrep(objPial, '?', 'l');
            sdfFile = strrep(sdfPial, '?', 'l');
        else
                %@todo crash properly
        end
        makeSignedDistanceField(objFile, sdfFile, referenceVolume(1).dim, referenceVolume(1).mat, objTransformationMatrix);

    end

    %Sets the data type to float
    referenceVolume(1).dt = [16, 0];

    referenceVolume(1).fname = white;
    referenceVolume(1).volume = zeros(referenceVolume.dim);
    right = spm_vol(strrep(sdfWhite, '?', 'r'));
    right.volume = spm_read_vols(right);
    left  = spm_vol(strrep(sdfWhite, '?', 'l'));
    left.volume  = spm_read_vols(left);
    referenceVolume(1).volume(:) = min([right.volume(:), left.volume(:)], [], 2);
    spm_write_vol(referenceVolume(1), referenceVolume(1).volume);

    referenceVolume(1).fname = pial;
    referenceVolume(1).volume = zeros(referenceVolume(1).dim);
    right = spm_vol(strrep(sdfPial, '?', 'r'));
    right.volume = spm_read_vols(right);
    left  = spm_vol(strrep(sdfPial, '?', 'l'));
    left.volume  = spm_read_vols(left);
    referenceVolume(1).volume(:) = min([right.volume(:), left.volume(:)], [], 2);
    spm_write_vol(referenceVolume(1), referenceVolume(1).volume);
end

end %end function











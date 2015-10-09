function tvm_computeCurvatureFromSdf(configuration)
%% Parse configuration
subjectDirectory 	= tvm_getOption(configuration, 'i_SubjectDirectory');
    %no default
sdfFile             = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_SDF'));
    %no default
curv1File           = fullfile(subjectDirectory, tvm_getOption(configuration, 'o_PrimaryCurvature1'));
    %no default
curv2File           = fullfile(subjectDirectory, tvm_getOption(configuration, 'o_SecondaryCurvature2'));
    %no default

%%


curvatureKernel = getCurvatureKernelCube3();
invKernel = pinv(curvatureKernel);

sdf = spm_vol(sdfFile);
sdf.volume    = spm_read_vols(sdf);
curv1 = sdf;
curv1.fname = curv1File;
curv2 = sdf;
curv2.fname = curv2File;

curv1.volume = zeros(sdf.dim);
curv2.volume = zeros(sdf.dim);
voxelValues = zeros(26, 1);
dimensions = sdf.dim;

% N. J. Wildberger, Differential Geometry Lecture 28: Curvature for the general paraboloid
% http://www.youtube.com/watch?v=PTh_wI6xjIQ,
% See 44:36 for the formulas
for x = 2:dimensions(1) - 1
    for y = 2:dimensions(2) - 1
        for z = 2:dimensions(3) - 1
            voxelValues(:) = sdf.volume(x, y, z);
            voxelValues = voxelValues - sampleCube(sdf.volume, x, y, z);

            paraboloidParameters = invKernel * voxelValues;
            
            curv1.volume(x, y, z) = ((paraboloidParameters(1) + paraboloidParameters(2)) * paraboloidParameters(7) ^ 2 + (paraboloidParameters(1) + paraboloidParameters(3)) * paraboloidParameters(8) ^ 2 + (paraboloidParameters(2) + paraboloidParameters(3)) * paraboloidParameters(9) ^ 2) / (paraboloidParameters(7) ^ 2 + paraboloidParameters(8) ^ 2 + paraboloidParameters(9) ^ 2);
            curv2.volume(x, y, z) = paraboloidParameters(1) * paraboloidParameters(2) * paraboloidParameters(7) ^ 2 + paraboloidParameters(1) * paraboloidParameters(3) * paraboloidParameters(8) ^ 2 + paraboloidParameters(2) * paraboloidParameters(3) * paraboloidParameters(9) ^ 2;
        end
    end
end

spm_write_vol(curv1, curv1.volume);
spm_write_vol(curv2, curv2.volume);

end %end function


function values = sampleCube(volume, x, y, z)

values = zeros(26, 1);

values(1)  = volume(x - 1, y - 1, z - 1);
values(2)  = volume(x - 1, y - 1, z);
values(3)  = volume(x - 1, y - 1, z + 1);
values(4)  = volume(x - 1, y, z - 1);
values(5)  = volume(x - 1, y, z);
values(6)  = volume(x - 1, y, z + 1);
values(7)  = volume(x - 1, y + 1, z - 1);
values(8)  = volume(x - 1, y + 1, z);
values(9)  = volume(x - 1, y + 1, z + 1);
values(10) = volume(x, y - 1, z - 1);
values(11) = volume(x, y - 1, z);
values(12) = volume(x, y - 1, z + 1);
values(13) = volume(x, y, z - 1);
values(14) = volume(x, y, z + 1);
values(15) = volume(x, y + 1, z - 1);
values(16) = volume(x, y + 1, z);
values(17) = volume(x, y + 1, z + 1);
values(18) = volume(x + 1, y - 1, z - 1);
values(19) = volume(x + 1, y - 1, z);
values(20) = volume(x + 1, y - 1, z + 1);
values(21) = volume(x + 1, y, z - 1);
values(22) = volume(x + 1, y, z);
values(23) = volume(x + 1, y, z + 1);
values(24) = volume(x + 1, y + 1, z - 1);
values(25) = volume(x + 1, y + 1, z);
values(26) = volume(x + 1, y + 1, z + 1);

end %end function

function curvatureKernel = getCurvatureKernelCube3()

curvatureKernel(1:9, 1) = 1;
curvatureKernel([1, 2, 3, 7:12], 2) = 1;
curvatureKernel([1, 3, 4, 6, 7, 9, 10, 12, 13], 3) = 1;
curvatureKernel(1:3, 4) = 2;
curvatureKernel(7:9, 4) = -2;
curvatureKernel([1, 9, 10], 5) = 2;
curvatureKernel([3, 7, 12], 5) = -2;
curvatureKernel([1, 4, 7], 6) = 2;
curvatureKernel([3, 6, 9], 6) = -2;
curvatureKernel = [curvatureKernel; flipud(curvatureKernel)];

curvatureKernel(1:9, 7) = -1; 
curvatureKernel(19:26, 7) = 1; 
curvatureKernel([1:3, 10:12, 18:20], 8) = -1;
curvatureKernel([7:9, 15:17, 24:26], 8) = 1;
curvatureKernel([1, 4, 7, 10, 13, 15, 18, 21, 24], 9) = -1;
curvatureKernel([3, 6, 9, 12, 14, 17, 20, 23, 26], 9) = 1;

end %end function



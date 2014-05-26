function computeCurvature(sdfFile, curv1File, curv2File)


curvatureKernel = zeros(13, 9);
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


sdf = spm_vol(sdfFile);
sdf.volume    = spm_read_vols(sdf);
curv1 = sdf;
curv1.fname = curv1File;
curv2 = sdf;
curv2.fname = curv2File;

curv1.volume = zeros(sdf.dim);
curv2.volume = zeros(sdf.dim);
kernel = zeros(26, 1);
dimensions = sdf.dim;
for x = 2:dimensions(1) - 1
    for y = 2:dimensions(2) - 1
        for z = 2:dimensions(3) - 1
        kernel(1)  = sdf.volume(x, y, z) - sdf.volume(x - 1, y - 1, z - 1);
        kernel(2)  = sdf.volume(x, y, z) - sdf.volume(x - 1, y - 1, z);
        kernel(3)  = sdf.volume(x, y, z) - sdf.volume(x - 1, y - 1, z + 1);
        kernel(4)  = sdf.volume(x, y, z) - sdf.volume(x - 1, y, z - 1);
        kernel(5)  = sdf.volume(x, y, z) - sdf.volume(x - 1, y, z);
        kernel(6)  = sdf.volume(x, y, z) - sdf.volume(x - 1, y, z + 1);
        kernel(7)  = sdf.volume(x, y, z) - sdf.volume(x - 1, y + 1, z - 1);
        kernel(8)  = sdf.volume(x, y, z) - sdf.volume(x - 1, y + 1, z);
        kernel(9)  = sdf.volume(x, y, z) - sdf.volume(x - 1, y + 1, z + 1);
        kernel(10) = sdf.volume(x, y, z) - sdf.volume(x, y - 1, z - 1);
        kernel(11) = sdf.volume(x, y, z) - sdf.volume(x, y - 1, z);
        kernel(12) = sdf.volume(x, y, z) - sdf.volume(x, y - 1, z + 1);
        kernel(13) = sdf.volume(x, y, z) - sdf.volume(x, y, z - 1);
        kernel(14) = sdf.volume(x, y, z) - sdf.volume(x, y, z + 1);
        kernel(15) = sdf.volume(x, y, z) - sdf.volume(x, y + 1, z - 1);
        kernel(16) = sdf.volume(x, y, z) - sdf.volume(x, y + 1, z);
        kernel(17) = sdf.volume(x, y, z) - sdf.volume(x, y + 1, z + 1);
        kernel(18) = sdf.volume(x, y, z) - sdf.volume(x + 1, y - 1, z - 1);
        kernel(19) = sdf.volume(x, y, z) - sdf.volume(x + 1, y - 1, z);
        kernel(20) = sdf.volume(x, y, z) - sdf.volume(x + 1, y - 1, z + 1);
        kernel(21) = sdf.volume(x, y, z) - sdf.volume(x + 1, y, z - 1);
        kernel(22) = sdf.volume(x, y, z) - sdf.volume(x + 1, y, z);
        kernel(23) = sdf.volume(x, y, z) - sdf.volume(x + 1, y, z + 1);
        kernel(24) = sdf.volume(x, y, z) - sdf.volume(x + 1, y + 1, z - 1);
        kernel(25) = sdf.volume(x, y, z) - sdf.volume(x + 1, y + 1, z);
        kernel(26) = sdf.volume(x, y, z) - sdf.volume(x + 1, y + 1, z + 1);
        
        paraboloidParameters = curvatureKernel \ kernel;
        
        curv1.volume(x, y, z) = ((paraboloidParameters(1) + paraboloidParameters(2)) * paraboloidParameters(7) ^ 2 + (paraboloidParameters(1) + paraboloidParameters(3)) * paraboloidParameters(8) ^ 2 + (paraboloidParameters(2) + paraboloidParameters(3)) * paraboloidParameters(9) ^ 2) / (paraboloidParameters(7) ^ 2 + paraboloidParameters(8) ^ 2 + paraboloidParameters(9) ^ 2);
        curv2.volume(x, y, z) = paraboloidParameters(1) * paraboloidParameters(2) * paraboloidParameters(7) ^ 2 + paraboloidParameters(1) * paraboloidParameters(3) * paraboloidParameters(8) ^ 2 + paraboloidParameters(2) * paraboloidParameters(3) * paraboloidParameters(9) ^ 2;

        end
    end
end

spm_write_vol(curv1, curv1.volume);
spm_write_vol(curv2, curv2.volume);

end %end function




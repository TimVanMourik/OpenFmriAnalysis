function output = tvm_modifyMp2rage(configuration)

memtic

subjectDirectory = configuration.SubjectDirectory;

uniFile = [subjectDirectory configuration.MP2RAGEFolder];
folder = dir([uniFile configuration.UniFolder]);
uniFile = [uniFile folder.name];
fileName = ls([uniFile '/*.nii']);
contrastImage = spm_vol(fileName);
contrastImage.volume = spm_read_vols(contrastImage);

inv2File = [subjectDirectory configuration.MP2RAGEFolder];
folder = dir([inv2File configuration.Inv2Folder]);
inv2File = [inv2File folder.name];
fileName = ls([inv2File '/*.nii']);
inversionImage = spm_vol(fileName);
inversionImage.volume = spm_read_vols(inversionImage);

threshold = 1.2;
m = mean(inversionImage.volume(:));
contrastImage.volume(inversionImage.volume < m * threshold) = 0;
contrastImage.fname = [subjectDirectory configuration.MP2RAGEFolder configuration.MP2RAGE];

empty = false(contrastImage.dim);
empty(contrastImage.volume == 0) = true;
empty = dilate3D(empty);
contrastImage.volume(empty) = 0;

spm_write_vol(contrastImage, contrastImage.volume);

output = memtoc;

end %end function
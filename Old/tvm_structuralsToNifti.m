function [memoryUsage, computationTime] = tvm_structuralsToNifti(configuration)

tic
memtic
subjectDirectory = configuration.SubjectDirectory;
mprage = [subjectDirectory 'Scans/Anatomical/MPRAGE/'];
folder = dir([mprage '*MPRAGE*']);
folder = folder([folder.isdir]);
folderName = strrep(strrep(folder.name, '(', '\('), ')', '\)');
unix(['dcm2nii -g n -r n -x n ' mprage folderName ';']);
unix(['mv ' mprage folderName '/*.nii ' mprage 'MPRAGE.nii']);
mp2rage = [subjectDirectory 'Scans/Anatomical/MP2RAGE/'];
folders = dir([mp2rage '*MP2RAGE*']);
folders = folders([folders.isdir]);
for folder = {folders.name}
    unix(['dcm2nii -g n -r n -x n ' mp2rage folder{1} ';']);
end

memoryUsage = memtoc;
computationTime = toc;

end %end function
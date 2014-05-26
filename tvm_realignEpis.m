function [memoryUsage, computationTime] = tvm_realignEpis(configuration)

tic
memtic

subjectDirectory = configuration.SubjectDirectory;
scanFolder       = [subjectDirectory configuration.ScanFolder];
niftiFolder      = [subjectDirectory configuration.NiftiFolder];
realignedFolder  = [subjectDirectory configuration.RealignmentFolder];
meanName         = configuration.MeanName;
epiCharacteristic = '*EP3D*';
dicomExtension = '*.IMA';

cd(scanFolder);
folder = dir(epiCharacteristic);
folder = folder([folder.isdir]);
cd(folder.name)
rawDicomFiles = dir(dicomExtension) ;
rawDicomFileNames = {rawDicomFiles.name};
rawDicomFileNames = vertcat(rawDicomFileNames{:});
headers = spm_dicom_headers(rawDicomFileNames);
cd(niftiFolder);
spm_dicom_convert(headers, 'all', 'flat', 'nii');

niftiFiles = dir('*.nii');
niftiFiles = {niftiFiles.name};
niftiFiles = vertcat(niftiFiles{:});
spm_realign(niftiFiles);
spm_reslice(niftiFiles);

unix(['mv ' niftiFolder 'r* ' realignedFolder]);
unix(['mv ' niftiFolder 'mean* ' scanFolder meanName]);

memoryUsage = memtoc;
computationTime = toc;

end %end function

function test
%%
    subject  = 4;
    configuration.SubjectDirectory = sprintf('%s/SubjectData/Subject%02d/', rootDirectory, subject);
    tvm_realignEpis(configuration);
end





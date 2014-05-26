function [memoryUsage, computationTime] = tvm_reconAll(configuration)

tic
memtic

if exist([configuration.SubjectDirectory 'FreeSurfer'], 'dir')
    if ~exist([configuration.SubjectDirectory 'FreeSurferOld'], 'dir')
        mkdir([configuration.SubjectDirectory 'FreeSurferOld']);
    end
    movefile([configuration.SubjectDirectory 'FreeSurfer/*'], [configuration.SubjectDirectory 'FreeSurferOld/*']);
    rmdir([configuration.SubjectDirectory 'FreeSurfer'], 's');
end

subjectDirectory = configuration.SubjectDirectory;
u1 = ['SUBJECTS_DIR=', subjectDirectory ';'];
u2 = ['recon-all -subjid FreeSurfer -i ' subjectDirectory configuration.Structural ' -all;'];
unix([u1, u2]);

memoryUsage = memtoc;
computationTime = toc;

cd(subjectDirectory);

end %end function
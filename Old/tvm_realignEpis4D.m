function [memoryUsage, computationTime] = tvm_realignEpis4D(configuration)

tic
memtic

subjectDirectory = configuration.SubjectDirectory;
scanName        = [subjectDirectory configuration.Scans];
meanName         = configuration.MeanName;

scanNameUnzipped = scanName(1:end - 3);
unix(sprintf('gunzip %s', scanName));
scanNiftis = spm_vol(scanNameUnzipped);

Vo = struct(    'fname',    [subjectDirectory meanName],...
        'dim',      scanNiftis(1).dim(1:3),...
        'dt',           [4, spm_platform('bigend')],...
        'mat',      scanNiftis(1).mat,...
        'pinfo',    [1.0,0,0]',...
        'descrip',  'Mean image');

Vo            = spm_create_vol(Vo);
Vo.volume     = zeros(Vo.dim);
for i = 1:length(scanNiftis)
    Vo.volume = scanNiftis(i).private.dat(:, :, :, i);
end
Vo.volume = Vo.volume / length(scanNiftis);
spm_write_vol(Vo, Vo.volume);

% unix(['mv ' niftiFolder 'r* ' realignedFolder]);
% unix(['mv ' niftiFolder 'mean* ' scanFolder meanName]);

% unix(sprintf('gzip %s', scanName));

memoryUsage = memtoc;
computationTime = toc;

end %end function





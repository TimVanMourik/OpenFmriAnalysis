function output = tvm_vertexInformationToVolume(configuration)

memtic

subjectDirectory = configuration.SubjectDirectory;

load(sprintf('%s/Profiles/All.mat', subjectDirectory), 'profiles');

numberOfVoxels = length(profiles{1}) + length(profiles{2}); %#ok<USENS>

volumeHeader = [];
volumeHeader.dt = [16, size(profiles{1}, 2)];
volumeHeader.mat = eye(4);
volumeHeader.pinfo = [1; 0; 0];
%Terribly ugly: but the maximum dimension in one dimension is 2^15 = 32768
%75 cubed should always be enough for FreeSurfer files
volumeHeader.dim = [75, 75, 75];
volumeHeader.volume = zeros(volumeHeader.dim);

for volume = 1:size(profiles{1}, 2)
    volumeHeader.fname = sprintf('%s%s%03d%s', subjectDirectory, configuration.VertexInformation(1:end - 4), volume, '.nii');
    volumeHeader.volume(1:length(profiles{1})) = profiles{1}(:, volume);
    volumeHeader.volume(length(profiles{1}) + 1:numberOfVoxels) = profiles{2}(:, volume);
    spm_write_vol(volumeHeader, volumeHeader.volume);
end 

directory = fileparts([subjectDirectory, configuration.VertexInformation]);
unix(sprintf('fslmerge -t %s %s', [subjectDirectory, configuration.VertexInformation], [directory '/*.nii']));

unix(sprintf('rm %s', [subjectDirectory configuration.VertexInformation(1:end - 4) '*.nii']));

output = memtoc;

end %end function







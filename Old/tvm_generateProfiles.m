function output = tvm_generateProfiles(configuration)
memtic

subjectDirectory    = configuration.SubjectDirectory;
load([subjectDirectory configuration.VerticesOfInterest], 'verticesOfInterest')
load([subjectDirectory configuration.Boundaries], 'wSurface', 'pSurface');

functionalScans = dir([subjectDirectory configuration.FunctionalFolder '*.nii']);
functionalScans = {functionalScans.name};

profiles = cell(size(verticesOfInterest));
for i = 1:length(profiles)
    profiles{i} = cell(size(verticesOfInterest{i}));
    for j = 1:length(profiles{i})
        profiles{i}{j} = zeros(length(verticesOfInterest{i}{j}), configuration.ProfileLength, length(functionalScans));
    end
end

switch configuration.Hemisphere
    case 'Right'
        hemisphere = 1;
    case 'Left'
        hemisphere = 2;
%     case 'Both'
%         hemisphere = [1, 2];
end

profileConfiguration = [];
profileConfiguration.Steps = configuration.ProfileLength;
for scan = 1:length(functionalScans)
    volume = spm_read_vols(spm_vol([subjectDirectory configuration.FunctionalFolder functionalScans{scan}]));
    for i = 1:length(profiles)
        for j = 1:length(profiles{i})
            profiles{i}{j}(:, :, scan) = getProfile(wSurface{hemisphere}(verticesOfInterest{i}{j}, :), pSurface{hemisphere}(verticesOfInterest{i}{j}, :), volume, profileConfiguration);
%             fprintf('j = %d\n', j);
        end
%         fprintf('i = %d\n', i);
    end
%     fprintf('scan = %d\n', scan);
end

save([subjectDirectory configuration.Profiles], 'profiles', '-v7.3')

output = memtoc;

end %end function







function output = tvm_boundariesToProfiles(configuration)
memtic


if isfield(configuration, 'SaveFullProfile')
    saveProfile = configuration.SaveFullProfile;
else
    saveProfile = false;
end

subjectDirectory    = configuration.SubjectDirectory;
bok = configuration.Bok;
load([subjectDirectory configuration.VerticesOfInterest], 'verticesOfInterest')
load([subjectDirectory configuration.Boundaries], 'wSurface', 'pSurface');

functionalScans = dir([subjectDirectory configuration.FunctionalFolder '*.nii']);
functionalScans = {functionalScans.name};

%If configuration.Hemisphere is one string, all labels are located on that
%hemisphere. If it is a cell, consider all labels to be located on the
%hemisphere as indicated. 
if iscell(configuration.Hemisphere)
    hemisphere = cell(size(configuration.Hemisphere));
    for h = 1:length(configuration.Hemisphere)
        switch configuration.Hemisphere{h}
            case 'Right'
                hemisphere{h} = 1;
            case 'Left'
                hemisphere{h} = 2;
        end
    end
else
    numberOfLabels = size(verticesOfInterest, 1);
    switch configuration.Hemisphere
        case 'Right'
            hemisphere = num2cell(ones(numberOfLabels, 1));
        case 'Left'
            hemisphere = num2cell(2 * ones(numberOfLabels, 1));
    end
end
% switch configuration.Hemisphere
%     case 'Right'
%         hemisphere = 1;
%     case 'Left'
%         hemisphere = 2;
% %     case 'Both'
% %         hemisphere = [1, 2];
% end

if bok
    curvatureFile = [subjectDirectory configuration.Curvature];
    leftCurvature = strrep(curvatureFile, '?', 'l');
    whiteMatterSurface = [subjectDirectory 'FreeSurfer/surf/?h.white'];
    if ~exist([leftCurvature '.asc'], 'file')
        unix(['mris_convert -c ' leftCurvature ' ' strrep(whiteMatterSurface, '?', 'l') ' ' leftCurvature '.asc'])
    end
    rightCurvature = strrep(curvatureFile, '?', 'r');
    if ~exist([rightCurvature '.asc'], 'file')
        unix(['mris_convert -c ' rightCurvature ' ' strrep(whiteMatterSurface, '?', 'r') ' ' rightCurvature '.asc'])
    end
    leftCurvature = importdata([leftCurvature '.asc']);
    leftCurvature = leftCurvature(:, 5);
    rightCurvature = importdata([rightCurvature '.asc']);
    rightCurvature = rightCurvature(:, 5);
end

profileConfiguration = [];
profileConfiguration.Steps = configuration.ProfileLength;
profileConfiguration.OutsideGreyMatter = configuration.OutsideGreyMatter;
profileConfiguration.Bok = bok;    

if length(verticesOfInterest) < 7 || saveProfile
    %high speed, high memory
    profiles = cell(length(verticesOfInterest), 1);
    for i = 1:length(profiles)
        profiles{i} = zeros(length(verticesOfInterest{i, hemisphere{i}}), configuration.ProfileLength, length(functionalScans));
    end
    for scan = 1:length(functionalScans)
        volume = spm_read_vols(spm_vol([subjectDirectory configuration.FunctionalFolder functionalScans{scan}]));
        for i = 1:length(profiles)
            if bok
                if hemisphere{i} == 1
                    profileConfiguration.Curvature = rightCurvature(verticesOfInterest{i, hemisphere{i}});
                elseif hemisphere{i} == 2
                    profileConfiguration.Curvature = leftCurvature(verticesOfInterest{i, hemisphere{i}});
                end
            end
            profiles{i}(:, :, scan) = getProfile(wSurface{hemisphere{i}}(verticesOfInterest{i, hemisphere{i}}, :), pSurface{hemisphere{i}}(verticesOfInterest{i, hemisphere{i}}, :), volume, profileConfiguration);
        end
    end
    collapsedProfile = cell(size(profiles));
    for i = 1:length(collapsedProfile)
        collapsedProfile{i} = squeeze(mean(profiles{i}, 1));
    end
else
    %low speed, low memory
    collapsedProfile = cell(length(verticesOfInterest), 1);
    for i = 1:length(verticesOfInterest)
        if bok
            if hemisphere{i} == 1
                profileConfiguration.Curvature = rightCurvature;
            elseif hemisphere{i} == 2
                profileConfiguration.Curvature = leftCurvature;
            end
        end
        profiles = zeros(length(verticesOfInterest{i, hemisphere{i}}), configuration.ProfileLength, length(functionalScans));
        for scan = 1:length(functionalScans)
            volume = spm_read_vols(spm_vol([subjectDirectory configuration.FunctionalFolder functionalScans{scan}]));
            profiles(:, :, scan) = getProfile(wSurface{hemisphere{i}}(verticesOfInterest{i, hemisphere{i}}, :), pSurface{hemisphere{i}}(verticesOfInterest{i, hemisphere{i}}, :), volume, profileConfiguration);
        end
        collapsedProfile{i} = squeeze(mean(profiles, 1));
    end
end


if saveProfile
    save([subjectDirectory configuration.Profiles], 'profiles', 'collapsedProfile', '-v7.3');
else
    save([subjectDirectory configuration.Profiles], 'collapsedProfile', '-v7.3');
end

output = memtoc;

end %end function







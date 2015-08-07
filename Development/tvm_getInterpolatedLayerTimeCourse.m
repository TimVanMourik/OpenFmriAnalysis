function tvm_getInterpolatedLayerTimeCourse(configuration)

%% Parse configuration
subjectDirectory        = tvm_getOption(configuration, 'i_SubjectDirectory');
    %no default
functionalFiles         = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_FunctionalFiles'));
    %no default
boundaryFiles           = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_Boundaries', []));
    %no default
labelFiles              = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_LabelFiles', []));
    %no default
hemispheres             = tvm_getOption(configuration, 'i_Hemispheres', []);
    %no default
profileLength           = tvm_getOption(configuration, 'i_ProfileLength', 30);
    %no default
outsideGreyMatter       = tvm_getOption(configuration, 'i_OutsideGreyMatter', 1 / 12);
    %no default
interpolationMethod     = tvm_getOption(configuration, 'i_InterpolationMethod', 'Trilinear');
    %no default
timeCourseFiles         = fullfile(subjectDirectory, tvm_getOption(configuration, 'o_TimeCourse'));
    %no default
    
% definitions = tvm_definitions();

%%
for i = 1:length(boundaryFiles)
    load(boundaryFiles{i}, 'wSurface', 'pSurface');
    
    whiteMatterSurface = [];
    pialSurface = [];
    for j = 1:length(labelFiles)
        h = 0;
        switch hemispheres{j}
            case 'Right'
                h = 1;
            case 'Left'
                h = 2;
        end
        label = tvm_importFreesurferLabel(labelFiles{j});
        
        whiteMatterSurface = [whiteMatterSurface; wSurface{h}(label, :)];
        pialSurface = [pialSurface; pSurface{h}(label, :)];

    end

    profileConfiguration = [];
    profileConfiguration.Steps = profileLength;
    profileConfiguration.OutsideGreyMatter = outsideGreyMatter;
    profileConfiguration.InterpolationMethod = interpolationMethod;

    scans = spm_vol(functionalFiles{1});
    timeCourses = cell(1);

    profiles = zeros(size(whiteMatterSurface, 1), profileLength, length(scans));
    for scan = 1:length(scans)
        volume = spm_read_vols(scans(scan));
        profiles(:, :, scan) = tvm_getProfile(whiteMatterSurface, pialSurface, volume, profileConfiguration);
    end
    timeCourses{1} = squeeze(mean(profiles, 1))';

    save(timeCourseFiles{1}, 'timeCourses');
end

end %end function







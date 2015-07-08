function output = tvm_makeWallpaperWithTimecourse(configuration)
memtic

concatTimecourses = cell(configuration.NumberOfTimeCourses, 1);
concatProfiles = cell(configuration.NumberOfRegions, 1);
for subject = 1:length(configuration.Subjects)
    subjectDirectory    = sprintf(configuration.SubjectDirectory, configuration.Subjects(subject));
    % load([subjectDirectory configuration.Profiles], 'profiles');
    load([subjectDirectory configuration.Profiles], 'collapsedProfile');

    load([subjectDirectory configuration.Nuisance], 'timecourses');
    nuisanceTimeCourses = [timecourses{:}]; 
    motionFile = strrep(ls([subjectDirectory configuration.MotionFile]), '\t', '');
    motionParameters = importdata(motionFile(1:end - 1));

    
    load([subjectDirectory configuration.Timecourses], 'timecourses');
    nuisance = [motionParameters nuisanceTimeCourses ones(size(motionParameters, 1), 1)];
%     nuisance = [motionParameters ones(length(motionParameters), 1)];

    for i = 1:length(collapsedProfile)
        A = nuisance \ collapsedProfile{i}';
        collapsedProfile{i} = bandpass(collapsedProfile{i}' - nuisance * A, configuration.TR, configuration.BandpassLower, configuration.BandpassUpper)'; %#ok<AGROW>
        concatProfiles{i} = [concatProfiles{i}, collapsedProfile{i}];
    end
    for i = 1:length(timecourses)
        A = nuisance \ timecourses{i};
        timecourses{i} = bandpass(timecourses{i} - nuisance * A, configuration.TR, configuration.BandpassLower, configuration.BandpassUpper); %#ok<AGROW>
        concatTimecourses{i} = [concatTimecourses{i}, timecourses{i}'];
    end
end

for k = 1:configuration.NumberOfTimeCourses
    mainFigure = figure;
    set(gcf,'Position',get(0,'Screensize'))
    for i = 1:configuration.NumberOfRegions
        for j = 1:configuration.NumberOfRegions
            c = corr(concatProfiles{i}', concatProfiles{j}');
            timeCorr = corr(concatProfiles{j}', concatTimecourses{k}');
            subplot(configuration.NumberOfRegions, configuration.NumberOfRegions, (i - 1) * configuration.NumberOfRegions + j)
            imagesc([0, length(timeCorr)], [min(timeCorr), max(timeCorr)], flipud(c));
            hold on;
            set(gca, 'YDir', 'normal')
            plot(0.5:length(timeCorr), timeCorr);
            l = length(c);
        plot([(l - 1) / 4 + 0.5, (l - 1) / 4 + 0.5],[0, l + 1]);
        plot([3 * (l - 1) / 4 + 1.5, 3 * (l - 1) / 4 + 1.5],[0, l + 1]);
        plot([0, l + 1],[(l - 1) / 4 + 0.5, (l - 1) / 4 + 0.5]);
        plot([0, l + 1],[3 * (l - 1) / 4 + 1.5, 3 * (l - 1) / 4 + 1.5]);
        plot([0, l], [0, l]);
        
            set(gca, 'XTickLabel', '');
    %         text(4, 7,'WM', 'FontSize', 24);
    %         text(30, 32,'CSF', 'FontSize', 24);
            switch i
                case 1
                    ylabel 'M1 Left Hemishpere'
                case 2
                    ylabel 'S1 Left Hemishpere'
                case 3
                    ylabel 'M1 Right Hemishpere'
                case 4
                    ylabel 'S1 Right Hemishpere'
            end
            switch j
                case 1
                    xlabel 'M1 Left Hemishpere'
                case 2
                    xlabel 'S1 Left Hemishpere'
                case 3
                    xlabel 'M1 Right Hemishpere'
                case 4
                    xlabel 'S1 Right Hemishpere'
            end

            colorbar;
            axis square
        end
    end
    mtit(mainFigure, configuration.FigureTitle);
end

saveas(gca, sprintf( '%s%s', configuration.Image));
output = memtoc;

end %end function











function makeAnimatedGif()

c = concatProfiles{1}(:, 1:320);

for i = 1:320
    plot(c(:, i));
    axis([1, 37, -10, 10])
    frame = getframe(1);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    fileName = 'test.gif';
    if i == 1
        imwrite(imind, cm, fileName, 'gif', 'Loopcount', inf);
    else
        imwrite(imind, cm, fileName, 'gif', 'WriteMode', 'append');
    end
end
end





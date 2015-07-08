function output = tvm_makeWallpaper(configuration)
memtic

s = sprintf(configuration.SubjectDirectory, configuration.Subjects(1));
load([s configuration.Profiles], 'collapsedProfile');
numberOfRegions = size(collapsedProfile, 1); %#ok<NODEF>

concatProfiles = cell(numberOfRegions, 1);
for subject = 1:length(configuration.Subjects)
    subjectDirectory    = sprintf(configuration.SubjectDirectory, configuration.Subjects(subject));
    % load([subjectDirectory configuration.Profiles], 'profiles');
    load([subjectDirectory configuration.Profiles], 'collapsedProfile');

    load([subjectDirectory configuration.Nuisance], 'timecourses');
    nuisanceTimeCourses = [timecourses{:}]; %#ok<USENS>
    motionFile = strrep(ls([subjectDirectory configuration.MotionFile]), '\t', '');
    motionParameters = importdata(motionFile(1:end - 1));

    nuisance = [motionParameters nuisanceTimeCourses ones(size(motionParameters, 1), 1)];
%     nuisance = [motionParameters ones(length(motionParameters), 1)];

    for i = 1:length(collapsedProfile)
        A = nuisance \ collapsedProfile{i}';
        collapsedProfile{i} = bandpass(collapsedProfile{i}' - nuisance * A, configuration.TR, configuration.BandpassLower, configuration.BandpassUpper)'; %#ok<AGROW>
%         collapsedProfile{i} = zscore(bandpass(collapsedProfile{i}' - nuisance * A, configuration.TR, configuration.BandpassLower, configuration.BandpassUpper)', [], 2); %#ok<AGROW>
        concatProfiles{i} = [concatProfiles{i}, collapsedProfile{i}];
    end
    
%     timeCourses = nuisanceTimeCourses;
%     for i = 1:length(collapsedProfile)
%         timeCourses = [timeCourses, collapsedProfile{i}((size(collapsedProfile{i}, 1) + 1) / 2, :)'];
%     end
%     timecourses = cell(size(timeCourses, 2), 1);
%     for i = 1:size(timeCourses, 2)
%         timecourses{i} = timeCourses(:, i);
%     end
%     save([subjectDirectory 'Timecourses/NuisanceWithGM.mat'], 'timecourses');
end

mainFigure = figure;
set(gcf,'Position',get(0,'Screensize'));
for i = 1:numberOfRegions
    for j = 1:i
%         figure
        c = corr(concatProfiles{i}', concatProfiles{j}');
        subplot(numberOfRegions, numberOfRegions, (i - 1) * numberOfRegions + j)
        imagesc(c);
%         X = meshgrid(1:37);
%         Y = X';
%         meshc(X, Y, c);
%         surf(X, Y, c);
        l = length(c);
        hold on;
%         plot([(l - 1) / 3 + 0.5, (l - 1) / 3 + 0.5],[0, l + 1]);
%         plot([2 * (l - 1) / 3 + 1.5, 2 * (l - 1) / 3 + 1.5],[0, l + 1]);
%         plot([0, l + 1],[(l - 1) / 3 + 0.5, (l - 1) / 3 + 0.5]);
%         plot([0, l + 1],[2 * (l - 1) / 3 + 1.5, 2 * (l - 1) / 3 + 1.5]);
        plot([(l - 1) / 4 + 0.5, (l - 1) / 4 + 0.5],[0, l + 1]);
        plot([3 * (l - 1) / 4 + 1.5, 3 * (l - 1) / 4 + 1.5],[0, l + 1]);
        plot([0, l + 1],[(l - 1) / 4 + 0.5, (l - 1) / 4 + 0.5]);
        plot([0, l + 1],[3 * (l - 1) / 4 + 1.5, 3 * (l - 1) / 4 + 1.5]);
        plot([0, l], [0, l]);
%         text(4, 7,'WM', 'FontSize', 24);
%         text(30, 32,'CSF', 'FontSize', 24);
        switch i
            case 1
                ylabel 'MT Left Hemishpere';
            case 2
                ylabel 'V1 Left Hemishpere';
            case 3
                ylabel 'V2 Left Hemishpere';
            case 4
                ylabel 'MT Right Hemishpere';
            case 5
                ylabel 'V1 Right Hemishpere';
            case 6
                ylabel 'V2 Right Hemishpere';
        end
        switch j
            case 1
                xlabel 'MT Left Hemishpere';
            case 2
                xlabel 'V1 Left Hemishpere';
            case 3
                xlabel 'V2 Right Hemishpere';
            case 4
                xlabel 'MT Right Hemishpere';
            case 5
                xlabel 'V1 Right Hemishpere';
            case 6
                xlabel 'V2 Right Hemishpere';
        end

        colorbar;
        axis square;
%         axis off;
        set(gcf,'Position',get(0,'Screensize'));
%         saveas(gca, sprintf('%s%d%d%s', '/home/mrphys/timvmou/Studies/RestingState/Documents/CentralSulcus/MotorCortex', i, j, '.fig'));
%         saveas(gca, sprintf('%s%d%d%s', '/home/mrphys/timvmou/Studies/RestingState/Documents/CentralSulcus/MotorCortex', i, j, '.png'));
    end
end
mtit(mainFigure, configuration.FigureTitle);
saveas(gca, sprintf( '%s', configuration.Image));
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





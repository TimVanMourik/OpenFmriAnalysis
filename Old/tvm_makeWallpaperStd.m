function output = tvm_makeWallpaperStd(configuration)
memtic

concatProfiles = cell(configuration.NumberOfRegions, 1);
for subject = 1:length(configuration.Subjects)
    subjectDirectory    = sprintf(configuration.SubjectDirectory, subject);
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
for i = 1:configuration.NumberOfRegions
    for j = 1:i
        v1 = std(concatProfiles{i}', 1);
        v2 = std(concatProfiles{j}', 1);
        c = zeros(length(v1));
        for k = 1:length(c)
            c(k, :) = v1(k) + v2;
        end
%         figure;
        subplot(configuration.NumberOfRegions, configuration.NumberOfRegions, (i - 1) * configuration.NumberOfRegions + j)
        imagesc(c);
%         X = meshgrid(1:37);
%         Y = X';
%         meshc(X, Y, c);
%         surf(X, Y, c);
        hold on;
        plot([12.5, 12.5],[0, 40]);
        plot([25.5, 25.5],[0, 40]);
        plot([0, 40],[12.5, 12.5]);
        plot([0, 40],[25.5, 25.5]);
%         text(4, 7,'WM', 'FontSize', 24);
%         text(30, 32,'CSF', 'FontSize', 24);
        switch i
            case 1
%                 ylabel 'MT'
%                 ylabel 'Broca (Destrieux Atlas 11112)'
%                 ylabel 'TL'
%                 ylabel 'Left Hemisphere'
%                     ylabel 'Left Hemisphere'

            case 2
%                 ylabel 'V1'
%                 ylabel 'Wernicke (Destrieux Atlas 11101)'
%                 ylabel 'OFC'
%                 ylabel 'Right Hemisphere'
%                     ylabel 'Right Hemisphere'
            case 3
%                 ylabel 'MFG (Destrieux Atlas 11115)'
%                 ylabel 'G temporal middle'
            case 4
%                 ylabel 'Geschwind (Destrieux Atlas 11126)'
        end
        switch j
            case 1
%                 xlabel 'MT'
%                 xlabel 'Left Hemisphere'
%                 xlabel 'Broca (Destrieux Atlas 11112)'
%                 xlabel 'TL'
%                 xlabel 'G temp sup-Lateral'
%                     xlabel 'Left Hemisphere'
            case 2
%                 xlabel 'V1'
%                 xlabel 'G temp sup-G T transv'
%                 xlabel 'Right Hemisphere'
%                 xlabel 'Wernicke (Destrieux Atlas 11101)'
%                 xlabel 'OFC'
%                     xlabel 'Right Hemisphere'
            case 3
%                 xlabel 'G temporal middle'
%                 xlabel 'MFG (Destrieux Atlas 11115)'
            case 4
%                 xlabel 'Geschwind (Destrieux Atlas 11126)'
        end

        colorbar;
        axis square
    end
end
mtit(mainFigure, configuration.FigureTitle);
set(gcf,'Position',get(0,'Screensize'))

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





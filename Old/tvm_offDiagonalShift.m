function output = tvm_offDiagonalShift(configuration)
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

    for i = 1:length(collapsedProfile)
        A = nuisance \ collapsedProfile{i}';
        collapsedProfile{i} = bandpass(collapsedProfile{i}' - nuisance * A, configuration.TR, configuration.BandpassLower, configuration.BandpassUpper)'; %#ok<AGROW>
        concatProfiles{i} = [concatProfiles{i}, collapsedProfile{i}];
    end
    
end

l = size(collapsedProfile{1}, 1);
lrIndices = false(l);
for i = 2:l; lrIndices(i, 1:i - 1) = true; end
lrIndices([1:floor(l / 3), ceil(l * 2 / 3):l], :) = 0;
lrIndices(:, [1:floor(l / 3), ceil(l * 2 / 3):l]) = 0;
rlIndices = lrIndices';
allIndices = lrIndices | rlIndices;

shiftValues = zeros(l);
maxCorrelations = zeros(l);
for i = 1:configuration.NumberOfRegions
    for j = 1:configuration.NumberOfRegions
        c = corr(concatProfiles{i}', concatProfiles{j}');
%         shiftValues(i, j) = log(sum(c(lrIndices)) / sum(c(rlIndices)));
        shiftValues(i, j) = sum(c(lrIndices)) / sum(c(rlIndices));
        maxCorrelations(i, j) = max(c(allIndices));
    end
end
shiftValues(isnan(shiftValues)) = 1;
% shiftValues = shiftValues + 1 ./ shiftValues()';
% shiftValues = shiftValues - eye(length(shiftValues));
% maxCorrelations = maxCorrelations + maxCorrelations';
% maxCorrelations = maxCorrelations - eye(length(maxCorrelations));

sum(shiftValues < 0)
% shiftValues = log(shiftValues);
mainFigure = figure;
imagesc(shiftValues);
colorbar;
axis square
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





function overlayImage = tvm_showObjectContourOnSlice(configuration)
%
%
%   Copyright (C) Tim van Mourik, 2015, DCCN
%

%% Parse configuration
volume =            tvm_getOption(configuration, 'i_Volume');
    %no default
slice =             tvm_getOption(configuration, 'i_Slice');
    %no default
vertices =          tvm_getOption(configuration, 'i_Vertices');
    %no default
faceData =          tvm_getOption(configuration, 'i_Faces');
    %no default
sliceAxis =         tvm_getOption(configuration, 'i_Axis', 'z');
    %no default
colorRange =      	tvm_getOption(configuration, 'i_ColorLimits', []);
    %
contourColours =   	tvm_getOption(configuration, 'i_ContourColors', {'y', 'r', 'g', 'b'});
    %no default
colorMap =          tvm_getOption(configuration, 'i_ColorMap', []);
    %
    
%%

%create a figure, possibly invisble, if it's only used for saving, not
%showing

% @todo the figure() lines have been removed such that it behaves more like
% a regular matlab image function and you can choose to call a figure
% first.

% screenSize = get(0, 'ScreenSize');
% overlayImage = figure('Visible', visibility, 'units', 'normalized', 'outerposition', [0, 0, 1, 1]);
% subplot('position', [0, 0, 1, 1]);

switch sliceAxis
    case {'x', 'coronal'}
        imageData = squeeze(volume(slice, :, :));
        imageData = permute(imageData, [2, 1]);
        dimension = 1;
        xDimension = 2;
        yDimension = 3;
    case {'y', 'sagittal'}
        imageData = squeeze(volume(:, slice, :));
        imageData = permute(imageData, [2, 1]);
        dimension = 2;
        xDimension = 1;
        yDimension = 3;
    case {'z', 'transversal', 'transverse', 'horizontal'}
        imageData = squeeze(volume(:, :, slice));
        dimension = 3;
        xDimension = 2;
        yDimension = 1;
        axis square;
    otherwise
        error('Invalid Axis');
end

if isempty(colorRange)
    colorRange = [min(imageData(:)), max(imageData(:))];
end
colormap('gray');
imagesc(imageData, colorRange);
set(gca, 'YDir', 'normal')
hold on;

%draws the vertices close to the slice
for i = 1:length(vertices)
    for j = 1:length(vertices{i})
        drawCrossSection(vertices{i}{j}, faceData{i}{j}, slice, dimension, xDimension, yDimension, contourColours{i});
    end
end
 
% axis equal tight off
% set(gcf, ...
%     'units', 'normalized', ...
%     'outerposition', [0, 0, screenSize(4) / screenSize(3), 1]);

if ~isempty(colorMap)
    colormap(colorMap);
end

end %end function

function drawCrossSection(vertices, faces, slice, sliceDimension, xDimension, yDimension, colour)

    faceVertices = vertices(faces(:), sliceDimension);
    faceVertices = reshape(faceVertices, size(faces));
    %the faces on the border have one or two vertices on the one side, the
    %other(s) on the other side of the border.
    borderliners = faceVertices < slice;
    borderline = find(sum(borderliners, 2) == 1 | sum(borderliners, 2) == 2);
    faces = faces(borderline, :)';
    borderliners = borderliners(borderline, :);
    borderliners(sum(borderliners, 2) == 2, :) = ~borderliners(sum(borderliners, 2) == 2, :);

    beginPoints = vertices(faces(borderliners'), 1:3);
    endPoints = vertices(faces(~borderliners'), 1:3);
    endPoints = permute(reshape(endPoints', [size(beginPoints, 2), 2, size(beginPoints, 1)]), [3, 1, 2]);
    edges = bsxfun(@minus, endPoints, beginPoints);
    lineCoordinates = bsxfun(@plus, beginPoints, bsxfun(@times, bsxfun(@rdivide, slice - beginPoints(:, sliceDimension), edges(:, sliceDimension, :)), edges));
    quiver( lineCoordinates(:, xDimension, 1), ...
            lineCoordinates(:, yDimension, 1), ...
            lineCoordinates(:, xDimension, 2) - lineCoordinates(:, xDimension, 1), ...
            lineCoordinates(:, yDimension, 2) - lineCoordinates(:, yDimension, 1), ...
            'ShowArrowHead', 'off', ...
            'AutoScale', 'off', ...
            'Color', colour);

end %end function






















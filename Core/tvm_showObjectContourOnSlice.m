function tvm_showObjectContourOnSlice(configuration)
%
%
%   Copyright (C) Tim van Mourik, 2015, DCCN
%

%% Parse configuration
volume =            tvm_getOption(configuration, 'i_Volume');
    %no default
roi =               tvm_getOption(configuration, 'i_ROI', '');
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
rotation =          tvm_getOption(configuration, 'i_Rotation', '');
    % ''
colorMap =          tvm_getOption(configuration, 'i_ColorMap', []);
    %
    
%%

%create a figure, possibly invisble, if it's only used for saving, not
%showing

% @todo the figure() lines have been removed such that it behaves more like
% a regular matlab image function and you can choose to call a figure
% first.
if isempty(roi)
    roi = zeros(size(volume));
end

switch sliceAxis
    case {'x', 'coronal', 1}
        imageData = squeeze(volume(slice, :, :));
        imageData = permute(imageData, [2, 1]);
        roiData = squeeze(roi(slice, :, :));
        roiData = permute(roiData, [2, 1]);
        dimension = 1;
        xDimension = 2;
        yDimension = 3;
    case {'y', 'sagittal', 2}
        imageData = squeeze(volume(:, slice, :));
        imageData = permute(imageData, [2, 1]);
        roiData = squeeze(roi(:, slice, :));
        roiData = permute(roiData, [2, 1]);
        dimension = 2;
        xDimension = 1;
        yDimension = 3;
    case {'z', 'transversal', 'transverse', 'horizontal', 3}
        imageData = squeeze(volume(:, :, slice));
        roiData = squeeze(roi(:, :, slice));
        dimension = 3;
        xDimension = 2;
        yDimension = 1;
        axis square;
    otherwise
        error('Invalid Axis');
end

switch rotation
    case ''
        set(gca, 'YDir', 'normal');
    case {'left', '90'}
        set(gca, 'YDir', 'normal');
        imageData = permute(fliplr(imageData), [2, 1]);
        roiData = permute(fliplr(roiData), [2, 1]);
    case {'right', '-90'}
        set(gca, 'YDir', 'reverse');
        imageData = fliplr(permute(imageData, [2, 1]));
        roiData = fliplr(permute(roiData, [2, 1]));
    case {'180', 'OneHundredAndEeeeeeighty'}
        set(gca, 'YDir', 'reverse');
end

if isempty(colorRange)
    colorRange = [min(imageData(:)), max(imageData(:))];
end

imagesc(imageData, colorRange);
colormap('gray');
% Make a truecolor all-green image.
red = cat(3, ones(size(imageData)), zeros(size(imageData)), zeros(size(imageData)));
hold('on');
h = imshow(red); 
set(h, 'AlphaData', 0.4 * roiData);

%draws the vertices close to the slice
for i = 1:length(vertices)
    for j = 1:length(vertices{i})
        
        switch rotation
            case ''
            case {'left', '90'}
                vertices{i}{j} = [size(volume, 2) - vertices{i}{j}(:, 2), vertices{i}{j}(:, 1), vertices{i}{j}(:, 3)];
            case {'right', '-90'}
                vertices{i}{j} = [vertices{i}{j}(:, 2), size(volume, 1) - vertices{i}{j}(:, 1), vertices{i}{j}(:, 3)];
            case {'180', 'OneHundredAndEeeeeeighty'}
                vertices{i}{j} = [size(volume, 1) - vertices{i}{j}(:, 1), size(volume, 2) - vertices{i}{j}(:, 2), vertices{i}{j}(:, 3)];
        end
        drawCrossSection(vertices{i}{j}, faceData{i}{j}, slice, dimension, xDimension, yDimension, contourColours{i});
    end
end
 
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






















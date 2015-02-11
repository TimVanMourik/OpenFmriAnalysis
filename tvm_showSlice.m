function tvm_showSlice(volume, slice, verticesA, verticesB, sliceAxis)
%
%

if nargin < 5
    sliceAxis = 'z';
end

%shows the slice
figure('units','normalized','outerposition',[0 0 1 1]);
colormap gray;

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
imagesc(imageData);
set(gca, 'YDir', 'normal')
hold on;

%draws the vertices close to the slice
width = 0.3;
for hemisphere = 1:2
    ind = find((verticesA{hemisphere}(:, dimension) > slice - width & verticesA{hemisphere}(:, dimension) < slice + width));   
    scatter(verticesA{hemisphere}(ind, xDimension), verticesA{hemisphere}(ind, yDimension), 1, 'r', 'filled');
    ind = find((verticesB{hemisphere}(:, dimension) > slice - width & verticesB{hemisphere}(:, dimension) < slice + width));
    scatter(verticesB{hemisphere}(ind, xDimension), verticesB{hemisphere}(ind, yDimension), 1, 'y', 'filled');
end

end %end function

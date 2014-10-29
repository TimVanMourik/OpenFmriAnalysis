function tvm_showSlice(volume, slice, verticesA, verticesB, sliceAxis)
%
%
if nargin < 5
    sliceAxis = 'z';
end

%shows the slice
figure('units','normalized','outerposition',[0 0 1 1]);
colormap gray;

if sliceAxis == 'x'
    imagesc(volume(slice, :, :));
    dimension = 1;
elseif sliceAxis == 'y'
    imagesc(volume(:, slice, :));
    dimension = 2;
elseif sliceAxis == 'z'
    imagesc(volume(:, :, slice));
    dimension = 3;
end
set(gca, 'YDir', 'normal')
hold on;
axis square;

%draws the vertices close to the slice
for hemisphere = 1:2
    width = 0.3;
    ind = find((verticesA{hemisphere}(:, dimension) > slice - width & verticesA{hemisphere}(:, dimension) < slice + width));   
    scatter(verticesA{hemisphere}(ind, 2), verticesA{hemisphere}(ind,1), 1, 'r', 'filled');
    ind = find((verticesB{hemisphere}(:, dimension) > slice - width & verticesB{hemisphere}(:, dimension) < slice + width));
    scatter(verticesB{hemisphere}(ind, 2), verticesB{hemisphere}(ind,1), 1, 'y', 'filled');
end

end %end function

function showSlice(volume, slice, verticesA, verticesB)
%
%

%shows the slice
figure('units','normalized','outerposition',[0 0 1 1]); 
colormap gray;
imagesc(volume(:,:,slice));
hold on;

%draws the vertices close to the slice
for hemisphere = 1:2
    width = 0.3;
    ind = find((verticesA{hemisphere}(:,3) > slice - width & verticesA{hemisphere}(:,3) < slice + width) | (verticesB{hemisphere}(:,3) > slice - width & verticesB{hemisphere}(:,3) < slice + width));   
    scatter(verticesA{hemisphere}(ind, 2), verticesA{hemisphere}(ind,1), 1, 'r', 'filled');
    scatter(verticesB{hemisphere}(ind, 2), verticesB{hemisphere}(ind,1), 1, 'b', 'filled');
end

end %end function

function [vertices, indices] = selectVertices(vertices, selectionGrid)
%SELECTVERTICES select vertices from a selection grid
%   OV = SELECTVERTICES(IV, SELECTIONGRID)
%   The input vertices IV that are selected according to the SELECTIONGRID
%   are returned in OV.
%   [OV, INDICES] = SELECTVERTICES(IV, SELECTIONGRID)
%   The input vertices IV that are selected according to the SELECTIONGRID
%   are returned as well as the indices in IV.

xMax = size(selectionGrid, 1);
yMax = size(selectionGrid, 2);
zMax = size(selectionGrid, 3);

outsideX = vertices(:, 1) > xMax;
outsideY = vertices(:, 2) > yMax;
outsideZ = vertices(:, 3) > zMax;

insideVolume = all(vertices(:, 1:3) > 1, 2) & ~outsideX & ~outsideY & ~outsideZ;

vertices(vertices(:, 1) > xMax, 1) = xMax;
vertices(vertices(:, 2) > yMax, 2) = yMax;
vertices(vertices(:, 3) > zMax, 3) = zMax;

vertices(vertices < 1) = 1;

floorVertices = floor(vertices);
ceilingVertices = ceil(vertices);

%indices = selectionGrid(sub2ind(size(selectionGrid), floorVertices(:, 1), floorVertices(:, 2), floorVertices(:, 3))) & selectionGrid(sub2ind(size(selectionGrid), floorVertices(:, 1), floorVertices(:, 2), ceilingVertices(:, 3))) & selectionGrid(sub2ind(size(selectionGrid), floorVertices(:, 1), ceilingVertices(:, 2), floorVertices(:, 3))) & selectionGrid(sub2ind(size(selectionGrid), floorVertices(:, 1), ceilingVertices(:, 2), ceilingVertices(:, 3))) & selectionGrid(sub2ind(size(selectionGrid), ceilingVertices(:, 1), floorVertices(:, 2), floorVertices(:, 3))) & selectionGrid(sub2ind(size(selectionGrid), ceilingVertices(:, 1), floorVertices(:, 2), ceilingVertices(:, 3))) & selectionGrid(sub2ind(size(selectionGrid), ceilingVertices(:, 1), ceilingVertices(:, 2), floorVertices(:, 3))) & selectionGrid(sub2ind(size(selectionGrid), ceilingVertices(:, 1), ceilingVertices(:, 2), ceilingVertices(:, 3)));
indices = (selectionGrid(sub2ind(size(selectionGrid), floorVertices(:, 1), floorVertices(:, 2), floorVertices(:, 3))) + selectionGrid(sub2ind(size(selectionGrid), floorVertices(:, 1), floorVertices(:, 2), ceilingVertices(:, 3))) + selectionGrid(sub2ind(size(selectionGrid), floorVertices(:, 1), ceilingVertices(:, 2), floorVertices(:, 3))) + selectionGrid(sub2ind(size(selectionGrid), floorVertices(:, 1), ceilingVertices(:, 2), ceilingVertices(:, 3))) + selectionGrid(sub2ind(size(selectionGrid), ceilingVertices(:, 1), floorVertices(:, 2), floorVertices(:, 3))) + selectionGrid(sub2ind(size(selectionGrid), ceilingVertices(:, 1), floorVertices(:, 2), ceilingVertices(:, 3))) + selectionGrid(sub2ind(size(selectionGrid), ceilingVertices(:, 1), ceilingVertices(:, 2), floorVertices(:, 3))) + selectionGrid(sub2ind(size(selectionGrid), ceilingVertices(:, 1), ceilingVertices(:, 2), ceilingVertices(:, 3))) > 4);

vertices = vertices(indices & insideVolume, :);

if nargout > 1
    indices = find(indices & insideVolume);
end

end %end function

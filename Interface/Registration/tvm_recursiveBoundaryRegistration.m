function tvm_recursiveBoundaryRegistration(configuration, registrationConfiguration)
% TVM_RECURSIVEBOUNDARYREGISTRATION
%   TVM_RECURSIVEBOUNDARYREGISTRATION(configuration)
%   @todo Add description
%
% Input:
%   i_SubjectDirectory
%   i_ReferenceVolume
%   i_Boundaries
%   i_Mask
%   i_MinimumVoxels
%   i_MinimumVertices
%   i_CuboidElements
%   i_Tetrahedra
%   i_NeighbourSmoothing
%   i_Mode
%   i_ReverseContrast
%   i_OptimisationMethod
%   i_ContrastMethod
%
% Output:
%   o_Boundaries
%   o_DisplacementMap
%

%   Copyright (C) Tim van Mourik, 2014-2016, DCCN
%
% This file is part of the fmri analysis toolbox, see 
% https://github.com/TimVanMourik/FmriAnalysis for the documentation and 
% details.
%
%    This toolbox is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    This toolbox is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with the fmri analysis toolbox. If not, see 
%    <http://www.gnu.org/licenses/>.

%% Parse configuration
subjectDirectory        = tvm_getOption(configuration, 'i_SubjectDirectory', pwd());
    % default: current working directory
referenceFile           = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_ReferenceVolume'));
    %no default
boundariesFileIn        = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_Boundaries'));
    %no default
minSize                 = tvm_getOption(configuration, 'i_MinimumVoxels', 10);
    % default: empty
minVertices             = tvm_getOption(configuration, 'i_MinimumVertices', 500);
    % default: empty
cuboidelements          = tvm_getOption(configuration, 'i_CuboidElements', true);
    % default: empty
addTetrahedraStructure  = tvm_getOption(configuration, 'i_Tetrahedra', false);
    % default: empty
alphaLevel              = tvm_getOption(configuration, 'i_NeighbourSmoothing', 0.5);
    % default: empty
maskFile                = tvm_getOption(configuration, 'i_Mask', '');
    % default: empty
boundariesFileOut       = fullfile(subjectDirectory, tvm_getOption(configuration, 'o_Boundaries'));
    %no default
displacementMap         = tvm_getOption(configuration, 'o_DisplacementMap', []);
    % default: empty

%% if you wanna specify all options in one go instead of two different options:
if nargin == 1
    registrationConfiguration = [];
    if isfield(configuration, 'i_ReverseContrast')
        registrationConfiguration.ReverseContrast = configuration.i_ReverseContrast;
    end
    if isfield(configuration, 'i_OptimisationMethod')
        registrationConfiguration.OptimisationMethod = configuration.i_OptimisationMethod;
    end
    if isfield(configuration, 'i_ContrastMethod')
        registrationConfiguration.ContrastMethod = configuration.i_ContrastMethod;
    end
    if isfield(configuration, 'i_Mode')
        registrationConfiguration.Mode = configuration.i_Mode;
    end
end
    
definitions = tvm_definitions();

%% Just loading data
referenceVolume = spm_vol(referenceFile);
referenceVolume.volume = spm_read_vols(referenceVolume);

if isempty(maskFile)
    mask = true(referenceVolume.dim);
else
    maskFile = fullfile(subjectDirectory, maskFile);
    mask = ~~spm_read_vols(spm_vol(maskFile));
end

load(boundariesFileIn, definitions.WhiteMatterSurface, definitions.PialSurface, definitions.FaceData);
wSurface = eval(definitions.WhiteMatterSurface);
pSurface = eval(definitions.PialSurface);
faceData = eval(definitions.FaceData);

for hemisphere = 1:2
    if size(wSurface{hemisphere}, 2) == 3
        wSurface{hemisphere} = [wSurface{hemisphere}, ones(size(wSurface{hemisphere}, 1), 1)]; 
        pSurface{hemisphere} = [pSurface{hemisphere}, ones(size(pSurface{hemisphere}, 1), 1)]; 
    end
end

registereSurfaceW = vertcat(wSurface{:});
registereSurfaceP = vertcat(pSurface{:});
[~, selectedVerticesW] = selectVertices(registereSurfaceW, mask);
[~, selectedVerticesP] = selectVertices(registereSurfaceP, mask);
selectedVertices = selectedVerticesW & selectedVerticesP;
% clear('mask', 'selectedVerticesW', 'selectedVerticesP');

registereSurfaceW = registereSurfaceW(selectedVertices, :);
registereSurfaceP = registereSurfaceP(selectedVertices, :);

%% The real implementation
dimensions = referenceVolume.dim; % .* sqrt(sum(referenceVolume.mat(1:3, 1:3) .^ 2));
numberOfVertices = prod(referenceVolume.dim);
[x, y, z] = ndgrid(1:referenceVolume.dim(1), 1:referenceVolume.dim(2), 1:referenceVolume.dim(3)); 

%divide the mesh
root                = [];
root.anchorPoints   = [min([registereSurfaceW; registereSurfaceP]) - 2 * eps(); ...
                       max([registereSurfaceW; registereSurfaceP]) + 2 * eps()];
indices             = [ceil(min([registereSurfaceW; registereSurfaceP])); ...
                       floor(max([registereSurfaceW; registereSurfaceP]))];
boundingBox         = false(dimensions);
boundingBox(indices(1, 1):indices(2, 1), ...
            indices(1, 2):indices(2, 2), ...
            indices(1, 3):indices(2, 3)) = true;

root.anchorPoints   = root.anchorPoints(:, 1:3);
root.vertexIndices  = (1:size(registereSurfaceW, 1))';
root.voxelIndices   = find(boundingBox);

minSize             = max(1, minSize);
voxelCoordinates    = [x(:), y(:), z(:), ones(numberOfVertices, 1)];
%find neighbours in mesh
root                = divideMesh(root, registereSurfaceW, voxelCoordinates, minSize);
[root, anchors]     = addNeighbourStructure(root);

if ~isempty(displacementMap)
    displacementMap = fullfile(subjectDirectory, displacementMap);
    withDisplacementMap = true;
else
    withDisplacementMap = false;
end

if addTetrahedraStructure
    root = addTetrahedra(root, registereSurfaceW, voxelCoordinates, withDisplacementMap);    
    tetrahedra = [5, 1, 2, 3; ...
                  6, 5, 2, 3; ...
                  6, 7, 5, 3; ...
                  6, 4, 7, 3; ...
                  6, 2, 4, 3; ...
                  6, 8, 7, 4];
end

%%
for level = 0:floor(log2(max(dimensions) / minSize)) - 1 %per level, as smoothing is per level
    elementsCurrentLevel = elementsLevelN(root, level);
    if isempty(elementsCurrentLevel)
        break;
    end
    [neighbourList, relevantAnchors] = neighbourStructure(elementsCurrentLevel, anchors, cuboidelements);
    deformationVectors = cell(size(relevantAnchors));
    %compute
    for i = 1:length(elementsCurrentLevel)
        % transformation for the whole
        if length(elementsCurrentLevel(i).vertexIndices) >= minVertices
            elementsCurrentLevel(i).transformation = optimalTransformation(registereSurfaceW(elementsCurrentLevel(i).vertexIndices, :), ...
                                                                           registereSurfaceP(elementsCurrentLevel(i).vertexIndices, :), ...
                                                                           referenceVolume.volume, registrationConfiguration);
        else
            elementsCurrentLevel(i).transformation = eye(4);
        end
        % add to list
        for j = 1:length(elementsCurrentLevel(i).anchorIndices)
            index = find(relevantAnchors == elementsCurrentLevel(i).anchorIndices(j));
            deformationVectors{index} = [deformationVectors{index}; anchors(elementsCurrentLevel(i).anchorIndices(j), :) * (elementsCurrentLevel(i).transformation - eye(4))];
        end
        % transformation for the cuboid elements
        if cuboidelements
            for k = 1:length(elementsCurrentLevel(i).cuboids)
                if length(elementsCurrentLevel(i).cuboids(k).vertexIndices) >= minVertices
                    elementsCurrentLevel(i).cuboids(k).transformation = optimalTransformation(registereSurfaceW(elementsCurrentLevel(i).cuboids(k).vertexIndices, :), ...
                                                                                              registereSurfaceP(elementsCurrentLevel(i).cuboids(k).vertexIndices, :), ...
                                                                                              referenceVolume.volume, registrationConfiguration);
                else
                    elementsCurrentLevel(i).cuboids(k).transformation = eye(4);
                end
                % add to list
                for j = 1:length(elementsCurrentLevel(i).cuboids(k).anchorIndices)
                    index = find(relevantAnchors == elementsCurrentLevel(i).cuboids(k).anchorIndices(j));
                    deformationVectors{index} = [deformationVectors{index}; anchors(elementsCurrentLevel(i).cuboids(k).anchorIndices(j), :) * (elementsCurrentLevel(i).cuboids(k).transformation - eye(4))];
                end
            end     
        end
    end
    
    %smooth anchor points
    medianDeformation = cellfun(@median, deformationVectors, num2cell(ones(size(deformationVectors))), 'UniformOutput', false);
    deformationVectorsSmoothed = cell(size(relevantAnchors));
    for i = 1:length(relevantAnchors)
        neighbourVector = mean(vertcat(medianDeformation{cell2mat(cellfun(@find, cellfun(@eq, repmat({relevantAnchors}, size(neighbourList{i})), num2cell(neighbourList{i}), 'UniformOutput', false), 'UniformOutput', false))}));
        %overwrite with the median
        deformationVectorsSmoothed{i} = (1 - alphaLevel) * medianDeformation{i} + alphaLevel * neighbourVector;
    end
    anchors(relevantAnchors, :) = anchors(relevantAnchors, :) + cat(1, deformationVectorsSmoothed{:});
    
    %deform mesh
    for i = 1:length(elementsCurrentLevel)
        if addTetrahedraStructure
            for j = 1:6
                currentAnchors = anchors(elementsCurrentLevel(i).anchorIndices(tetrahedra(j, :)), :);
                deformations = cat(1, deformationVectorsSmoothed{cell2mat(cellfun(@find, cellfun(@eq, repmat({relevantAnchors}, size(elementsCurrentLevel(i).anchorIndices(tetrahedra(j, :)))), num2cell(elementsCurrentLevel(i).anchorIndices(tetrahedra(j, :))), 'UniformOutput', false), 'UniformOutput', false))});
                centreOfMass = mean(currentAnchors, 1);
                T = eye(4);
                T(4, :) = centreOfMass;
                transformedAnchors = currentAnchors / T;
                M = transformedAnchors \ deformations;
                
                % white matter surface coordinates
                registereSurfaceW(elementsCurrentLevel(i).vertexIndices(elementsCurrentLevel(i).vertexTetrahedra(:, j)), :) = registereSurfaceW(elementsCurrentLevel(i).vertexIndices(elementsCurrentLevel(i).vertexTetrahedra(:, j)), :) + registereSurfaceW(elementsCurrentLevel(i).vertexIndices(elementsCurrentLevel(i).vertexTetrahedra(:, j)), :) / T * M;
                % pial surface coordinates
                registereSurfaceP(elementsCurrentLevel(i).vertexIndices(elementsCurrentLevel(i).vertexTetrahedra(:, j)), :) = registereSurfaceP(elementsCurrentLevel(i).vertexIndices(elementsCurrentLevel(i).vertexTetrahedra(:, j)), :) + registereSurfaceP(elementsCurrentLevel(i).vertexIndices(elementsCurrentLevel(i).vertexTetrahedra(:, j)), :) / T * M;
                 % voxel coordinates
                 if withDisplacementMap
                    voxelCoordinates(elementsCurrentLevel(i).voxelIndices(elementsCurrentLevel(i).voxelTetrahedra(:, j)), :) = voxelCoordinates(elementsCurrentLevel(i).voxelIndices(elementsCurrentLevel(i).voxelTetrahedra(:, j)), :) + voxelCoordinates(elementsCurrentLevel(i).voxelIndices(elementsCurrentLevel(i).voxelTetrahedra(:, j)), :) / T * M;
                 end
            end
        else
            currentAnchors = anchors(elementsCurrentLevel(i).anchorIndices, :);
            deformations = cat(1, deformationVectorsSmoothed{cell2mat(cellfun(@find, cellfun(@eq, repmat({relevantAnchors}, size(elementsCurrentLevel(i).anchorIndices)), num2cell(elementsCurrentLevel(i).anchorIndices), 'UniformOutput', false), 'UniformOutput', false))});
            centreOfMass = mean(currentAnchors, 1);
            T = eye(4);
            T(4, :) = centreOfMass;
            transformedAnchors = currentAnchors / T;
            M = transformedAnchors \ deformations;
            % white matter surface coordinates
            registereSurfaceW(elementsCurrentLevel(i).vertexIndices, :) = registereSurfaceW(elementsCurrentLevel(i).vertexIndices, :) + registereSurfaceW(elementsCurrentLevel(i).vertexIndices, :) / T * M;
            % pial surface coordinates
            registereSurfaceP(elementsCurrentLevel(i).vertexIndices, :) = registereSurfaceP(elementsCurrentLevel(i).vertexIndices, :) + registereSurfaceP(elementsCurrentLevel(i).vertexIndices, :) / T * M;
            % voxel coordinates
            if withDisplacementMap
                voxelCoordinates(elementsCurrentLevel(i).voxelIndices, :) = voxelCoordinates(elementsCurrentLevel(i).voxelIndices, :) + voxelCoordinates(elementsCurrentLevel(i).voxelIndices, :) / T * M;
            end
        end
    end
end

%% Saving output
w1 = selectedVertices(1:length(wSurface{1}));
wSurface{1}(w1, :) = registereSurfaceW(1:sum(w1), :);
pSurface{1}(w1, :) = registereSurfaceP(1:sum(w1), :);
w2 = selectedVertices((end + 1 - length(wSurface{2})):end);
wSurface{2}(w2, :) = registereSurfaceW(end - sum(w2) + 1:end, :);
pSurface{2}(w2, :) = registereSurfaceP(end - sum(w2) + 1:end, :);
save(boundariesFileOut, definitions.WhiteMatterSurface, definitions.PialSurface, definitions.FaceData);

if withDisplacementMap
    referenceVolume.dt = [64, 0];
    tvm_write4D(referenceVolume, reshape([x(:), y(:), z(:)] - voxelCoordinates(:, 1:3), [dimensions, 3]), displacementMap);
end

end %end function


function [neighbourList, relevantAnchors] = neighbourStructure(elements, anchors, withCuboids)
neighbourList = cell(length(anchors), 1);
%This is a struture that shows the neighbour vertices in a cube
neighbours = [2, 3, 5;
              1, 4, 6;
              1, 4, 7;
              2, 3, 8;
              1, 6, 7
              2, 5, 8
              3, 5, 8
              4, 6, 7];
          
for i = 1:length(elements)
    for k = 1:size(neighbours, 1)
        neighbourList{elements(i).anchorIndices(k)} = [neighbourList{elements(i).anchorIndices(k)}, elements(i).anchorIndices(neighbours(k, 1)), elements(i).anchorIndices(neighbours(k, 2)), elements(i).anchorIndices(neighbours(k, 3))];
    end

    if withCuboids
        for j = 1:length(elements(i).cuboids)
            for k = 1:size(neighbours, 1)
                neighbourList{elements(i).cuboids(j).anchorIndices(k)} = [neighbourList{elements(i).cuboids(j).anchorIndices(k)}, elements(i).cuboids(j).anchorIndices(neighbours(k, 1)), elements(i).cuboids(j).anchorIndices(neighbours(k, 2)), elements(i).cuboids(j).anchorIndices(neighbours(k, 3))];
            end
        end
    end
end

relevantAnchors = find(~cellfun(@isempty, neighbourList));
neighbourList = neighbourList(relevantAnchors);
neighbourList = cellfun(@unique, neighbourList, 'UniformOutput', false);
end %end function


function root = divideMesh(root, coordinates, voxels, minSize)
    root = recursiveDivision(root);

    function root = recursiveDivision(root)
    anchorPoints = cellfun(@linspace, ...
                           num2cell(root.anchorPoints(1, :)), ...
                           num2cell(root.anchorPoints(2, :)), ...
                           num2cell(3 * ones(size(root.anchorPoints(1, :)))), ...
                           'UniformOutput', false);
    % cuboid division
    root.cuboids = [];
    for d = 1:3
        boxSize = [1, 1, 1];
        boxSize(d) = 2;
        cuboidAnchors = cellfun(@(a)a([1,3]), anchorPoints, 'UniformOutput', false);
        cuboidAnchors{d} = anchorPoints{d};
        boundaries = chopUpBox(cuboidAnchors, boxSize);
        newAnchorPoints = {num2cell(boundaries, [1,2])};
        cuboids = repmat(struct(), [1, prod(boxSize)]);
        cuboids = cellfun(@setfield, num2cell(cuboids), repmat({'vertexIndices'}, [1, prod(boxSize)]), divideIntoCategories(coordinates, root.vertexIndices, cuboidAnchors, boxSize));
        cuboids = cellfun(@setfield, num2cell(cuboids), repmat({'anchorPoints'}, [1, prod(boxSize)]), squeeze(newAnchorPoints{:})', 'UniformOutput', false);
        root.cuboids = [root.cuboids, cuboids{:}];
    end     

    % spawn children 
    boxSize = [2, 2, 2];
    boundaries = chopUpBox(anchorPoints, boxSize);
    newBoxDimensions = boundaries(2, :, 1) - boundaries(1, :, 1);
    if any(newBoxDimensions < minSize);
        root.children = {};
        return;
    end
    newAnchorPoints = {num2cell(boundaries, [1,2])};
    children = repmat(struct(), [1, prod(boxSize)]);
    children = cellfun(@setfield, num2cell(children), repmat({'vertexIndices'}, [1, prod(boxSize)]), divideIntoCategories(coordinates, root.vertexIndices, anchorPoints, boxSize));
    children = cellfun(@setfield, num2cell(children), repmat({'voxelIndices'},  [1, prod(boxSize)]), divideIntoCategories(voxels, root.voxelIndices, anchorPoints, boxSize));
    children = cellfun(@setfield, num2cell(children), repmat({'anchorPoints'},  [1, prod(boxSize)]), squeeze(newAnchorPoints{:})');
    root.children = children;
    
    %clear out memory before recursion
    clear('xi', 'yi', 'zi', 'ind', 'newBoxDimensions', 'newAnchorPoints', 'd', 'cuboids', 'cuboidAnchors', 'children', 'boxSize', 'boundaries', 'anchorPoints');
    root.children = cellfun(@recursiveDivision, num2cell(root.children), 'UniformOutput', false);
    end %end function
end %end function


function boundaries = chopUpBox(anchorPoints, boxSize)
[xi, yi, zi] = meshgrid(1:boxSize(1), 1:boxSize(2), 1:boxSize(3));
boundaries = permute(cat(3, ...
    [anchorPoints{1}(xi(:)); ...
    anchorPoints{1}(xi(:) + 1)], ...
    [anchorPoints{2}(yi(:)); ...
    anchorPoints{2}(yi(:) + 1)], ...
    [anchorPoints{3}(zi(:)); ...
    anchorPoints{3}(zi(:) + 1)]), [1, 3, 2]);
end %end function


function categories = divideIntoCategories(coordinates, indices, anchorPoints, boxSize)
xi = sum(bsxfun(@gt, coordinates(indices, 1), anchorPoints{1}), 2);
yi = sum(bsxfun(@gt, coordinates(indices, 2), anchorPoints{2}), 2);
zi = sum(bsxfun(@gt, coordinates(indices, 3), anchorPoints{3}), 2);

ind = sub2ind(boxSize([2, 1, 3]), yi, xi, zi);
categories = cellfun(@find, ...
                cellfun(@eq, ...
                    repmat({ind}, [1, prod(boxSize)]), ...
                    num2cell(1:prod(boxSize)), ...
                    'UniformOutput', false), ...
                'UniformOutput', false);
categories = cellfun(@(a,b) a(b), repmat({indices}, size(categories)), categories, 'UniformOutput', false);
end %end function


function [root, anchorPoints] = addNeighbourStructure(root)
anchorPoints = [];
root = addAnchors(root);
[anchorPoints, ~, indices] = unique(anchorPoints, 'rows');
root = replaceAnchors(root);
anchorPoints = [anchorPoints, ones(size(anchorPoints, 1), 1)];

    function root = addAnchors(root)
    root.anchorIndices = 1+length(anchorPoints):length(anchorPoints) + 8;
    anchorPoints = cat(1, anchorPoints, toBoundingBox(root.anchorPoints(1, :), root.anchorPoints(2, :)));
    if ~isempty(root.cuboids)
        for k = 1:length(root.cuboids)
            root.cuboids(k).anchorIndices = 1+length(anchorPoints):length(anchorPoints) + 8;
            anchorPoints = cat(1, anchorPoints, toBoundingBox(root.cuboids(k).anchorPoints(1, :), root.cuboids(k).anchorPoints(2, :)));
        end
    end
    if ~isempty(root.children);
        root.children = cellfun(@addAnchors, root.children, 'UniformOutput', false);
    end
    end %end function

    function root = replaceAnchors(root)
    root.anchorIndices = indices(root.anchorIndices);
    if ~isempty(root.cuboids)
        for k = 1:length(root.cuboids)
            root.cuboids(k).anchorIndices = indices(root.cuboids(k).anchorIndices);
        end
    end
    if ~isempty(root.children);
        root.children = cellfun(@replaceAnchors, root.children, 'UniformOutput', false);
    end
    end %end function

end %end function


function root = addTetrahedra(root, coordinates, voxels, withVoxels)
root = recursivelyAddTetrahedra(root);

    function root = recursivelyAddTetrahedra(root)
    boundingBox = toBoundingBox(root.anchorPoints(1, :), root.anchorPoints(2, :));

    %Check which vertices are inside tetrahedra
    tetrahedra = [5, 1, 2, 3; ...
                  6, 5, 2, 3; ...
                  6, 7, 5, 3; ...
                  6, 4, 7, 3; ...
                  6, 2, 4, 3; ...
                  6, 8, 7, 4];

    tetrahedra = permute(reshape(boundingBox(tetrahedra, :), [6, 4, 3]), [2, 3, 1]);
    tetrahedra = cat(2, tetrahedra, ones(4, 1, 6));    
    elementCoordinates = coordinates(root.vertexIndices, :);
    elementVoxels = voxels(root.voxelIndices, :);
    root.vertexTetrahedra = false(size(elementCoordinates, 1), 6);
    root.voxelTetrahedra = false(size(elementVoxels, 1), 6);
    for j = 1:6
%         add vertices
        d0 = cat(3, repmat(cat(3, tetrahedra(1, :, j), tetrahedra(2, :, j), tetrahedra(3, :, j), tetrahedra(4, :, j)), [size(elementCoordinates, 1), 1, 1]));
        d1 = cat(3, elementCoordinates, repmat(cat(3, tetrahedra(2, :, j), tetrahedra(3, :, j), tetrahedra(4, :, j)), [size(elementCoordinates, 1), 1, 1]));
        d2 = cat(3, repmat(tetrahedra(1, :, j), [size(elementCoordinates, 1), 1, 1]), elementCoordinates, repmat(cat(3, tetrahedra(3, :, j), tetrahedra(4, :, j)), [size(elementCoordinates, 1), 1, 1]));
        d3 = cat(3, repmat(cat(3, tetrahedra(1, :, j), tetrahedra(2, :, j)), [size(elementCoordinates, 1), 1, 1]), elementCoordinates, repmat(tetrahedra(4, :, j), [size(elementCoordinates, 1), 1, 1]));
        d4 = cat(3, repmat(cat(3, tetrahedra(1, :, j), tetrahedra(2, :, j), tetrahedra(3, :, j)), [size(elementCoordinates, 1), 1, 1]), elementCoordinates);        
        detD = [specialCaseDeterminant(d0), specialCaseDeterminant(d1), specialCaseDeterminant(d2), specialCaseDeterminant(d3), specialCaseDeterminant(d4)];
        root.vertexTetrahedra(:, j) = all(bsxfun(@eq, sign(detD(:, 1)), sign(detD(:, 2:end))), 2);

%         add voxels
        if withVoxels
            d0 = cat(3, repmat(cat(3, tetrahedra(1, :, j), tetrahedra(2, :, j), tetrahedra(3, :, j), tetrahedra(4, :, j)), [size(elementVoxels, 1), 1, 1]));
            d1 = cat(3, elementVoxels, repmat(cat(3, tetrahedra(2, :, j), tetrahedra(3, :, j), tetrahedra(4, :, j)), [size(elementVoxels, 1), 1, 1]));
            d2 = cat(3, repmat(tetrahedra(1, :, j), [size(elementVoxels, 1), 1, 1]), elementVoxels, repmat(cat(3, tetrahedra(3, :, j), tetrahedra(4, :, j)), [size(elementVoxels, 1), 1, 1]));
            d3 = cat(3, repmat(cat(3, tetrahedra(1, :, j), tetrahedra(2, :, j)), [size(elementVoxels, 1), 1, 1]), elementVoxels, repmat(tetrahedra(4, :, j), [size(elementVoxels, 1), 1, 1]));
            d4 = cat(3, repmat(cat(3, tetrahedra(1, :, j), tetrahedra(2, :, j), tetrahedra(3, :, j)), [size(elementVoxels, 1), 1, 1]), elementVoxels);        
            detD = [specialCaseDeterminant(d0), specialCaseDeterminant(d1), specialCaseDeterminant(d2), specialCaseDeterminant(d3), specialCaseDeterminant(d4)];
            root.voxelTetrahedra(:, j) = all(bsxfun(@eq, sign(detD(:, 1)), sign(detD(:, 2:end))), 2);
        end
    end
    
    clear('d0', 'd1', 'd2', 'd3', 'd4', 'detD', 'boundingBox', 'tetrahedra', 'elementCoordinates', 'elementVoxels');
    if ~isempty(root.children);    
        root.children = cellfun(@recursivelyAddTetrahedra, root.children, 'UniformOutput', false);
    end

    end %end function
end %end function

function d = specialCaseDeterminant(d)
% the determinant can be simplified because there is a column of ones
d = ...
...
d(:, 1, 4) .* (d(:, 2, 2) .* d(:, 3, 3) - d(:, 2, 3) .* d(:, 3, 2)) - ...
d(:, 2, 4) .* (d(:, 1, 2) .* d(:, 3, 3) - d(:, 1, 3) .* d(:, 3, 2)) + ...
d(:, 3, 4) .* (d(:, 1, 2) .* d(:, 2, 3) - d(:, 2, 2) .* d(:, 1, 3)) + ...
...
d(:, 1, 1) .* (d(:, 2, 2) .* d(:, 3, 4) - d(:, 2, 4) .* d(:, 3, 2)) - ...
d(:, 2, 1) .* (d(:, 1, 2) .* d(:, 3, 4) - d(:, 1, 4) .* d(:, 3, 2)) + ...
d(:, 3, 1) .* (d(:, 1, 2) .* d(:, 2, 4) - d(:, 2, 2) .* d(:, 1, 4)) - ...
...
d(:, 1, 1) .* (d(:, 2, 2) .* d(:, 3, 3) - d(:, 2, 3) .* d(:, 3, 2)) + ...
d(:, 2, 1) .* (d(:, 1, 2) .* d(:, 3, 3) - d(:, 1, 3) .* d(:, 3, 2)) - ...
d(:, 3, 1) .* (d(:, 1, 2) .* d(:, 2, 3) - d(:, 2, 2) .* d(:, 1, 3)) + ...
...
d(:, 1, 1) .* (d(:, 2, 4) .* d(:, 3, 3) - d(:, 2, 3) .* d(:, 3, 4)) - ...
d(:, 2, 1) .* (d(:, 1, 4) .* d(:, 3, 3) - d(:, 1, 3) .* d(:, 3, 4)) + ...
d(:, 3, 1) .* (d(:, 1, 4) .* d(:, 2, 3) - d(:, 2, 4) .* d(:, 1, 3))   ...
;

end %end function

function boundingBox = toBoundingBox(lowerCorner, upperCorner)
boundingBox = [ ...
    lowerCorner(1), lowerCorner(2), lowerCorner(3); ... %1
    lowerCorner(1), lowerCorner(2), upperCorner(3); ... %2
    lowerCorner(1), upperCorner(2), lowerCorner(3); ... %3
    lowerCorner(1), upperCorner(2), upperCorner(3); ... %4
    upperCorner(1), lowerCorner(2), lowerCorner(3); ... %5
    upperCorner(1), lowerCorner(2), upperCorner(3); ... %6
    upperCorner(1), upperCorner(2), lowerCorner(3); ... %7
    upperCorner(1), upperCorner(2), upperCorner(3)];    %8
end %end function


function elements = allElements(root)
if isempty(root.children)
    elements = root;
    return;
else
    elements = cat(1, cellfun(@allElements, root.children, 'UniformOutput', false));
    elements = [root, elements{:}];
    return;
end
end %end function


function elements = elementsLevelN(root, N)
if N == 0
    elements = root;
    return;
elseif isempty(root.children)
    elements = [];
    return;
else
    elements = cat(1, cellfun(@elementsLevelN, root.children, repmat({N - 1}, size(root.children)), 'UniformOutput', false));
    elements = [elements{:}];
    return;
end
end %end function




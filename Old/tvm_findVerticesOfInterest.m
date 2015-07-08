function output = tvm_findVerticesOfInterest(configuration)

memtic
subjectDirectory    = configuration.SubjectDirectory;

meanFunctional = spm_vol([subjectDirectory configuration.Functional]);

load([subjectDirectory configuration.CorrelationFolder configuration.PeakFile], 'peaks')

meanFunctional.volume = zeros(meanFunctional.dim); %spm_read_vols(meanFunctional);
meanFunctional.dt = [2, 0];
for region = 1:length(peaks)
    meanFunctional.volume(:) = 0;
    indices = sub2ind(meanFunctional.dim, peaks{region}(:, 1), peaks{region}(:, 2), peaks{region}(:, 3));
    meanFunctional.volume(indices) = 1;
    meanFunctional.fname = [subjectDirectory configuration.CorrelationFolder configuration.FileNames{region}];
    spm_write_vol(meanFunctional, meanFunctional.volume);
end

load ([subjectDirectory configuration.Boundaries], 'wSurface', 'pSurface');

numberOfRegions = 0;
for i = 1:length(peaks)
    numberOfRegions = numberOfRegions + size(peaks{i}, 1);
end
closestVertices = ones(numberOfRegions, 4);
n = 1;
for i = 1:length(peaks)
    for j = 1:size(peaks{i}, 1)
        closestVertices(n, 1:3) = peaks{i}(j, :);
        n = n + 1;
    end
end
switch configuration.Hemisphere
    case 'Right'
        hemisphere = 1;
    case 'Left'
        hemisphere = 2;
%     case 'Both'
%         hemisphere = [1, 2];
end
%the indices of the vertices closest to the peaks
vertexIndices = zeros(length(closestVertices), 1);
for i = 1:length(closestVertices)
    [~, index] = min(sum(bsxfun(@minus, wSurface{hemisphere}, closestVertices(i, :)) .^ 2, 2));
    vertexIndices(i) = index;
end

loadedBoundaryInformation = [];
loadedBoundaryInformation.Neighbours   = [subjectDirectory configuration.FreeSurferFolder 'surf/?h.neighbours.asc'];

[~, ~, ~, ~, ~, N] = loadFreeSurferAsciiFile(loadedBoundaryInformation);

order = 12;
%The indices of vertices closest to the peak vertex
verticesOfInterest = cell(size(peaks));
n = 1;
for i = 1:length(verticesOfInterest)
    verticesOfInterest{i} = cell(size(peaks{i}, 1), 1);
    for j = 1:size(peaks{i}, 1)
        verticesOfInterest{i}{j} = findNeighbours(vertexIndices(n), N{hemisphere}, order);
        n = n + 1;
    end
end

save([subjectDirectory configuration.VerticesOfInterest], 'verticesOfInterest')

n = 1;
meanFunctional.dt = [4, 0];
for region = 1:length(peaks)
    meanFunctional.volume(:) = 0;
    for j = 1:size(peaks{region}, 1)
        boundaryVoxels = unique(round([wSurface{hemisphere}(verticesOfInterest{region}{j}, :); pSurface{hemisphere}(verticesOfInterest{region}{j}, :)]), 'rows');
        boundaryVoxels(boundaryVoxels < 1) = 1;
        indices = sub2ind(meanFunctional.dim, boundaryVoxels(:, 1), boundaryVoxels(:, 2), boundaryVoxels(:, 3));
        meanFunctional.volume(indices) = n;

        n = n + 1;
    end
    meanFunctional.fname = [subjectDirectory configuration.CorrelationFolder 'Vertices' configuration.FileNames{region}];
    spm_write_vol(meanFunctional, meanFunctional.volume);
end

output = memtoc;

end %end function

function VOI = findNeighbours(vertexIndex, neighbourList, order)
    
VOI = vertexIndex;
for i = 1:order
    for j = 1:length(VOI)
        VOI = [VOI, neighbourList{VOI(j)}(2:end)]; %#ok<AGROW>
    end
    VOI = unique(VOI);
end

end %end function








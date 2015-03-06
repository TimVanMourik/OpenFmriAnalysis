function contrast = findContrast(arrayW, arrayP, voxelgrid, configuration)
%FINDCONTRAST Finds the contrast near a boundary of a given mesh.
%   FINDCONTRAST(INNERBOUNDARY, OUTERBOUNDARY, VOXELGRID)
%   Finds the contrast in a VOXELGRID, near the INNERBOUNDARY.
%
%   FINDCONTRAST(INNERBOUNDARY, OUTERBOUNDARY, VOXELGRID, MODE)
%   Finds the contrast in a VOXELGRID, near the INNERBOUNDARY in a certain
%   MODE
%
%   modes:
%   	'fixedDistance'
%   	'average'
%   	'gradient'
%
%   Copyright (C) 2012-2013, Tim van Mourik, DCCN

%% Parse configuration
contrastMethod = tvm_getOption(configuration, 'ContrastMethod', 'gradient');
    % 'gradient'

%%

switch contrastMethod
    case 'fixedDistance'
        contrast = findContrastFixedDistance(arrayW, arrayP, voxelgrid);
%     case 'median'
%         contrast = findContrastMedian(arrayW, arrayP, voxelgrid);
%     case 'extrema'
%         contrast = findContrastLocalExtrema(arrayW, arrayP, voxelgrid);
    case 'average'
        contrast = findContrastAverage(arrayW, arrayP, voxelgrid);
    case 'gradient'
        contrast = findContrastGradient(arrayW, arrayP, voxelgrid);
%     case 'GreveFischl' %not implemented yet! But fairly similar to gradient
%         contrast = findGradient(arrayW, arrayP, voxelgrid);
%     otherwise
%         disp('This contrast method does not exists. Average contrast is used.')
%         contrast = findContrastAverage(arrayW, arrayP, voxelgrid);
end

end % end functions

function contrast = findContrastGradient(array1, array2, voxelgrid, d)
%This function computes the contrast on both sides of the grey matter - white matter
%boundary given two arrays. It is to be used as a contrast detection for white-
%grey matter contrast
%   The computation method is relative distance sampling: computing the
%   contrast by means of sampling at a percentage of the thickness of the
%   grey matter
%   The first array needs to be the inner mesh, the second array should be the
%   outer mesh. The third input is the voxel grid for which the meshes are
%   given. The fourth is a boolean that determines if the contrast needs to 
%   be reversed. The fifth input is a scalar value that determines the distance 
%   (percentage) from the boundary.

%if no distance percentage is given, set it to 30%
if nargin < 4
    d = 0.3;
end

%computes the normals and the thickness
normals = findNormals(array1, array2);
thickness = findThickness(array1, array2);

%replicates the thickness three times for all spatial coordinates
thickness = repmat(thickness, 1, size(array1, 2));

%The white matter is supposed to be along the negative vertex normal
whitepixels = array1 - d * normals .* thickness;
%The grey matter is supposed to be along the vertex normal
greypixels  = array1 + d * normals .* thickness;

%determine the contrast
white = tvm_sampleVoxels(voxelgrid, whitepixels(:, 1), whitepixels(:, 2), whitepixels(:, 3));
grey  = tvm_sampleVoxels(voxelgrid, greypixels(:, 1) , greypixels(:, 2) , whitepixels(:, 3));

%computes the contrast
contrast = (white - grey) ./ (grey + white);

%If there have been divisions by zero, contrasts can be +-Inf. The pixels
%have zero contrast so are set to zero.
%Also the contrast for very dark pixels is set to 0 in order to prevent a
%contrast bias resulting from divisions by small numbers
contrast(abs(contrast) > 1 | contrast ~= contrast) = 0;

end %end function
function contrast = findContrastAverage(array1, array2, voxelgrid)
%FINDCONTRASTAVERAGE This function computes the contrast on both sides of the grey matter - white matter
%boundary given two arrays. It is to be used as a contrast detection for white-
%grey matter contrast
%   C = FINDCONTRASTAVERAGE(INNERBOUNDARY, OUTERBOUNDARY, VOXELGRID)
%   The computation method is sampling at a number of points around the
%   boundary, computing the average and computing the contrast
%   The first array needs to be the inner mesh, the second array should be the
%   outer mesh. The third input is the voxel grid for which the meshes are
%   given. 
%
%   C = FINDCONTRASTAVERAGE(INNERBOUNDARY, OUTERBOUNDARY, VOXELGRID, REVERSECONTRAST)
%   Similar to the previous, but with an additional boolean that is set to
%   false when the contrast needs to be reversed. This is important when
%   the enclosed volume is brighter than the outer volume
%
%   This method is called so many times that input error checking has been
%   removed from the file, even though the used tvm_sampleVoxels function
%   is the main limiting factor.

%if contrast reversal is not specified, it is set to false

numberOfCoordinates = size(array1, 1);
normals = findNormals(array1, array2);

if size(array1, 2) == 4
    %homogeneous coordinates
    homogeneousCoordinates = 4;
else
    %inhomogeneous coordinates
    homogeneousCoordinates = 3;
end

thickness = findThickness(array1, array2);
numberOfSteps = 5;
%It goes on until 60 percent of the grey matter
stepSize = 1 / numberOfSteps * 0.6;
stepsWhite  = zeros(numberOfCoordinates, homogeneousCoordinates, numberOfSteps);
pixelsWhite = zeros(numberOfCoordinates, numberOfSteps);
stepsGrey  = zeros(numberOfCoordinates, homogeneousCoordinates, numberOfSteps);
pixelsGrey  = zeros(numberOfCoordinates, numberOfSteps);

thickness = repmat(thickness, 1, homogeneousCoordinates);
distance = normals .* thickness * stepSize;

for j = 1:numberOfSteps
    %The white matter is supposed to be along the negative vertex normal
    stepsWhite(:, :, j) = array1(:, :) - distance(:, :) * j;
    %The grey matter is supposed to be along the positive vertex normal
    stepsGrey(:, :, j)  = array1(:, :) + distance(:, :) * j;
    %Interpolates the pixels
    pixelsWhite(:, j) = tvm_sampleVoxels(voxelgrid, stepsWhite(:, 1, j), stepsWhite(:, 2, j), stepsWhite(:, 3, j));
    pixelsGrey(:, j)  = tvm_sampleVoxels(voxelgrid, stepsGrey(:, 1, j),  stepsGrey(:, 2, j) , stepsGrey(:, 3, j));
end

grey  = sum(pixelsGrey, 2);
white = sum(pixelsWhite, 2);


%computes the contrast
contrast = (white - grey) ./ (grey + white);

%If there have been divisions by zero, contrasts can be +-Inf. The pixels
%have zero contrast so are set to zero.
%Also the contrast for very dark pixels is set to 0 in order to prevent a
%contrast bias resulting from divisions by small numbers
contrast(abs(contrast) > 1 | contrast ~= contrast | grey < 1 | white < 1) = 0;



end % end functions
function contrast = findContrastFixedDistance(array1, array2, voxelgrid, d)
%FINDCONTRASTFIXEDDISTANCE This function computes the contrast on both
%sides of the grey matter - white matter boundary given two arrays. It is
%to be used as a contrast detection for white-grey matter contrast
%   The computation method is fixed distance sampling: computing the
%   contrast by means of sampling at a fixed distance from the grey matter
%   The first array needs to be the inner mesh, the second array should be the
%   outer mesh. The third input is the voxel grid for which the meshes are
%   given. The fourth is a boolean that determines if the contrast needs to 
%   be reversed. The fifth input is a scalar value that determines the distance 
%   from the boundary.

if nargin < 4
    d = 0.3;
end

normals = findNormals(array1, array2);

%The white matter is supposed to be along the negative vertex normal
whitepixels = array1 - d * normals;
%The grey matter is supposed to be along the vertex normal
greypixels = array1 + d * normals;

%determine the contrast

white = tvm_sampleVoxels(voxelgrid, whitepixels(:, 1), whitepixels(:, 2), whitepixels(:, 3));
grey  = tvm_sampleVoxels(voxelgrid, greypixels(:, 1),  greypixels(:, 2),  whitepixels(:, 3));
    
%computes the contrast
contrast = (white - grey) ./ (grey + white);

%If there have been divisions by zero, contrasts can be +-Inf. The pixels
%have zero contrast so are set to zero. 
contrast(abs(contrast) > 1) = 0;

end %end function
% function contrast = findContrastLocalExtrema(array1, array2, voxelgrid)
% %This function computes the contrast on both sides of the grey matter - white matter
% %boundary given two arrays. It is to be used as a contrast detection for white-
% %grey matter contrast
% %   The computation method is local extrema sampling: it takes the maximum
% %   value in the white matter and the minimum value in the grey matter and
% %   computes the contrast using these values.
% %   The first array needs to be the inner mesh, the second array should be the
% %   outer mesh. The third input is the voxel grid for which the meshes are
% %   given. The fourth is a boolean that determines if the contrast needs to 
% %   be reversed. 
% 
% normals = findNormals(array1, array2);
% thickness = findThickness(array1, array2);
% 
% if size(arrayW, 2) == 4
%     %homogeneous coordinates
%     homogeneousCoordinates = 4;
% else
%     %inhomogeneous coordinates
%     homogeneousCoordinates = 3;
% end
% length = size(array1, 1);
% numberOfSteps = 5;
% %Samples until 70 percent of the grey matter
% stepSize = 1 / numberOfSteps * 0.7;
% stepsWhite = zeros(length, homogeneousCoordinates, numberOfSteps);
% pixelsWhite = zeros(length, numberOfSteps);
% stepsGrey = zeros(length, homogeneousCoordinates, numberOfSteps);
% pixelsGrey = zeros(length, numberOfSteps);
% grey = zeros(length, 1);
% white = zeros(length, 1);
% 
% %distance = zeros(length, numberOfCoordinates);
% %replicates the thickness three times for all spatial coordinates
% thickness = repmat(thickness, 1, homogeneousCoordinates);
% distance = normals .* thickness * stepSize;
% 
% for j = 1:numberOfSteps
%     %The white matter is supposed to be along the negative vertex normal
%     stepsWhite(:, :, j) = array1(:, :) - distance(:, :) * j;
%     %The grey matter is supposed to be along the vertex normal
%     stepsGrey(:, :, j)  = array1(:, :) + distance(:, :) * j;
% 
%     pixelsWhite(:, j) = tvm_sampleVoxels(voxelgrid, stepsWhite(:, 1, j), stepsWhite(:, 2, j), stepsWhite(:, 3, j));
%     pixelsGrey(:, j)  = tvm_sampleVoxels(voxelgrid, stepsGrey(:, 1, j),  stepsGrey(:, 2, j) , stepsGrey(:, 3, j));
% end
% 
% %find the local extrema
% for i = 1:length
%     grey(i) = min(pixelsGrey(i, :));
%     white(i) = max(pixelsWhite(i, :));
% end
% 
% %computes the contrast
% contrast = (white - grey) ./ (grey + white);
% 
% %If there have been divisions by zero, contrasts can be +-Inf. The pixels
% %have zero contrast so are set to zero. 
% contrast(abs(contrast) > 1) = 0;
% 
% end %end function
% function contrast = findContrastMedian(array1, array2, voxelgrid)
% %FINDGRADIENT This function computes the contrast on both sides of the
% %boundary given two arrays. It is to be used as a contrast detection for
% %white-grey matter contrast
% %   G = FINDGRADIENT(INNERBOUNDARY, OUTERBOUNDARY, VOXELGRID)
% %
% %
% %   G = FINDGRADIENT(INNERBOUNDARY, OUTERBOUNDARY, VOXELGRID, REVERSECONTRAST)
% 
% if nargin < 3
%     error('TVM:findGradient:NoInputs',['No input arguments specified. ' ...
%             'There should be at least three input arguments.'])
% end
% 
% %computes the normals and the thickness
% normals = findNormals(array1, array2);
% thickness = findThickness(array1, array2);
% 
% if size(arrayW, 2) == 4
%     %homogeneous coordinates
%     homogeneousCoordinates = 4;
% else
%     %inhomogeneous coordinates
%     homogeneousCoordinates = 3;
% end
% 
% length = size(array1, 1);
% numberOfSteps = 5;
% %Samples until 70 percent of the grey matter
% stepSize = 1 / numberOfSteps * 0.7;
% stepsWhite = zeros(length, homogeneousCoordinates, numberOfSteps);
% pixelsWhite = zeros(length, numberOfSteps);
% stepsGrey = zeros(length, homogeneousCoordinates, numberOfSteps);
% pixelsGrey = zeros(length, numberOfSteps);
% grey = zeros(length, 1);
% white = zeros(length, 1);
% 
% %replicates the thickness three times for all spatial coordinates
% thickness = repmat(thickness, 1, 3);
% distance = normals .* thickness * stepSize;
% 
% for j = 1:numberOfSteps
%     %The white matter is supposed to be along the negative vertex normal
%     stepsWhite(:, :, j) = array1(:, :) - distance(:, :) * j;
%     %The grey matter is supposed to be along the vertex normal
%     stepsGrey(:, :, j)  = array1(:, :) + distance(:, :) * j;
% 
%     pixelsWhite(:, j) = tvm_sampleVoxels(voxelgrid, stepsWhite(:, 1, j), stepsWhite(:, 2, j), stepsWhite(:, 3, j));
%     pixelsGrey(:, j)  = tvm_sampleVoxels(voxelgrid, stepsGrey(:, 1, j),  stepsGrey(:, 2, j) , stepsGrey(:, 3, j));
% 
% end
% 
% %find the local extrema
% for i = 1:length
%     grey(i) = median(pixelsGrey(i, :));
%     white(i) = median(pixelsWhite(i, :));
% end
% 
% %computes the contrast
% contrast = (white - grey) ./ (grey + white);
% 
% %If there have been divisions by zero, contrasts can be +-Inf. The pixels
% %have zero contrast so are set to zero. 
% contrast(abs(contrast) > 1) = 0;
% 
% end %end function






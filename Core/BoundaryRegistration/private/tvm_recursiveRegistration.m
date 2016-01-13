function [arrayW, arrayP, transformStack] = tvm_recursiveRegistration(arrayW, arrayP, voxelGrid, dimensionOrder, configuration)
%RECURSIVEREGISTRATION recursively registers boundaries W and P to the
%VOLUME 
%   [W, P] = RECURSIVEREGISTRATION(W, P, VOLUME, CONFIGURATION)
%   Registers boundaries W and P to the VOLUME 
%
%
%   Copyright (C) 2012-2013, Tim van Mourik, DCCN

%% Parse configuration
% minimalNumberOfVertices     = tvm_getOption(configuration, 'MinVertices', 1000);
    % 1000
accuracy                    = tvm_getOption(configuration, 'Accuracy', 10);
    % 10
dynamicAccuracy             = tvm_getOption(configuration, 'DynamicAccuracy', true);
    % true
numberOfIterations          = tvm_getOption(configuration, 'NumberOfIterations', 6);
    % 6

contrastConfiguration = configuration;

%%
numberOfVertices            = size(arrayW, 1);
%start the recursive algorithm. The function is a nested function and
%therefore works with shared memory, i.e. the arrays in the main
%function are altered by the subfunctions in order to get a cumulative
%recursive registration
transformStack = [];
transformStack = recursiveTransformation(true(numberOfVertices, 1), 1, numberOfIterations, transformStack);

function transformStack = recursiveTransformation(indices, dimension, iteration, transformStack)
    if iteration <= 0
        return;
    end
    selectedIndices = find(indices);
    %compute best accuracy if requested
    if dynamicAccuracy
        currentAccuracy = round(min(max(100 * (numberOfIterations - iteration + 1) / numberOfIterations / 2 ^ (iteration - 1), accuracy), 100));
        selectedIndices = selectedIndices(mod(find(selectedIndices), round(100 / currentAccuracy)) == 0);
    else
        currentAccuracy = accuracy;
        selectedIndices = selectedIndices(mod(find(selectedIndices), round(100 / accuracy)) == 0);
    end
    %find the best transformation...
    tic;
    t = optimalTransformation(arrayW(selectedIndices, :), arrayP(selectedIndices, :), voxelGrid, contrastConfiguration);
    computationTime = toc;
    %...and apply it to the selected indices
    arrayW(indices, :) = arrayW(indices, :) * t;
    arrayP(indices, :) = arrayP(indices, :) * t;
    %find new indices
    
    middleValue = median(arrayW(indices, dimension));
    newIndices     = arrayW(:, dimension) < middleValue & indices;
%     newIndices = findIndices(indices, dimensionOrder(dimension));
    %execute the same function to both parts
    
    transformStack.mat = t;
    transformStack.computationTime = computationTime;
    transformStack.accuracy = currentAccuracy;
    transformStack.dimension = dimension;
    transformStack.cut = middleValue;
    transformStack.smaller = [];
    transformStack.bigger = [];
    
    dimension = mod(dimension, 3) + 1;
    transformStack.smaller = recursiveTransformation(newIndices,           	dimensionOrder(dimension), iteration - 1, transformStack.smaller);
    transformStack.bigger = recursiveTransformation(indices & ~newIndices,	dimensionOrder(dimension), iteration - 1, transformStack.bigger);
end %end function

end %end function


function [transformationMatrix, registrationParameters]  = tvm_BoundaryBasedRegistration(arrayW, arrayP, voxelGrid, configuration)
%BOUNDARYBASEDREGISTRATION A method of using the boundaries that enclose
%the grey matter for registration of brain volume data. It is a five-stage
%process proposed by Greve & Fischl (2009).
%
%   T = BOUNDARYBASEDREGISTRATION(W, P, VOLUME, CONFIGURATION)
%
%   List of possible configurations and their defaults:
%       Display             'off'
%       Stages              '12345'
%       OptimisationMethod  'GreveFischl'
%       Pivot               size(VOXELGRID) / 2
%       Mode                'rst'
%       ContrastMethod      'gradient'
%       ReverseContrast     false
%
%   Display: progress messages are displayed during the registration
%
%   Stages: which stages of the 5-stage approach proposed by Greve & Fischl
%   are implemented. Default is '12345' but any combination of any number
%   of stages is possible
%
%   OptimisationMethod: the cost function used for determining the optimal
%   transformation
%
%   Pivot: the pivot point around which is rotated and scaled
%
%   Mode: the degrees of freedom for which is a transformation is solved. 
%   This is a string consisting of the preferred parameters: 
%   `r' for rotation around all axes, `rx', `ry', or `rz' for a
%   single rotation around the respective axis and for example `rxrz' for a
%   rotation around the x-axis and the z-axis. In the same way the scaling
%   and translation can be modified. For example the combination `rystytz'
%   would optimise for a rotation around the y-axis, a scaling in all
%   direction and a translation along the y-axis and along the z-axis. The
%   default is 'rst'for all transformations.
%
%   ContrastMethod: the way contrast is computed
%
%   ReverseContrast: false when a T1-weighted image is registered, true
%   when a T2*-weighted image is registered.
%
%   Copyright (C) 2012-2013, Tim van Mourik, DCCN

registrationParameters = [0, 0, 0,  1, 1, 1,  0, 0, 0]; 
if nargin < 4 
    configuration = [];
end

%initials
mode                    = tvm_getOption(configuration, 'Mode',      'rst');
display                 = tvm_getOption(configuration, 'Display',   'off');
stages                  = tvm_getOption(configuration, 'Stages',    '12345');
accuracy                = tvm_getOption(configuration, 'Accuracy',  100);
modeSettings            = parseMode(mode);

switch display
    case 'on'
        messages = true;
    case 'off'
        messages = false;
    otherwise
        messages = false;
end
numberOfStages = length(stages);
transformationMatrix = eye(4);

if messages
    messageInitial();
end
readIndex = 1;
while readIndex <= numberOfStages
    switch stages(readIndex)
        case '1'
            stage1() %Initialisation
        case '2'
            stage2() %Coarse Search
        case '3'
            stage3() %Gradient Descent I
        case '4' 
            stage4() %Fine Search
        case '5'
            stage5() %Gradient Descent II
        otherwise
    end
    readIndex = readIndex + 1;
end
if messages
    messageStageEnd();
end

    function stage1
    %STAGE1 Initialisation
    %Generally, the initialisation is done before calling this method. If
    %this is required of this method, the initialisation stage can be
    %inserted here.     
        
    %THIS IS A TEST INITIALISATION
    numberOfSamples = 3;
    numberOfParameters = 6;
    %translation of 2 pixels
    tMin = -4;
    tMax = 4;
    %rotation of 2 degrees
    rMin = -4 / 180 * pi;
    rMax = 4 / 180 * pi;
    
    configuration.Accuracy = 10;
    [t, p] = gridSearch(arrayW, arrayP, voxelGrid, numberOfSamples, numberOfParameters, tMin, tMax, rMin, rMax, modeSettings, configuration);
    arrayW = arrayW * t;
    arrayP = arrayP * t;

    transformationMatrix = transformationMatrix * t; 
    registrationParameters([1:3, 7:9]) = registrationParameters([1:3, 7:9]) + p([1:3, 7:9]);
    registrationParameters(4:6) = registrationParameters(4:6) .* p(4:6);
    
    if messages
    messageStage1();
    end
    
    end %end function

    function stage2
    %STAGE2 Coarse Search
    %Makes a grid of 3^6 = 729: three values for all translation and
    %rotation parameters.
    
    numberOfSamples = 3;
    numberOfParameters = 6;
    %translation of 1 pixels
    tMin = -1;
    tMax = 1;
    %rotation of 1 degrees
    rMin = -1 / 180 * pi;
    rMax = 1 / 180 * pi;
    
    configuration.Accuracy = 10;
    [t, p] = gridSearch(arrayW, arrayP, voxelGrid, numberOfSamples, numberOfParameters, tMin, tMax, rMin, rMax, modeSettings, configuration); 
    arrayW = arrayW * t;
    arrayP = arrayP * t;

    transformationMatrix = transformationMatrix * t;
    registrationParameters([1:3, 7:9]) = registrationParameters([1:3, 7:9]) + p([1:3, 7:9]);
    registrationParameters(4:6) = registrationParameters(4:6) .* p(4:6);
    
    if messages
    messageStage2();
    end
    
    end %end function
    function stage3
    %STAGE3 Gradient Descent I
    indices = false(length(arrayW), 1);
    indices(mod(find(~indices), round(100 / accuracy)) == 0) = true;
    configuration.TolX = 1e-4;
    configuration.Accuracy = 20;
    [t, p] = optimalTransformation(arrayW(indices, :), arrayP(indices, :), voxelGrid, configuration);
    arrayW = arrayW * t;
    arrayP = arrayP * t;

    transformationMatrix = transformationMatrix * t;
    registrationParameters([1:3, 7:9]) = registrationParameters([1:3, 7:9]) + p([1:3, 7:9]);
    registrationParameters(4:6) = registrationParameters(4:6) .* p(4:6);
    
    if messages
        messageStage3
    end

    end %end function
    function stage4
    %STAGE4 Fine Search
    
    numberOfSamples = 3;
    numberOfParameters = 6;
    %translation of 0.1 pixels
    tMin = -0.1;
    tMax = 0.1;
    %rotation of 0.1 degrees
    rMin = -0.1 / 180 * pi;
    rMax = 0.1 / 180 * pi;
    
    configuration.Accuracy = 100;
    [t, p] = gridSearch(arrayW, arrayP, voxelGrid, numberOfSamples, numberOfParameters, tMin, tMax, rMin, rMax, modeSettings, configuration); 
    arrayW = arrayW * t;
    arrayP = arrayP * t;
   
    transformationMatrix = transformationMatrix * t;
    registrationParameters([1:3, 7:9]) = registrationParameters([1:3, 7:9]) + p([1:3, 7:9]);
    registrationParameters(4:6) = registrationParameters(4:6) .* p(4:6);
    
    if messages
        messageStage4();
    end

    end %end function
    function stage5
    %STAGE5 Gradient Descent II
    configuration.TolX = 1e-8;
    configuration.Accuracy = 100;
    [t, p] = optimalTransformation(arrayW, arrayP, voxelGrid, configuration);
    arrayW = arrayW * t;
    arrayP = arrayP * t;
   
    transformationMatrix = transformationMatrix * t;
    registrationParameters([1:3, 7:9]) = registrationParameters([1:3, 7:9]) + p([1:3, 7:9]);
    registrationParameters(4:6) = registrationParameters(4:6) .* p(4:6);
    
    if messages
        messageStage5();
    end

    end %end function

    function messageInitial
        tic %tics the start of the BBR
        fprintf('\n---Begin Boundary Based Registration---\n');
        fprintf('The average contrast is %1.6f\n', contrast());
    end %end function
    function messageStage1
        fprintf('Stage 1 completed: Initialisation\n')
        fprintf('The average contrast is %1.6f\n', contrast());
    end %end function
    function messageStage2
        fprintf('Stage 2 completed: Coarse Search\n')
        fprintf('The average contrast is %1.6f\n', contrast());
        end %end function
    function messageStage3
        fprintf('Stage 3 completed: Gradient Descent I\n')
        fprintf('The average contrast is %1.6f\n', contrast());
    end %end function
    function messageStage4
        fprintf('Stage 4 completed: Fine Search\n')
        fprintf('The average contrast is %1.6f\n', contrast());
    end %end function
    function messageStage5
        fprintf('Stage 5 completed: Gradient Descent II\n')
        fprintf('The average contrast is %1.6f\n', contrast());
    end %end function
    function messageStageEnd
        fprintf('Executing BBR took %f seconds\n', toc);
        fprintf('---End Boundary Based Registration---\n\n');
    end %end function

    function c = contrast()
%     c = sum(findContrast(arrayW, arrayP, voxelGrid, configuration)) / length(arrayW);
        c = tvm_contrastAverage([], arrayW, arrayP, voxelGrid, [], configuration) / length(arrayW);   
    end %end function
end %end function

function [transformation, registrationParameters] = gridSearch(arrayW, arrayP, voxelGrid, numberOfSamples, numberOfParameters, tMin, tMax, rMin, rMax, modeSettings, configuration)

pivot               = tvm_getOption(configuration, 'Pivot', mean(arrayW));
accuracy            = tvm_getOption(configuration, 'Accuracy', 100);

n = numberOfSamples ^ numberOfParameters;
contrast = zeros(n, 1);

rx = rMin:(rMax - rMin)/(numberOfSamples - 1):rMax;
ry = rMin:(rMax - rMin)/(numberOfSamples - 1):rMax;
rz = rMin:(rMax - rMin)/(numberOfSamples - 1):rMax;
tx = tMin:(tMax - tMin)/(numberOfSamples - 1):tMax;
ty = tMin:(tMax - tMin)/(numberOfSamples - 1):tMax;
tz = tMin:(tMax - tMin)/(numberOfSamples - 1):tMax;

[rX, rY, rZ, tX, tY, tZ] = ndgrid(rx, ry, rz, tx, ty, tz);
allTransformations = [rX(:), rY(:), rZ(:), tX(:), tY(:), tZ(:)];

modeSettings = true(1, 9);
modeSettings(4:6) = false;

indices = false(length(arrayW), 1);
indices(mod(1:length(indices), round(100 / accuracy)) == 0) = true;

for i = 1:n
    contrast(i) = tvm_contrastAverage(allTransformations(i, :), arrayW(indices, :), arrayP(indices, :), voxelGrid, modeSettings, configuration);   
end

index = round(median(find(contrast == min(contrast))));

registrationParameters = [allTransformations(index, 1:3), 1, 1, 1, allTransformations(index, 4:6)];
transformation = tvm_toMatrixRSTP(registrationParameters(1:3), registrationParameters(4:6), registrationParameters(7:9), pivot);

end %end function











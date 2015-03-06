function [newArrayW, newArrayP, transformStack] = tvm_RecursiveBoundaryRegistration(arrayW, arrayP, voxelGrid, configuration)
%TVM_RECURSIVEBOUNDARYREGISTRATION fits the input mesh to the volume. It is to
%be used for fitting grey matter boundaries (constructed on an anatomical
%scan) to a (locally inhomogeneously distorted) functional scan
%   [W, P] = TVM_RECURSIVEBOUNDARYREGISTRATION(W, P, VOLUME, CONFIGURATION)
%   Fits the input white matter boundary W and pial boundary P to the
%   boundaries present in the input VOLUME, using settings specified in
%   the CONFIGURATION struct. The fitted boundaries are returned. The
%   boundaries should be given in homogeneous coordinates [x y z 1], i.e.
%   3D coordinates with a 1 in a fourth last column
%
%   The method applies the optimalTransformation method recursively to a
%   shrinking partition of the mesh until a given minimum number of
%   vertices has been reached.
%   
%   List of possible configurations and their defaults:
%       MinVertices         1000
%       MultipleLoops       false
%       Accuracy            10
%       DynamicAccuracy     false
%       OptimisationMethod  'GreveFischl'
%       Pivot               size(VOXELGRID) / 2
%       Mode                'rst'
%       ContrastMethod      'gradient'
%       ReverseContrast     false
%       Display             'off'
%       BBR                 false
%
%   MinVertices, MultipleLoops, configuration and Accuracy are used by this method, the
%   rest is passed on to the optimalTransformation method.
%
%   MultipleLoops set to true makes the algorithm run 6 times with
%   different initial values and returns the median of the shifts from all
%   6 runs.
%
%   Accuracy is the percentage of vertices that is used for the
%   optimalTransformation method. When DynamicAccuracy is set to true, 
%   Accuracy will be the minimum accuracy used.
%
%   DynamicAccuracy set an opimal Accuracy for each run: low accuracy for
%   early stages in the process and high accuracy for later stages.
%
%   TimeRequirement is the requirement for a single boundary registration
%   loop in seconds.
%
%   Example:
%       %for boundaries 'w' and 'p' in a voxel grid 'volume'
%      	configuration = [];
%       configuration.ReverseContrast =     true;
%       configuration.ContrastMethod =      'gradient';
%       configuration.OptimisationMethod =  'GreveFischl';
%       configuration.Mode =                'rsyt';
%       configuration.MultipleLoops =       true;
%       configuration.Accuracy =            4;
%       configuration.DynamicAccuracy =     true;
%       configuration.Display =             'on';
%       configuration.BBR =                 'false';
%       configuration.TimeRequirement =     900;
%
%       [w, p] = optimalRecursiveTransformation(w, p, volume, configuration);
%
%   Copyright (C) 2012-2013, Tim van Mourik, DCCN

%% Parse configuration
multipleLoops         	= tvm_getOption(configuration, 'MultipleLoops',     false);
    % false
useQsub                 = tvm_getOption(configuration, 'qsub',              false);
    % false
timeRequirement         = tvm_getOption(configuration, 'TimeRequirement',   1200);
    % 800
    
%%
if size(arrayW, 2) == 3
    arrayW = [arrayW, ones(size(arrayW, 1), 1)];
    arrayP = [arrayP, ones(size(arrayP, 1), 1)];
end

if multipleLoops
    dimensions = {[1, 2, 3]; [1, 3, 2]; [2, 1, 3]; [2, 3, 1]; [3, 1, 2]; [3, 2, 1]};
else
    dimensions = {[1, 2, 3]};
end
%memory copies of the data. One for each node on the cluster.
whiteMatterBoundary = cell(length(dimensions), 1);
pialBoundary        = cell(length(dimensions), 1);
volumeData          = cell(length(dimensions), 1);
cfg                 = cell(length(dimensions), 1);

whiteMatterBoundary(:)  = {arrayW};
pialBoundary(:)         = {arrayP};
volumeData(:)           = {voxelGrid};
cfg(:)                  = {configuration};


if useQsub
    memoryRequirement = length(dimensions) * (numel(arrayW) + numel(arrayP) + numel(voxelGrid)) * 8 * 2;
    %timeRequirement = ?; @TODO: make a nice estimation function
    [w, p, transformStack] = qsubcellfun(@tvm_recursiveRegistration, whiteMatterBoundary, pialBoundary, volumeData, dimensions, cfg, 'UniformOutput', false, 'memreq', memoryRequirement, 'timreq', timeRequirement);
else
    [w, p, transformStack] =     cellfun(@tvm_recursiveRegistration, whiteMatterBoundary, pialBoundary, volumeData, dimensions, cfg, 'UniformOutput', false);
end
w = reshape([w{:}], [size(arrayW, 1), size(arrayW, 2), length(dimensions)]);
p = reshape([p{:}], [size(arrayP, 1), size(arrayP, 2), length(dimensions)]);

newArrayW = median(w, 3);
newArrayP = median(p, 3);

end %end function




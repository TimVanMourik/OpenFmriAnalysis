function [transformation, registrationParameters] = optimalTransformation(arrayW, arrayP, voxelGrid, configuration)
%OPTIMALTRANSFORMATION Comes upwith the best transformation possible to
%reach the maximum contrast
%   T = OPTIMALTRANSFORMATION(INNERBOUNDARY, OUTERBOUNDARY, VOXELGRID, CONFIGURATION)
%   Finds an optimal transformation for transforming the INNERBOUNDARY and
%   OUTERBOUNDARY to reach maximum contrast in the VOXELGRID, using the
%   specified CONFIGURATION.
%
%   Possible options:       default:
%       Pivot               mean(INNERBOUNDARY)
%       ReverseContrast     false
%       Mode                'rst'
%       ContrastMethod      'gradient'
%       TolX                1e-4
%       OptimisationMethod  'GreveFischl'
%       Weighted            false
%
%   Pivot:                  The rotation and scaling is preformed around
%   the pivot point. 
%   ReverseContrast:        reverses the contrast: necessary when the inner
%   surface is darker the the outer.
%   Mode:                   This is a string consisting of the preferred
%   parameters: `r' for rotation around all axes, `rx', `ry', or `rz' for a
%   single rotation around the respective axis and for example `rxrz' for a
%   rotation around the x-axis and the z-axis. In the same way the scaling
%   and translation can be modified. For example the combination `rystytz'
%   would optimise for a rotation around the y-axis, a scaling in all
%   direction and a translation along the y-axis and along the z-axis. The
%   default is 'rst'for all transformations.
%   ContrastMethod:         The method with which the contrast is
%   optimised. The default is 'gradient'. Other possibilities are 'average',
%   'fixedDistance', 'relativeDistance', and 'extrema'.
%   TolX:                   The tolerance of fminsearch
%   OptimisationMethod:     the method by means of which the list of
%   contrasts per vertex is transformed into one value. Possibilities are
%   'GreveFischl', 'sum' and 'sumOfSquares'.
%   Weighted:               if true, the contrast value is given a penalty
%   for the size of the transformation.
%
%   The transformation needs to be applied in
%   the specified order to reach the optimal contrast.
%
%   Example:
%       configuration = [];
%       configuration.Mode = 't';
%       configuration.Pivot = [100, 128, 30];
%       configuration.ContrastMethod = 'average';
%       t = optimalTransformation(w, p, voxelGrid, configuration);
%       w = w * t;
%       p = p * t;
%
%   Copyright (C) 2012-2013, Tim van Mourik, DCCN

%% Parse configuration
pivot =                 tvm_getOption(configuration, 'Pivot', mean(arrayW, 1));
    % mean(arrayW)
mode =                  tvm_getOption(configuration, 'Mode', 'rst');
    % 'rst'
tolerance =           	tvm_getOption(configuration, 'TolX', 1e-4);
    % '1e-4'
bounded =           	tvm_getOption(configuration, 'Clamp', []);
    % '1e-4'

contrastConfiguration = configuration;

%%
%parses the mode. Gives a 1 X 9 row vector that consist of ones where the
%contrast needs to be optimised and a zero when the variable does not
%change.
modeSettings = parseMode(mode);

% the intial values that are required by fminsearch.
registrationParameters = [0, 0, 0, 1, 1, 1, 0, 0, 0];
initialValues = registrationParameters(modeSettings);
t = fminsearch(@(transformation)tvm_contrastAverage(transformation, arrayW, arrayP, voxelGrid, modeSettings, contrastConfiguration), initialValues, optimset('Display', 'off', 'TolX', tolerance));

if ~isempty(bounded)
    %translation, rotation
    maxT = t;
    maxValues = initialValues + bounded;    
    zeroDefaults = ~initialValues;
    maxT(zeroDefaults) = min([abs(maxT(zeroDefaults)); maxValues(zeroDefaults)]) .* sign(maxT(zeroDefaults));
    
    %scaling
    oneDefaults = ~zeroDefaults;
    maxT(oneDefaults) = min([max([maxT(oneDefaults); 1 ./ maxT(oneDefaults)]); maxValues(oneDefaults)]);
    maxT(oneDefaults & t(oneDefaults) < 1) = 1 ./ maxT(oneDefaults & t(oneDefaults) < 1);    
    t = maxT;
end

%the output obtained from fminsearch needs to be transformed in the required output

registrationParameters(modeSettings) = t;

%transforms the transformation into a transformation matrix
transformation = tvm_toMatrixRSTP(registrationParameters(1:3), registrationParameters(4:6), registrationParameters(7:9), pivot);

end %end function

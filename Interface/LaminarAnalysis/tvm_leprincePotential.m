function tvm_leprincePotential(configuration)
% TVM_LEPRINCEPOTENTIAL
%   TVM_LEPRINCEPOTENTIAL(configuration)
%   @todo Add description
%
%   Copyright (C) Martin Havlicek 2015, Maastricht University, Tim van 
%   Mourik, 2016, DCCN
%   Original function written by Martin Havlicek, 2015
%   Heavily optimised by Tim van Mourik, 2016, DCCN
%   Modified to fit this toolbox by Tim van Mourik, 2016, DCCN
%
% Input:
%   i_SubjectDirectory
%   i_White
%   i_Pial
%   i_Potential
%   i_Gradient
%   i_Curvature
%   i_B0
%   i_B1
%   i_Epsilon
% Output:
%   o_EquivolumePotential
%   o_EquidistantPotential
%

%% Parse configuration
subjectDirectory        = tvm_getOption(configuration, 'i_SubjectDirectory', pwd());
    % default: current working directory
white                   = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_White'));
    %no default
pial                    = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_Pial'));
    %no default
potentialFile           = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_Potential'));
    %no default
gradientFile            = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_Gradient'));
    %no default
curvatureFile           = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_Curvature'));
    %no default
b0                      = tvm_getOption(configuration, 'i_B0', 0);
    %default: 0
b1                      = tvm_getOption(configuration, 'i_B1', 1);
    %default: 1
epsilon                 = tvm_getOption(configuration, 'i_Epsilon', 0);
    %default: 0
layeringEVFile          = tvm_getOption(configuration, 'o_EquivolumePotential', '');
    %default: empty
layeringEDFile          = tvm_getOption(configuration, 'o_EquidistantPotential', '');
    %default: empty
    
%% Load data
whiteLevelSet = spm_vol(white);
whiteLevelSet.volume = spm_read_vols(whiteLevelSet);

pialLevelSet = spm_vol(pial);
pialLevelSet.volume = spm_read_vols(pialLevelSet);

potential = spm_vol(potentialFile);
potential.volume = spm_read_vols(potential);

curvature = spm_vol(curvatureFile);
curvature.volume = spm_read_vols(curvature);

gradient = spm_vol(gradientFile);
gradientVolume = spm_read_vols(gradient);

%% Set some parameters
% @todo make these option accessable via the interface
greyMatter  = whiteLevelSet.volume >= 0 & pialLevelSet.volume  <= 0;
[x, y, z]  = ind2sub(potential.dim, find(greyMatter));
N = length(x);

optionFiberLengthMax      = 200;
optionDeviationAngleMax   = 15; %(degrees)
optionStep                = 0.1;

%% propagate fibers upwards
check           = true(N, optionFiberLengthMax);
gradient        = zeros(N, 3);
old_gradient    = zeros(N, 3);
f_U             = zeros(N, 1);
    
fibersUp = zeros(N, 3, optionFiberLengthMax);
fibersUp(:, :, 1) = [x, y, z];
for i = 1:optionFiberLengthMax - 1
    if sum(check(:, i)) == 0
        break;
    end
    % move up the check flag
    check(:, i + 1) = check(:, i);
    
    gradient(check(:, i), :) = tvm_sampleVoxels(gradientVolume, fibersUp(check(:, i), :, i));
    gradient(check(:, i), :) = bsxfun(@rdivide, gradient(check(:, i), :), sqrt(sum(gradient(check(:, i), :) .^ 2, 2)));
    if i >= 2
        % Stop in case of hard turn, only from second iteration onwards.
        check(abs(sum(gradient .* old_gradient, 2)) < cos(optionDeviationAngleMax * pi / 180), i + 1) = false;
    end
    
    % Stop if outside of boundaries
    f_U(check(:, i)) = tvm_sampleVoxels(potential.volume, fibersUp(check(:, i), :, i));
    check(f_U < b0 | f_U > b1 | isnan(f_U), i + 1) = false;
    
    % Move on but stop if we end up in NaNs
    fibersUp(check(:, i), :, i + 1) = fibersUp(check(:, i), :, i) + optionStep * gradient(check(:, i), :);
    check(any(isnan(fibersUp(:, :, i + 1)), 2), i + 1) = false;
    
    % Keep the gradient for next step angle change calculation
    old_gradient(check(:, i), :) = gradient(check(:, i), :);
end
check(:, i + 1:end) = false;
fiberUpLength = sum(check, 2) - 1;
fiberUpLength(fiberUpLength == 0) = 1;

%% propagate fibers downwards, only difference is a minus sign in front of the gradient
check           = true(N, optionFiberLengthMax);
gradient        = zeros(N, 3);
old_gradient    = zeros(N, 3);
f_U             = zeros(N, 1);
    
fibersDown = zeros(N, 3, optionFiberLengthMax);
fibersDown(:, :, 1) = [x, y, z];
for i = 1:optionFiberLengthMax - 1
    if sum(check(:, i)) == 0
        break;
    end
    % move up the check flag
    check(:, i + 1) = check(:, i);
    
    gradient(check(:, i), :) = tvm_sampleVoxels(gradientVolume, fibersDown(check(:, i), :, i));
    gradient(check(:, i), :) = -bsxfun(@rdivide, gradient(check(:, i), :), sqrt(sum(gradient(check(:, i), :) .^ 2, 2)));
    if i >= 2
        % Stop in case of hard turn, only from second iteration onwards.
        check(abs(sum(gradient .* old_gradient, 2)) < cos(optionDeviationAngleMax * pi / 180), i + 1) = false;
    end
    
    % Stop if outside of boundaries
    f_U(check(:, i)) = tvm_sampleVoxels(potential.volume, fibersDown(check(:, i), :, i));
    check(f_U < b0 | f_U > b1 | isnan(f_U), i + 1) = false;
    
    % Move on but stop if we end up in NaNs
    fibersDown(check(:, i), :, i + 1) = fibersDown(check(:, i), :, i) + optionStep * gradient(check(:, i), :);
    check(any(isnan(fibersDown(:, :, i + 1)), 2), i + 1) = false;
    
    % Keep the gradient for next step angle change calculation
    old_gradient(check(:, i), :) = gradient(check(:, i), :);
end
check(:, i + 1:end) = false;
fiberDownLength = sum(check, 2) - 1;
fiberDownLength(fiberDownLength == 0) = 1;

%% Equidistant layering
if ~isempty(layeringEDFile)
    layeringEDFile = fullfile(subjectDirectory, layeringEDFile);
    
    dsUp    = 0:optionStep:optionStep * (optionFiberLengthMax - 1);
    dsDown  = 0:optionStep:optionStep * (optionFiberLengthMax - 1);
    ED = dsDown(fiberDownLength)';
    ED = ED ./ (dsUp(fiberUpLength) + dsDown(fiberDownLength))';

    ED(fiberDownLength == 1 & fiberUpLength == 1 & abs(whiteLevelSet.volume(greyMatter)) <= abs(pialLevelSet.volume(greyMatter))) = 2;%1;
    ED(fiberDownLength == 1 & fiberUpLength == 1 & abs(whiteLevelSet.volume(greyMatter)) >  abs(pialLevelSet.volume(greyMatter))) = -2;%0;

    layeringED = zeros(potential.dim);
    layeringED(greyMatter) = ED;
    layeringED(whiteLevelSet.volume < 0) = 1 + epsilon;
    layeringED(pialLevelSet.volume  > 0) = 0 - epsilon;
    whiteLevelSet.fname = layeringEDFile;
    spm_write_vol(whiteLevelSet, layeringED);
end

%% Equivolume Layering
if ~isempty(layeringEVFile)    
    % @todo here we're gonna sample it all, only to discard most of it. 
    % Overhead of selecting fibers is too great.
    curvature.volume(isnan(curvature.volume)) = 0;
    x = squeeze(fibersUp(:, 1, :));
    y = squeeze(fibersUp(:, 2, :));
    z = squeeze(fibersUp(:, 3, :));
    divm = reshape(tvm_sampleVoxels(-curvature.volume, [x(:), y(:), z(:)]), [N, optionFiberLengthMax]);
    S = [ones(size(divm, 1), 1), cumprod(1 + optionStep * divm, 2)];
    csUp = cumsum(S, 2);

    x = squeeze(fibersDown(:, 1, :));
    y = squeeze(fibersDown(:, 2, :));
    z = squeeze(fibersDown(:, 3, :));
    divm = reshape(tvm_sampleVoxels(curvature.volume, [x(:), y(:), z(:)]), [N, optionFiberLengthMax]);
    S = [ones(size(divm, 1), 1), cumprod(1 + optionStep * divm, 2)];
    csDown = cumsum(S, 2);

    EV = csDown(sub2ind(size(csDown), (1:size(csDown, 1))', fiberDownLength)) ./ (csDown(sub2ind(size(csDown), (1:size(csDown, 1))', fiberDownLength)) + csUp(sub2ind(size(csUp), (1:size(csUp, 1))', fiberUpLength)));
    EV(fiberDownLength == 1 & fiberUpLength == 1 & abs(whiteLevelSet.volume(greyMatter)) <= abs(pialLevelSet.volume(greyMatter))) = 1;
    EV(fiberDownLength == 1 & fiberUpLength == 1 & abs(whiteLevelSet.volume(greyMatter)) >  abs(pialLevelSet.volume(greyMatter))) = 0;
    %
    layeringEV = zeros(potential.dim);
    layeringEV(greyMatter) = EV;
    layeringEV(whiteLevelSet.volume < 0) = 1 + epsilon;
    layeringEV(pialLevelSet.volume  > 0) = 0 - epsilon;
    layeringEVFile = fullfile(subjectDirectory, layeringEVFile);
    whiteLevelSet.fname = layeringEVFile;
    spm_write_vol(whiteLevelSet, layeringEV);
end

end %end function




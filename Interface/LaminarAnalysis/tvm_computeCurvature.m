function tvm_computeCurvature(configuration)
% TVM_COMPUTECURVATURE 
%   TVM_COMPUTECURVATURE(configuration)
%   
%
%   Copyright (C) Tim van Mourik, 2014, DCCN
%
%   configuration.SubjectDirectory
%   configuration.White
%   configuration.Pial
%   configuration.WhiteCurvature1
%   configuration.WhiteCurvature2
%   configuration.PialCurvature1
%   configuration.PialCurvature2

%% Parse configuration
subjectDirectory    = tvm_getOption(configuration, 'i_SubjectDirectory', pwd());
    %no default
white               = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_White'));
    %no default
pial                = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_Pial'));
    %no default
whiteK              = fullfile(subjectDirectory, tvm_getOption(configuration, 'o_WhiteCurvature'));
    %no default
pialK               = fullfile(subjectDirectory, tvm_getOption(configuration, 'o_PialCurvature'));
%     %no default
order               = tvm_getOption(configuration, 'i_Order', 10);
    % 10

%%

%white matter surface
brain = spm_vol(white);
brain.volume = spm_read_vols(brain);

stencil = tvm_getGradientStencil3D(order);
filter = tvm_getGradientFilter3D(order);

gradient = zeros([brain.dim, 3]);
gradient(:, :, :, 1) = convn(brain.volume, stencil .* filter(:, :, :, 1), 'same');
gradient(:, :, :, 2) = convn(brain.volume, stencil .* filter(:, :, :, 2), 'same');
gradient(:, :, :, 3) = convn(brain.volume, stencil .* filter(:, :, :, 3), 'same');
gradient(1:2, :, :, :) = 0;
gradient(:, 1:2, :, :) = 0;
gradient(:, :, 1:2, :) = 0;
gradient(end-1:end, :, :, :) = 0;
gradient(:, end-1:end, :, :) = 0;
gradient(:, :, end-1:end, :) = 0;

gradient2 = zeros([brain.dim, 3]);
gradient2(:, :, :, 1) = convn(gradient(:, :, :, 1), stencil .* filter(:, :, :, 1), 'same');
gradient2(:, :, :, 2) = convn(gradient(:, :, :, 2), stencil .* filter(:, :, :, 2), 'same');
gradient2(:, :, :, 3) = convn(gradient(:, :, :, 3), stencil .* filter(:, :, :, 3), 'same');
gradient2(1:2, :, :, :) = 0;
gradient2(:, 1:2, :, :) = 0;
gradient2(:, :, 1:2, :) = 0;
gradient2(end-1:end, :, :, :) = 0;
gradient2(:, end-1:end, :, :) = 0;
gradient2(:, :, end-1:end, :) = 0;

gradientCross = zeros([brain.dim, 3]);
gradientCross(:, :, :, 1) = convn(gradient(:, :, :, 1), stencil .* filter(:, :, :, 2), 'same');
gradientCross(:, :, :, 2) = convn(gradient(:, :, :, 1), stencil .* filter(:, :, :, 3), 'same');
gradientCross(:, :, :, 3) = convn(gradient(:, :, :, 2), stencil .* filter(:, :, :, 3), 'same');
gradientCross(1:2, :, :, :) = 0;
gradientCross(:, 1:2, :, :) = 0;
gradientCross(:, :, 1:2, :) = 0;
gradientCross(end-1:end, :, :, :) = 0;
gradientCross(:, end-1:end, :, :) = 0;
gradientCross(:, :, end-1:end, :) = 0;

curvature = gradient(:, :, :, 1) .^ 2 .* gradient2(:, :, :, 2) ...
          + gradient(:, :, :, 1) .^ 2 .* gradient2(:, :, :, 3) ...
          + gradient(:, :, :, 2) .^ 2 .* gradient2(:, :, :, 1) ...
          + gradient(:, :, :, 2) .^ 2 .* gradient2(:, :, :, 3) ...
          + gradient(:, :, :, 3) .^ 2 .* gradient2(:, :, :, 1) ...
          + gradient(:, :, :, 3) .^ 2 .* gradient2(:, :, :, 2) ...
      - 2 * gradient(:, :, :, 1) .* gradient(:, :, :, 2) .* gradientCross(:, :, :, 1) ...
      - 2 * gradient(:, :, :, 1) .* gradient(:, :, :, 3) .* gradientCross(:, :, :, 2) ...
      - 2 * gradient(:, :, :, 2) .* gradient(:, :, :, 3) .* gradientCross(:, :, :, 3);

% curvature = curvature ./ sum(gradient .^ 2, 4) .^ 3;
dx = 1;
curvature(curvature < -1 / dx) = -1 / dx;
curvature(curvature >  1 / dx) =  1 / dx;
curvature(isnan(curvature) | isinf(curvature)) = 0;

tvm_write4D(brain, curvature, whiteK);
    
%pial surface
brain = spm_vol(pial);
brain.volume = spm_read_vols(brain);

stencil = tvm_getGradientStencil3D(order);
filter = tvm_getGradientFilter3D(order);

gradient = zeros([brain.dim, 3]);
gradient(:, :, :, 1) = convn(brain.volume, stencil .* filter(:, :, :, 1), 'same');
gradient(:, :, :, 2) = convn(brain.volume, stencil .* filter(:, :, :, 2), 'same');
gradient(:, :, :, 3) = convn(brain.volume, stencil .* filter(:, :, :, 3), 'same');
gradient(1:2, :, :, :) = 0;
gradient(:, 1:2, :, :) = 0;
gradient(:, :, 1:2, :) = 0;
gradient(end-1:end, :, :, :) = 0;
gradient(:, end-1:end, :, :) = 0;
gradient(:, :, end-1:end, :) = 0;

gradient2 = zeros([brain.dim, 3]);
gradient2(:, :, :, 1) = convn(gradient(:, :, :, 1), stencil .* filter(:, :, :, 1), 'same');
gradient2(:, :, :, 2) = convn(gradient(:, :, :, 2), stencil .* filter(:, :, :, 2), 'same');
gradient2(:, :, :, 3) = convn(gradient(:, :, :, 3), stencil .* filter(:, :, :, 3), 'same');
gradient2(1:2, :, :, :) = 0;
gradient2(:, 1:2, :, :) = 0;
gradient2(:, :, 1:2, :) = 0;
gradient2(end-1:end, :, :, :) = 0;
gradient2(:, end-1:end, :, :) = 0;
gradient2(:, :, end-1:end, :) = 0;

gradientCross = zeros([brain.dim, 3]);
gradientCross(:, :, :, 1) = convn(gradient(:, :, :, 1), stencil .* filter(:, :, :, 2), 'same');
gradientCross(:, :, :, 2) = convn(gradient(:, :, :, 1), stencil .* filter(:, :, :, 3), 'same');
gradientCross(:, :, :, 3) = convn(gradient(:, :, :, 2), stencil .* filter(:, :, :, 3), 'same');
gradientCross(1:2, :, :, :) = 0;
gradientCross(:, 1:2, :, :) = 0;
gradientCross(:, :, 1:2, :) = 0;
gradientCross(end-1:end, :, :, :) = 0;
gradientCross(:, end-1:end, :, :) = 0;
gradientCross(:, :, end-1:end, :) = 0;

curvature = gradient(:, :, :, 1) .^ 2 .* gradient2(:, :, :, 2) ...
          + gradient(:, :, :, 1) .^ 2 .* gradient2(:, :, :, 3) ...
          + gradient(:, :, :, 2) .^ 2 .* gradient2(:, :, :, 1) ...
          + gradient(:, :, :, 2) .^ 2 .* gradient2(:, :, :, 3) ...
          + gradient(:, :, :, 3) .^ 2 .* gradient2(:, :, :, 1) ...
          + gradient(:, :, :, 3) .^ 2 .* gradient2(:, :, :, 2) ...
      - 2 * gradient(:, :, :, 1) .* gradient(:, :, :, 2) .* gradientCross(:, :, :, 1) ...
      - 2 * gradient(:, :, :, 1) .* gradient(:, :, :, 3) .* gradientCross(:, :, :, 2) ...
      - 2 * gradient(:, :, :, 2) .* gradient(:, :, :, 3) .* gradientCross(:, :, :, 3);

%@todo make this optional: our level sets are normalised and don't need 
% rescaling as the gradient should be 1 everywhere 
% curvature = curvature ./ sum(gradient .^ 2, 4) .^ 3; 
dx = 1;
curvature(curvature < -1 / dx) = -1 / dx;
curvature(curvature >  1 / dx) =  1 / dx;
curvature(isnan(curvature) | isinf(curvature)) = 0;

tvm_write4D(brain, curvature, pialK);

end %end function











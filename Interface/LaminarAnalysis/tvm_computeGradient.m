function tvm_computeGradient(configuration)
% TVM_COMPUTEGRADIENT
%   TVM_COMPUTEGRADIENT(configuration)
%   @todo Add description
%
%   Copyright (C) Tim van Mourik, 2014-2016, DCCN
%
% Input:
%   i_SubjectDirectory
%   i_White
%   i_Pial
%   i_Normalise
%   i_Order
% Output:
%   o_WhiteGradient
%   o_PialGradient


%% Parse configuration
subjectDirectory    = tvm_getOption(configuration, 'i_SubjectDirectory', pwd());
    % default: current working directory
white               = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_White'));
    %no default
pial                = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_Pial'));
    %no default
normalise           = tvm_getOption(configuration, 'i_Normalise', false);
    %no normalisation
order               = tvm_getOption(configuration, 'i_Order', 10);
    % order: 10
whiteGradient     	= fullfile(subjectDirectory, tvm_getOption(configuration, 'o_WhiteGradient'));
    %no default
pialGradient      	= fullfile(subjectDirectory, tvm_getOption(configuration, 'o_PialGradient'));
    %no default
    
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
if normalise
    gradient = bsxfun(@rdivide, gradient, sqrt(sum(gradient .^ 2, 4)));
end

% [gx, gy, gz] = gradnan(gradient);
% gradient = cat(gx, gy, gz, 4);

tvm_write4D(brain, gradient, whiteGradient);
    

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
if normalise
    gradient = bsxfun(@rdivide, gradient, sqrt(sum(gradient .^ 2, 4)));
end
tvm_write4D(brain, gradient, pialGradient);
    
end %end function











function tvm_gradient(configuration)
% TVM_COMPUTECURVATURE 
%   TVM_COMPUTECURVATURE(configuration)
%   
%
%   Copyright (C) Tim van Mourik, 2014, DCCN
%
%   configuration.i_SubjectDirectory
%   configuration.i_Potential
%   configuration.i_Normalise
%   configuration.i_Order
%   configuration.o_Gradient

%% Parse configuration
subjectDirectory    = tvm_getOption(configuration, 'i_SubjectDirectory', pwd());
    %no default
potentialFile           = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_Potential'));
    %no default
normalise           = tvm_getOption(configuration, 'i_Normalise', false);
    %no normalisation as default
% order               = tvm_getOption(configuration, 'i_Order', 2);
    % default is a standard centred diifference
gradientFile     	= fullfile(subjectDirectory, tvm_getOption(configuration, 'o_Gradient'));
    %no default
    
%%
potential = spm_vol(potentialFile);
potential.volume = spm_read_vols(potential);

%% fourier
% potential.volume(isnan(potential.volume)) = 0;
% fourier = fftshift(fftn(potential.volume)) .* tukeyWindow(potential.dim);
% fourier = ifftshift(fourier);
% 
% nx = potential.dim(1);
% hx = ceil(nx / 2) - 1;
% ftdiff = (2i * pi / sqrt(nx)) * (0:hx);
% ftdiff(nx:-1:nx - hx + 1) = -ftdiff(2 : hx + 1); % correct conjugate symmetry
% fourierX = -fourier .* repmat(ftdiff', [1, potential.dim(2), potential.dim(3)]);
% 
% ny = potential.dim(2);
% hy = ceil(ny / 2) - 1;
% ftdiff = (2i * pi / sqrt(ny)) * (0:hy);
% ftdiff(ny:-1:ny - hy + 1) = -ftdiff(2 : hy + 1); % correct conjugate symmetry
% fourierY = -fourier .* repmat(ftdiff,  [potential.dim(1), 1, potential.dim(3)]);
% 
% nz = potential.dim(3);
% hz = ceil(nz / 2) - 1;
% ftdiff = (2i * pi / sqrt(nz)) * (0:hz);
% ftdiff(nz:-1:nz - hz + 1) = -ftdiff(2 : hz + 1); % correct conjugate symmetry
% fourierZ = -fourier .* permute(repmat(ftdiff', [1, potential.dim(1), potential.dim(2)]), [2, 3, 1]);
% 
% gx = ifftn(fourierX);
% gy = ifftn(fourierY);
% gz = ifftn(fourierZ);

%% stencil method
% stencil = tvm_getGradientStencil3D(order);
% filter = tvm_getGradientFilter3D(order);
% 
% gradient = zeros([potential.dim, 3]);
% gradient(:, :, :, 1) = -convn(potential.volume, stencil .* filter(:, :, :, 1), 'same');
% gradient(:, :, :, 2) = -convn(potential.volume, stencil .* filter(:, :, :, 2), 'same');
% gradient(:, :, :, 3) = -convn(potential.volume, stencil .* filter(:, :, :, 3), 'same');
% gradient(1:2, :, :, :) = 0;
% gradient(:, 1:2, :, :) = 0;
% gradient(:, :, 1:2, :) = 0;
% gradient(end-1:end, :, :, :) = 0;
% gradient(:, end-1:end, :, :) = 0;
% gradient(:, :, end-1:end, :) = 0;

%% gradnan
%It's crazy but for some reason x and y have to be reversed
[gy, gx, gz] = gradnan(potential.volume);
gradient = cat(4, gx, gy, gz);

if normalise
    gradient = bsxfun(@rdivide, gradient, sqrt(sum(gradient .^ 2, 4)));
end

tvm_write4D(potential, gradient, gradientFile);
        
end %end function


function window = tukeyWindow(windowSize)

r = 0.5;
numberOfDimensions = length(windowSize);
window1D = cell(numberOfDimensions, 1);
for i = 1:numberOfDimensions
    window1D{i} = tukeywin(windowSize(i) + mod(windowSize(i), 2), r);
    window1D{i} = window1D{i}(1:end - mod(windowSize(i), 2));
end
[window1D{:}] = meshgrid(window1D{:});
window = reshape([window1D{:}], [windowSize(2), windowSize(1), length(windowSize), windowSize(3)]);
window = prod(permute(window, [2, 1, 4, 3]), 4);

end %end function






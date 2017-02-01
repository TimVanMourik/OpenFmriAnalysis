function tvm_computeDivergence(configuration)
% TVM_COMPUTEGRADIENT
%   TVM_COMPUTEGRADIENT(configuration)
%   @todo Add description
%
%   Copyright (C) Tim van Mourik, 2015-2016, DCCN
%
% Input:
%   i_SubjectDirectory
%   i_VectorField
%   i_Order
% Output:
%   o_Divergence
%

%% Parse configuration
subjectDirectory    = tvm_getOption(configuration, 'i_SubjectDirectory', pwd());
    % default: current working directory
normalFile          = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_VectorField'));
    %no default
order               = tvm_getOption(configuration, 'i_Order', 2);
    % order: 2
divergenceFile   	= fullfile(subjectDirectory, tvm_getOption(configuration, 'o_Divergence'));
    %no default
    
%%
method = 'Fourier';
switch method
    case 'StencilMethod'
        %white matter surface
        brain = spm_vol(normalFile);
        brainVolume = spm_read_vols(brain);

        stencil = tvm_getGradientStencil3D(order);
        filter = tvm_getGradientFilter3D(order);

        gradient = zeros([brain(1).dim, 3]);
        gradient(:, :, :, 1) = convn(brainVolume(:, :, :, 1), stencil .* filter(:, :, :, 1), 'same');
        gradient(:, :, :, 2) = convn(brainVolume(:, :, :, 2), stencil .* filter(:, :, :, 2), 'same');
        gradient(:, :, :, 3) = convn(brainVolume(:, :, :, 3), stencil .* filter(:, :, :, 3), 'same');
        gradient(1:2, :, :, :) = 0;
        gradient(:, 1:2, :, :) = 0;
        gradient(:, :, 1:2, :) = 0;
        gradient(end-1:end, :, :, :) = 0;
        gradient(:, end-1:end, :, :) = 0;
        gradient(:, :, end-1:end, :) = 0;
        tvm_write4D(brain(1), sum(gradient, 4), divergenceFile);
    case 'Fourier'
        brain = spm_vol(normalFile);
        brainVolume = spm_read_vols(brain);
        brainVolume(isnan(brainVolume(:))) = 0;
        
        fourier = fftshift(fftn(brainVolume(:, :, :, 1))) .* tukeyWindow(brain(1).dim);
        fourier = ifftshift(fourier);
        nx = brain(1).dim(1);
        hx = ceil(nx / 2) - 1;
        ftdiff = (2i * pi / nx) * (0:hx);
        ftdiff(nx:-1:nx - hx + 1) = -ftdiff(2 : hx + 1); % correct conjugate symmetry
        fourierX = fourier .* repmat(ftdiff', [1, brain(1).dim(2), brain(1).dim(3)]);

        fourier = fftshift(fftn(brainVolume(:, :, :, 2))) .* tukeyWindow(brain(1).dim);
        fourier = ifftshift(fourier);
        ny = brain(1).dim(2);
        hy = ceil(ny / 2) - 1;
        ftdiff = (2i * pi / ny) * (0:hy);
        ftdiff(ny:-1:ny - hy + 1) = -ftdiff(2 : hy + 1); % correct conjugate symmetry
        fourierY = fourier .* repmat(ftdiff,  [brain(1).dim(1), 1, brain(1).dim(3)]);

        fourier = fftshift(fftn(brainVolume(:, :, :, 3))) .* tukeyWindow(brain(1).dim);
        fourier = ifftshift(fourier);
        nz = brain(1).dim(3);
        hz = ceil(nz / 2) - 1;
        ftdiff = (2i * pi / nz) * (0:hz);
        ftdiff(nz:-1:nz - hz + 1) = -ftdiff(2 : hz + 1); % correct conjugate symmetry
        fourierZ = fourier .* permute(repmat(ftdiff', [1, brain(1).dim(1), brain(1).dim(2)]), [2, 3, 1]);

        gx = real(ifftn(fourierX));
        gy = real(ifftn(fourierY));
        gz = real(ifftn(fourierZ));
        
        tvm_write4D(brain(1), gx + gy + gz, divergenceFile);
end

end %end function



function window = tukeyWindow(windowSize)

r = 1;
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











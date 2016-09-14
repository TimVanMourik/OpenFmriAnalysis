function tvm_curvature(configuration)
% TVM_COMPUTECURVATURE 
%   TVM_COMPUTECURVATURE(configuration)
%   
%
%   Copyright (C) Tim van Mourik, 2014, DCCN
%
%   configuration.SubjectDirectory
%   configuration.White
%   configuration.Pial
%   configuration.WhiteCurvature
%   configuration.PialCurvature

%% Parse configuration
subjectDirectory        = tvm_getOption(configuration, 'i_SubjectDirectory', pwd());
    %no default
potentialFile               = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_Potential'));
    %no default
curvatureFile           = fullfile(subjectDirectory, tvm_getOption(configuration, 'o_Curvature'));
    %no default
    
%%
potential = spm_vol(potentialFile);
potential.volume = spm_read_vols(potential);

%% gradient
potential.volume(isnan(potential.volume)) = 0;
fourier = fftshift(fftn(potential.volume)) .* tukeyWindow(potential.dim);
fourier = ifftshift(fourier);

nx = potential.dim(1);
hx = ceil(nx / 2) - 1;
ftdiff = (2i * pi / nx) * (0:hx);
ftdiff(nx:-1:nx - hx + 1) = -ftdiff(2 : hx + 1); % correct conjugate symmetry
fourierX = fourier .* repmat(ftdiff', [1, potential.dim(2), potential.dim(3)]) .^ 2;

ny = potential.dim(2);
hy = ceil(ny / 2) - 1;
ftdiff = (2i * pi / ny) * (0:hy);
ftdiff(ny:-1:ny - hy + 1) = -ftdiff(2 : hy + 1); % correct conjugate symmetry
fourierY = fourier .* repmat(ftdiff,  [potential.dim(1), 1, potential.dim(3)]) .^ 2;

nz = potential.dim(3);
hz = ceil(nz / 2) - 1;
ftdiff = (2i * pi / nz) * (0:hz);
ftdiff(nz:-1:nz - hz + 1) = -ftdiff(2 : hz + 1); % correct conjugate symmetry
fourierZ = fourier .* permute(repmat(ftdiff', [1, potential.dim(1), potential.dim(2)]), [2, 3, 1]) .^ 2;

gx = real(ifftn(fourierX));
gy = real(ifftn(fourierY));
gz = real(ifftn(fourierZ));

gradient = gx ;%+ gy + gz;

%%
tvm_write4D(potential, gradient, curvatureFile);

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
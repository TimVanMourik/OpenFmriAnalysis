function tvm_computeDivergence(configuration)
% TVM_COMPUTECURVATURE 
%   TVM_COMPUTECURVATURE(configuration)
%   
%
%   Copyright (C) Tim van Mourik, 2014, DCCN
%
%   configuration.i_SubjectDirectory
%   configuration.i_White
%   configuration.i_Pial
%   configuration.i_Order
%   configuration.o_WhiteGradient
%   configuration.o_PialGradient

%% Parse configuration
subjectDirectory    = tvm_getOption(configuration, 'i_SubjectDirectory', pwd());
    %no default
normalFile          = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_VectorField'));
    %no default
divergenceFile   	= fullfile(subjectDirectory, tvm_getOption(configuration, 'o_Divergence'));
    %no default
order               = tvm_getOption(configuration, 'i_Order', 2);
    %no default
    
%%
%white matter surface
brain = spm_vol(normalFile);
brainVolume = spm_read_vols(brain);

stencil = tvm_getGradientStencil3D(order);
filter = tvm_getGradientFilter3D(order);

gradient = zeros([brain(1).dim, 3]);
gradient(:, :, :, 1) = convn(brainVolume(:, :, :, 1), stencil .* filter(:, :, :, 1), 'same');
gradient(:, :, :, 2) = convn(brainVolume(:, :, :, 1), stencil .* filter(:, :, :, 2), 'same');
gradient(:, :, :, 3) = convn(brainVolume(:, :, :, 1), stencil .* filter(:, :, :, 3), 'same');
gradient(1:2, :, :, :) = 0;
gradient(:, 1:2, :, :) = 0;
gradient(:, :, 1:2, :) = 0;
gradient(end-1:end, :, :, :) = 0;
gradient(:, end-1:end, :, :) = 0;
gradient(:, :, end-1:end, :) = 0;
tvm_write4D(brain(1), sum(gradient, 4), divergenceFile);

end %end function











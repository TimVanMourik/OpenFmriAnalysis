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
white               = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_WhiteNormal'));
    %no default
pial                = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_PialNormal'));
    %no default
whiteDivergence   	= fullfile(subjectDirectory, tvm_getOption(configuration, 'o_WhiteDivergence'));
    %no default
pialDivergence     	= fullfile(subjectDirectory, tvm_getOption(configuration, 'o_PialDivergence'));
    %no default
order               = tvm_getOption(configuration, 'i_Order', 10);
    %no default
    
%%
%white matter surface
brain = spm_vol(white);
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
tvm_write4D(brain(1), sum(gradient, 4), whiteDivergence);
    

%pial surface
brain = spm_vol(pial);
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
tvm_write4D(brain(1), sum(gradient, 4), pialDivergence);
    
end %end function











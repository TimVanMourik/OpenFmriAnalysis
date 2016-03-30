function tvm_divergence(configuration)
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
vectorFile          = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_VectorField'));
    %no default
divergenceFile     	= fullfile(subjectDirectory, tvm_getOption(configuration, 'o_Divergence'));
    %no default
    
%%
gradient = spm_vol(vectorFile);
grad = spm_read_vols(gradient);
curvature = divergence(grad(:, :, :, 1), grad(:, :, :, 2), grad(:, :, :, 3));

tvm_write4D(gradient(1), curvature, divergenceFile);
        
end %end function











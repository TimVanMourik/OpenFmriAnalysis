function tvm_keepGreyMatterOnly(configuration)
% TVM_KEEPGREYMATTERONLY 
%   TVM_KEEPGREYMATTERONLY(configuration)
%   
%
%   Copyright (C) Tim van Mourik, 2015, DCCN
%
%   configuration.SubjectDirectory
%

%% Parse configuration
subjectDirectory =      tvm_getOption(configuration, 'i_SubjectDirectory', pwd());
    %no default
inputFiles              = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_VolumeFile'));
    %no default
laplacianFile           = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_Laplacian'));
    %no default
outputFiles             = fullfile(subjectDirectory, tvm_getOption(configuration, 'o_VolumeFile'));
    %no default
    
definitions = tvm_definitions();

%%
f = fullfile(laplacianFile);
laplace = spm_vol(f);
laplace.volume = spm_read_vols(laplace);
for i = 1:length(inputFiles)
    v = spm_vol(inputFiles{i});
    v.volume = spm_read_vols(v);
    v.volume = v.volume & (laplace.volume > 0 & laplace.volume < 1);
    
    v.fname = outputFiles{i};
    spm_write_vol(v, v.volume);
end

end






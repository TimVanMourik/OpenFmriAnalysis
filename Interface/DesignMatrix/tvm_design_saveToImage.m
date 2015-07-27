function tvm_design_saveToImage(configuration)
%   
%
%   Copyright (C) Tim van Mourik, 2015, DCCN
%

%% Parse configuration
subjectDirectory        = tvm_getOption(configuration, 'i_SubjectDirectory', '.');
    %no default
designFileIn            = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_Design'));
    %no default
imageFile               = fullfile(subjectDirectory, tvm_getOption(configuration, 'o_Image'));
    %no default
  
definitions = tvm_definitions();

%%
load(designFileIn, definitions.GlmDesign);

%% Save picture
figure('units', 'normalized', 'outerposition', [0, 0, 1, 1]);
imagesc(design.DesignMatrix);
%todo: incorporate the design matrix labels
saveas(gca, imageFile);

end %end function



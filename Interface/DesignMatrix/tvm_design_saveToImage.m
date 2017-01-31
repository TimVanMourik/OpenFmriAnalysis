function tvm_design_saveToImage(configuration)
% TVM_DESIGN_SAVETOIMAGE
%   TVM_DESIGN_SAVETOIMAGE(configuration)
%   @todo Add description
%
%   Copyright (C) Tim van Mourik, 2015-2016, DCCN
%
% Input:
%   i_SubjectDirectory
%   i_DesignMatrix
% Output:
%   o_Image

%% Parse configuration
subjectDirectory        = tvm_getOption(configuration, 'i_SubjectDirectory', pwd());
    % default: current working directory
designFileIn            = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_DesignMatrix'));
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



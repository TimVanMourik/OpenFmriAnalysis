function tvm_design_motionRegression(configuration)
% TVM_DESIGN_MOTIONREGRESSION
%   TVM_DESIGN_MOTIONREGRESSION(configuration)
%   @todo Add description
%   @todo Support different formats of motion files. Currently it's
%   identical to adding a matrix from a file
%
%   Copyright (C) Tim van Mourik, 2015-2016, DCCN
%
% Input:
%   i_SubjectDirectory
%   i_DesignMatrix
%   i_MotionFiles
% Output:
%   o_DesignMatrix

%% Parse configuration
subjectDirectory        = tvm_getOption(configuration, 'i_SubjectDirectory', pwd());
    % default: current working directory
designFileIn            = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_DesignMatrix'));
    %no default
motionFiles             = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_MotionFiles'));
    %no default
designFileOut           = fullfile(subjectDirectory, tvm_getOption(configuration, 'o_DesignMatrix'));
    %no default
    
definitions = tvm_definitions();

%%
load(designFileIn, definitions.GlmDesign);

numberOfMotionRegressors = 6;
designMatrix = zeros(design.Length, design.NumberOfPartitions * numberOfMotionRegressors);
[root, ~, ~] = fileparts(motionFiles);
motionFiles = dir(motionFiles);

% @todo what if you don't want all given session within the folder
for column = 1:design.NumberOfPartitions
    motionParameters = importdata(fullfile(root, motionFiles(column).name));
    %de-mean motion parameters
    motionParameters = bsxfun(@minus, motionParameters, mean(motionParameters, 1));
    % orthogonalise the parameters
    motionParameters = spm_orth(motionParameters);
    % and rescale
    motionParameters = bsxfun(@rdivide, motionParameters, sqrt(sum(motionParameters .^ 2, 1)));

    designMatrix(design.Partitions{column}, (1:numberOfMotionRegressors) + numberOfMotionRegressors * (column - 1)) = motionParameters;
end
regressorLabels = cell(1, size(designMatrix, 2));
for i = 1:size(designMatrix, 2)
    regressorLabels{i} = 'Motion';
end
% add the design matrix to the rest
design.DesignMatrix     = [design.DesignMatrix, designMatrix];
design.RegressorLabel   = [design.RegressorLabel, regressorLabels];

% @todo add temporal derivatives

save(designFileOut, definitions.GlmDesign);


end %end function
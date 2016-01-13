function tvm_design_orthogonalise(configuration)
%   
%
%   Copyright (C) Tim van Mourik, 2015, DCCN
%

%% Parse configuration
subjectDirectory        = tvm_getOption(configuration, 'i_SubjectDirectory', '.');
    %no default
designFileIn            = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_DesignMatrix'));
    %no default
regressorsLabels        = tvm_getOption(configuration, 'i_Order');
    %no default
designFileOut           = fullfile(subjectDirectory, tvm_getOption(configuration, 'o_DesignMatrix'));
    %no default
    
definitions = tvm_definitions();

%%
load(designFileIn, definitions.GlmDesign);

regressorsOfInterest = cellfun(@strfind, repmat({design.RegressorLabel}, [1, length(regressorsLabels)]), regressorsLabels, 'UniformOutput', false);
regressorsOfInterest = mod(find(~cellfun(@isempty, [regressorsOfInterest{:}])), length(design.RegressorLabel));

design.DesignMatrix(:, regressorsOfInterest) = spm_orth(design.DesignMatrix(:, regressorsOfInterest));

save(designFileOut, definitions.GlmDesign);


end %end function
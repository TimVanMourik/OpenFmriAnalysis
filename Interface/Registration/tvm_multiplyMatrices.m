function tvm_multiplyMatrices(configuration)
% TVM_MULTIPLYMATRICES
%   TVM_MULTIPLYMATRICES(configuration)
%   @todo Add description
%   
%
%   Copyright (C) Tim van Mourik, 2014, DCCN
%
% Input:
%   i_SubjectDirectory
%   i_Matrices
% Output:
%   o_Matrix
%

%% Parse configuration
subjectDirectory =      tvm_getOption(configuration, 'i_SubjectDirectory', pwd());
    % default: current working directory
inputMatrices =         fullfile(subjectDirectory, tvm_getOption(configuration, 'i_Matrices'));
    %no default
outputMatrix =      	fullfile(subjectDirectory, tvm_getOption(configuration, 'o_Matrix'));
    %no default
    
% definitions = tvm_definitions();    

%%
m = eye(4);
for i = 1:length(inputMatrices)
    load(inputMatrices{i}, 'coregistrationMatrix');
    m = m * coregistrationMatrix;
end
coregistrationMatrix = m;

save(outputMatrix, 'coregistrationMatrix');

end %end function




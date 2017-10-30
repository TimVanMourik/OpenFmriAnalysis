function tvm_use3dQwarp(configuration)
% TVM_USE3DQWARP 
%   TVM_USE3DQWARP(configuration)
%   
%
%   Copyright (C) Tim van Mourik, 2017, DCCN
%

%% Parse configuration
subjectDirectory =      tvm_getOption(configuration, 'i_SubjectDirectory');
    %no default
referenceFile =         fullfile(subjectDirectory, tvm_getOption(configuration, 'i_ReferenceVolume'));
    %no default
moveFile =              fullfile(subjectDirectory, tvm_getOption(configuration, 'i_MoveVolume'));
    %no default
costFunction =          tvm_getOption(configuration, 'i_CostFunction', '');
    %no default
warpedimage =           fullfile(subjectDirectory, tvm_getOption(configuration, 'o_WarpedImage'));
    %no default
displacementMap =       fullfile(subjectDirectory, tvm_getOption(configuration, 'o_FieldMap'));
    %no default

%%
switch costFunction
    case ''
        costFunction = '';
    case 'HellingerDistance'
        costFunction = '-hel';
    case 'MutualInformation'
        costFunction = '-mi';
    case 'NormalisedMutualInformation'
        costFunction = '-nmi';
    otherwise
        costFunction = '';
end

unixCommand = sprintf('FSLOUTPUTTYPE=NIFTI; 3dqwarp --ref=%s --in=%s --fout=%s --iout=%s', referenceFile, moveFile, fieldMap, warpedimage);
unixCommand = sprintf('3dQwarp -nopadWARP -base %s -source %s -prefix %s %s -noXdis -noZdis -verb;', referenceFile, moveFile, warpedimage, costFunction);
% unix(unixCommand);
[root, file, extension] = fileparts(warpedimage);
movefile(fullfile(root, [file, '_WARP', extension]), displacementMap);


end %end function

    
    
    
    
    
    
    
    
    
    

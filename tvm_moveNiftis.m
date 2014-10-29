function tvm_moveNiftis(configuration)
% TVM_MOVENIFTIS Moves niftis to destination folder
%   TVM_MOVENIFTIS(configuration)
%
%   Copyright (C) Tim van Mourik, 2014, DCCN
%
%   configuration.SubjectDirectory
%   configuration.SourceFolder
%   configuration.DestinationAnatomicals
%   configuration.DestinationFunctionals

%% Parse configuration
subjectDirectory    = tvm_getOption(configuration, 'SubjectDirectory');
    %no default
sourceFolder      = [subjectDirectory, tvm_getOption(configuration, 'SourceFolder')];
    %no default
destinationAnatomicals = fullfile(subjectDirectory, tvm_getOption(configuration, 'DestinationAnatomicals'));
    %no default
destinationFunctionals = fullfile(subjectDirectory, tvm_getOption(configuration, 'DestinationFunctionals'));
    %no default
    
definitions = tvm_definitions;

%%
anatomicalData = definitions.AnatomicalData;
anatomicals = [];
for i = 1:length(anatomicalData)
   folders = dir(fullfile(sourceFolder, ['*' anatomicalData{i} '*']));
   folders = folders([folders.isdir]);
   anatomicals = [anatomicals; {folders.name}]; %#ok<AGROW>
end

for i = 1:length(anatomicals)
    movefile(fullfile(sourceFolder, anatomicals{i}), destinationAnatomicals);
end

functionalData = definitions.FunctionalData;
functionals=[];
for i = 1:length(functionalData)
    folders = dir(fullfile(sourceFolder, ['*' functionalData{i} '*']));
    folders = folders([folders.isdir]);
    functionals = [functionals; {folders.name}]; %#ok<AGROW>
end

for i = 1:length(functionals)
    if ~isempty(dir(fullfile(sourceFolder, functionals{i}, '*.nii')))
        movefile(fullfile(sourceFolder, functionals{i}, '*.nii'), destinationFunctionals);  %to move functional folders remome '/' '*.nii'
    end
end

end %end function
function tvm_design_empty(configuration)
%   
%
%   Copyright (C) Tim van Mourik, 2015, DCCN
%

%% Parse configuration
subjectDirectory        = tvm_getOption(configuration, 'i_SubjectDirectory', pwd());
    %no default
designFileOut           = fullfile(subjectDirectory, tvm_getOption(configuration, 'o_DesignMatrix'));
    %no default
functionalFiles         = tvm_getOption(configuration, 'i_FunctionalFiles', '');
    %no default
functionalFolder        = tvm_getOption(configuration, 'i_FunctionalFolder', '');
    %no default
  
definitions = tvm_definitions();

%%
if ~isempty(functionalFolder)
    allVolumes = [];
    for file = 1:length(definitions.VolumeFileTypes)
        allVolumes = [allVolumes; dir(fullfile(subjectDirectory, functionalFolder, ['*', definitions.VolumeFileTypes{file}]))];
    end

    numberOfRuns = length(allVolumes);
    numberOfVolumes = zeros(1, numberOfRuns);
    for session = 1:length(allVolumes)
        sessionVolumes = spm_vol(fullfile(subjectDirectory, functionalFolder, allVolumes(session).name));
        numberOfVolumes(session) = length(sessionVolumes);
    end
    startOfRun = [0, cumsum(numberOfVolumes)] + 1;
    partitions = [startOfRun(1:end-1); startOfRun(2:end) - 1]';
elseif ~isempty(functionalFiles)
    numberOfRuns = length(functionalFiles);
    numberOfVolumes = zeros(1, numberOfRuns);
    for i = 1:numberOfRuns
        allVolumes = dir(fullfile(subjectDirectory, functionalFiles{i}));
        numberOfVolumes(i) = length(allVolumes);
    end
    startOfRun = [0, cumsum(numberOfVolumes)] + 1;
    partitions = [startOfRun(1:end-1); startOfRun(2:end) - 1]';
end

%%
numberOfPartitions = size(partitions, 1);
design = [];
design.NumberOfPartitions = numberOfPartitions;
design.Partitions = cell(numberOfPartitions, 1);
design.PartitionLabel = cell(numberOfPartitions, 1);
for i = 1:numberOfPartitions
    design.Partitions{i} = partitions(i, 1):partitions(i, 2);
    design.PartitionLabel{i} = sprintf('Run %d', i);
end

design.DesignMatrix = [];
design.Length = design.Partitions{end}(end);
design.RegressorLabel = {};
save(designFileOut, definitions.GlmDesign);

end %end function



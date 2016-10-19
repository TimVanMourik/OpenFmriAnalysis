function tvm_designMatrixToTimeCourse(configuration)
% TVM_DESIGNMATRIXTOTIMECOURSE 
%   TVM_DESIGNMATRIXTOTIMECOURSE(configuration)
%   
%
%   Copyright (C) Tim van Mourik, 2014, DCCN
%
%   configuration.SubjectDirectory
%   configuration.TimeCourse
%   configuration.DesignMatrix
%   configuration.FunctionalFolders

%% Parse configuration
subjectDirectory        = tvm_getOption(configuration, 'i_SubjectDirectory', pwd());
    %no default
designMatricesFiles     = tvm_getOption(configuration, 'i_DesignMatrix');
    %no default
functionalFolders       = tvm_getOption(configuration, 'i_FunctionalFolder', '');
    % ''
functionalFiles         = tvm_getOption(configuration, 'i_FunctionalFiles', '');
    % ''
regressionApproach      = tvm_getOption(configuration, 'i_RegressionApproach', 'OLS');
    %no default
timeCourseFiles         = fullfile(subjectDirectory, tvm_getOption(configuration, 'o_TimeCourse'));
    %no default
    
definitions = tvm_definitions();

%%

% load data
if ~isempty(functionalFiles)
    allVolumes = dir(fullfile(subjectDirectory, functionalFiles));
    [path, ~, ~] = fileparts(functionalFiles);
    allVolumes = {allVolumes(:).name};
    spmVolumes = spm_vol(fullfile(subjectDirectory, path, allVolumes));
elseif ~isempty(functionalFolders) && iscell(functionalFolders)
    %@todo implement this way of loading that's compatible 
%     for session = 1:length(functionalFolders)
%         directory = fullfile(subjectDirectory, functionalFolders{session});
%         %@todo change into definitions functions
%         allVolumes = [];
%         for file = 1:length(definitions.VolumeFileTypes)
%             allVolumes = [allVolumes; dir(fullfile(directory, ['*', definitions.VolumeFileTypes{file}]))];
%         end
%         allVolumes = char({allVolumes.name});
%         allVolumes = [repmat([directory filesep], [size(allVolumes, 1), 1]), char(allVolumes)];     
%     end
elseif ~isempty(functionalFolders) && ischar(functionalFolders)
    directory = fullfile(subjectDirectory, functionalFolders);
    allVolumes = [];
    for file = 1:length(definitions.VolumeFileTypes)
        allVolumes = [allVolumes; dir(fullfile(directory, ['*', definitions.VolumeFileTypes{file}]))]; %#ok<*AGROW>
    end
    allVolumes = {allVolumes(:).name};
    spmVolumes = spm_vol(fullfile(subjectDirectory, functionalFolders, allVolumes));
end

numberOfRegions = length(designMatricesFiles);
designFiles = cell(numberOfRegions, 1);
volumeData  = cell(numberOfRegions, 1);
% load design matrices
for region = 1:numberOfRegions
    load(fullfile(subjectDirectory, designMatricesFiles{region}), definitions.GlmDesign);
    designFiles{region} = design;
    if ~isfield(design, 'Locations')
        designFiles{region}.Locations = [];
    end
%     if ~isfield(design, 'CovarianceMatrix')
%         designFiles{region}.CovarianceMatrix = inv(design.DesignMatrix' * design.DesignMatrix);
%     end
    numberOfSessions = length(spmVolumes);
    volumeData{region} = cell(numberOfSessions, 1);
    for session = 1:numberOfSessions
        numberOfVoxels = size(design.DesignMatrix, 1);
        numberOfTimpoints = size(spmVolumes{session}, 1);
        volumeData{region}{session} = zeros(numberOfVoxels, numberOfTimpoints);
        for timepoint = 1:numberOfTimpoints
            % read in one by one: the intention is that this works for
            % lots of high-res data, which can't be loaded all at once.
            volume = spm_read_vols(spmVolumes{session}(timepoint));
            volumeData{region}{session}(:, timepoint) = volume(design.Indices);
        end
    end
end
clear('volume', 'design');

for region = 1:numberOfRegions
    numberOfSessions = length(volumeData{region});
    timeCourses = cell(numberOfSessions, 1);
    for session = 1:numberOfSessions
        timeCourses{session} = regressLayers(designFiles{region}.DesignMatrix, volumeData{region}{session}, regressionApproach, designFiles{region}.Locations);
    end
    save(timeCourseFiles{region}, definitions.TimeCourses);
end

end %end function


function timePoints = regressLayers(designMatrix, voxelValues, estimationMethod, locations)

if nargin == 3
    locations = [];
end

switch estimationMethod
    case 'OLS'
        timePoints = designMatrix \ voxelValues;
        
    case 'GLS'
        if isempty(locations)
            error('Please recreate your design matrix to include locations');
        end
        numberOfPoints = size(locations, 1);
        [x, y] = meshgrid(1:numberOfPoints, 1:numberOfPoints);
        distances = sqrt(sum(reshape(locations(x, :) - locations(y, :), [numberOfPoints, numberOfPoints, 3]) .^ 2, 3));
        gaussianFWHM = sqrt(2);
        stddev = gaussianFWHM / (2 * sqrt(2 * log(2)));
        errorVariance = normpdf(distances, 0, stddev) / normpdf(0, 0, stddev);
        errorVariance(distances > 2 * gaussianFWHM) = 0; %after 2 FWHM, the normpdf < 10 ^ -4
        timePoints = (designMatrix' / errorVariance * designMatrix) \ designMatrix' / errorVariance * voxelValues;

    case 'RobustFit'
        timePoints = zeros(size(designMatrix, 2), size(voxelValues, 2) + 1);
        for t = 1:size(voxelValues, 2)
            timePoints = robustfit(designMatrix, voxelValues(:, t), 'bisquare', 10);
%             you can't un-model the constant in robustfit()
        end
        timePoints = bsxfun(@plus, timePoints(1, :), timePoints(2:end, :));
        
    case 'L1Norm'
        timePoints = zeros(size(designMatrix, 2), size(voxelValues, 2));
        for t = 1:size(voxelValues, 2)
            n = size(designMatrix, 2);
            m = size(designMatrix, 1);

            f   = [zeros(n,1); ones(m,1); ones(m,1) ];
            Aeq = [designMatrix, -eye(m), +eye(m) ];
            lb  = [-Inf * ones(n, 1); zeros(m, 1); zeros(m, 1) ];
            xzz = linprog(f, [], [], Aeq, voxelValues(:, t), lb, [], [], optimset('Display', 'off'));
            timePoints(:, t) = xzz(1:n, :);
        end
        
    case 'Classification'
        m = max(designMatrix, [], 2);
        designMatrix(bsxfun(@ne, designMatrix, m)) = 0;
        designMatrix(bsxfun(@eq, designMatrix, m)) = 1;
        timePoints = designMatrix \ voxelValues;
        
    case 'Interpolation'
        timePoints = bsxfun(@rdivide, designMatrix' * voxelValues, sum(designMatrix, 1)');
end

end









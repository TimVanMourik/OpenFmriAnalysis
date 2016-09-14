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
functionalIndices       = tvm_getOption(configuration, 'i_FunctionalSelection', []);
    %no default
timeCourseFiles         = tvm_getOption(configuration, 'o_TimeCourse');
    %no default
    
definitions = tvm_definitions();

%%
if ~isempty(functionalFolders)
    %save design matrix
    for region = 1:length(designMatricesFiles)
        load(fullfile(subjectDirectory, designMatricesFiles{region}), definitions.GlmDesign);
        if ~isfield(design, 'Locations');
            design.Locations = [];
        end
        if ~isfield(design, 'CovarianceMatrix')
            design.CovarianceMatrix = inv(design.DesignMatrix' * design.DesignMatrix);
        end

        if iscell(functionalFolders) %list of 3D files
            timeCourses = cell(size(functionalFolders));
            for session = 1:length(functionalFolders)
                directory = fullfile(subjectDirectory, functionalFolders{session});
                %@todo change into definitions functions
                allVolumes = [];
                for file = 1:length(definitions.VolumeFileTypes)
                    allVolumes = [allVolumes; dir(fullfile(directory, ['*', definitions.VolumeFileTypes{file}]))];
                end
                allVolumes = char({allVolumes.name});
                allVolumes = [repmat([directory filesep], [size(allVolumes, 1), 1]), char(allVolumes)];

                timeCourses{session} = zeros(size(design.DesignMatrix, 2), size(allVolumes, 1));
                for timePoint = 1:size(allVolumes, 1)
                    volume = spm_read_vols(spm_vol(allVolumes(timePoint, :)));                
                    voxelValues = volume(design.Indices);

                    timeCourses{session}(: ,timePoint) = regressLayers(voxelValues, design.DesignMatrix, regressionApproach, design.Locations);
                end        
            end
        else %list of 4D files
            directory = fullfile(subjectDirectory, functionalFolders);
            allVolumes = [];
            for file = 1:length(definitions.VolumeFileTypes)
                allVolumes = [allVolumes; dir(fullfile(directory, ['*', definitions.VolumeFileTypes{file}]))];
            end
            if isempty(functionalIndices)
                functionalIndices = 1:size(allVolumes, 1);
            end
            allVolumes = allVolumes(functionalIndices, :);

            timeCourses = cell(size(allVolumes));
            for session = 1:length(allVolumes)
                sessionVolumes = spm_vol(fullfile(directory, allVolumes(session).name));
                timeCourses{session} = zeros(size(design.DesignMatrix, 2), size(sessionVolumes, 1));
                for timePoint = 1:size(sessionVolumes, 1)
                    volume = spm_read_vols(sessionVolumes(timePoint));
                    voxelValues = volume(design.Indices);
                    timeCourses{session}(design.NonZerosColumns, timePoint) = regressLayers(design.DesignMatrix(:, design.NonZerosColumns), voxelValues, regressionApproach, design.Locations);
%                     removedRows = design.DesignMatrix(:, 1) >= 1;
%                     [timeCourses{session}(design.NonZerosColumns, timePoint), covariance{session}(:, :, timePoint)] = regressLayers(voxelValues(~removedRows), design.DesignMatrix(~removedRows, design.NonZerosColumns), design.CovarianceMatrix, regressionApproach);
                end        
            end
        end
        
%         eval(tvm_changeVariableNames(definitions.TimeCourses, timeCourses));
        save(fullfile(subjectDirectory, timeCourseFiles{region}), definitions.TimeCourses);
    end
elseif ~isempty(functionalFiles)
    for region = 1:length(designMatricesFiles)
        load(fullfile(subjectDirectory, designMatricesFiles{region}), definitions.GlmDesign);
        timeCourses = cell(length(design), 1);
        for label = 1:length(design)
            if ~isfield(design{label}, definitions.CovarianceMatrix)
                design{label}.CovarianceMatrix = inv(design{label}.DesignMatrix' * design{label}.DesignMatrix);
            end
            allVolumes = dir(fullfile(subjectDirectory, functionalFiles));
            [path, ~, ~] = fileparts(functionalFiles);
            allVolumes = {allVolumes(:).name};
            timeCourses{label} = zeros(size(design{label}.DesignMatrix, 2), size(allVolumes, 2));
            for timePoint = 1:size(allVolumes, 2)
                v = spm_vol(fullfile(subjectDirectory, path, allVolumes(timePoint)));
                volume = spm_read_vols(v{1});                
                voxelValues = volume(design{label}.Indices);

                timeCourses{label}(: ,timePoint) = regressLayers(design{label}.DesignMatrix, voxelValues, regressionApproach, design{label}.Locations);
            end
        end
%         eval(tvm_changeVariableNames(definitions.TimeCourses, timeCourses));
        save(fullfile(subjectDirectory, timeCourseFiles{region}), definitions.TimeCourses);
    end
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
        timePoints = robustfit(designMatrix, voxelValues, 'bisquare', 10);
        % you can't un-model the constant in robustfit()
        timePoints = timePoints(1) + timePoints(2:end);
        
    case 'Classification'
        m = max(designMatrix, [], 2);
        designMatrix(bsxfun(@ne, designMatrix, m)) = 0;
        designMatrix(bsxfun(@eq, designMatrix, m)) = 1;
        timePoints = designMatrix \ voxelValues;
        
    case 'Interpolation'
        timePoints = designMatrix' * voxelValues ./ sum(designMatrix, 1)';
end

end









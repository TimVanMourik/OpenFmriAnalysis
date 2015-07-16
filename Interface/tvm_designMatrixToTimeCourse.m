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
subjectDirectory        = tvm_getOption(configuration, 'i_SubjectDirectory');
    %no default
designMatricesFiles     = tvm_getOption(configuration, 'i_DesignMatrix');
    %no default
functionalFolders       = tvm_getOption(configuration, 'i_FunctionalFolder', []);
    %no default
functionalFiles         = tvm_getOption(configuration, 'i_FunctionalFiles', []);
    %no default
regressionApproach      = tvm_getOption(configuration, 'i_RegrassionApproach', 'OLS');
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
        if ~isfield(design, 'CovarianceMatrix')
            design.CovarianceMatrix = inv(design.DesignMatrix' * design.DesignMatrix);
        end

        if iscell(functionalFolders) %list of 3D files
            timeCourses = cell(size(functionalFolders));
            covariance = cell(size(functionalFolders));
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
                covariance{session} = zeros([size(design.CovarianceMatrix), size(allVolumes, 1)]);
                for timePoint = 1:size(allVolumes, 1)
                    volume = spm_read_vols(spm_vol(allVolumes(timePoint, :)));                
                    voxelValues = volume(design.Indices);

                    [timeCourses{session}(: ,timePoint), covariance{session}(:, :, timePoint)] = regressLayers(voxelValues, design.DesignMatrix, design.CovarianceMatrix, regressionApproach);
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
            covariance = cell(size(allVolumes));

            for session = 1:length(allVolumes)
                sessionVolumes = spm_vol(fullfile(directory, allVolumes(session).name));
                timeCourses{session} = zeros(size(design.DesignMatrix, 2), size(sessionVolumes, 1));
                covariance{session} = zeros([size(design.CovarianceMatrix), size(sessionVolumes, 1)]);
                for timePoint = 1:size(sessionVolumes, 1)
                    volume = spm_read_vols(sessionVolumes(timePoint));
                    voxelValues = volume(design.Indices);
                    [timeCourses{session}(design.NonZerosColumns, timePoint), covariance{session}(:, :, timePoint)] = regressLayers(voxelValues, design.DesignMatrix(:, design.NonZerosColumns), design.CovarianceMatrix, regressionApproach);
%                     removedRows = design.DesignMatrix(:, 1) >= 1;
%                     [timeCourses{session}(design.NonZerosColumns, timePoint), covariance{session}(:, :, timePoint)] = regressLayers(voxelValues(~removedRows), design.DesignMatrix(~removedRows, design.NonZerosColumns), design.CovarianceMatrix, regressionApproach);
                end        
            end
        end
        
        eval(tvm_changeVariableNames(definitions.TimeCourses, timeCourses));
        eval(tvm_changeVariableNames(definitions.Covariance, covariance));
        save(fullfile(subjectDirectory, timeCourseFiles{region}), definitions.TimeCourses, definitions.Covariance);
    end
else
    for region = 1:length(designMatricesFiles)
        load(fullfile(subjectDirectory, designMatricesFiles{region}), definitions.GlmDesign);
        if ~isfield(design, definitions.CovarianceMatrix)
            design.CovarianceMatrix = inv(design.DesignMatrix' * design.DesignMatrix);
        end
        allVolumes = fullfile(subjectDirectory, functionalFiles);

        timeCourses{1} = zeros(size(design.DesignMatrix, 2), size(allVolumes, 1));
        covariance{1} = zeros([size(design.CovarianceMatrix), size(allVolumes, 1)]);
        for timePoint = 1:size(allVolumes, 1)
            volume = spm_read_vols(spm_vol(allVolumes{1}(timePoint, :)));                
            voxelValues = volume(design.Indices);

            [timeCourses{1}(: ,timePoint), covariance{1}(:, :, timePoint)] = regressLayers(voxelValues, design.DesignMatrix, design.CovarianceMatrix, regressionApproach);
        end
        eval(tvm_changeVariableNames(definitions.TimeCourses, timeCourses));
        eval(tvm_changeVariableNames(definitions.Covariance, covariance));
        save(fullfile(subjectDirectory, timeCourseFiles{region}), definitions.TimeCourses, definitions.Covariance);
    end
end

end %end function


function [timePoints, covariance] = regressLayers(voxelValues, designMatrix, covariance, regressionApproach)

switch regressionApproach
    case 'OLS'
        % @todo instead, compute pinv and multiply that every time point!
        timePoints = designMatrix \ voxelValues;
        sumOfSquares = sum((voxelValues - designMatrix * timePoints) .^ 2);
%         vcov = X'X * SSres / (n - p)
        covariance = covariance * (sumOfSquares / (length(voxelValues) - length(covariance)));
 
    case 'GLS'
        
end

end










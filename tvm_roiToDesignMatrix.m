function output = tvm_roiToDesignMatrix(configuration)

memtic

%load in layers
subjectDirectory = configuration.SubjectDirectory;
layers = spm_vol([subjectDirectory configuration.Layers]);

for i = 1:length(configuration.ROI)
    %load in ROI
    roi = spm_vol([subjectDirectory configuration.ROI{i}]);
    roi.volume = spm_read_vols(roi);

    %match ROI with layers
    %make design matrix [Vox X Layers]
    indices = find(roi.volume ~= 0);
    designMatrix = zeros(length(indices), length(layers));

    for j = 1:length(layers)
        layerI = spm_read_vols(layers(j));
        designMatrix(:, j) = layerI(indices);
    end
    % @todo
    %if the ROI is not a binary mask, the weights should be adapted accordingly
    % designMatrix = bsxfun(@times, designMatrix, roi.volume(indices));

    design = [];
    design.Indices = indices;
    design.DesignMatrix = designMatrix;

    %save design matrix
    save([subjectDirectory configuration.DesignMatrix{i}], 'design');
end

output = memtoc;

end %end function






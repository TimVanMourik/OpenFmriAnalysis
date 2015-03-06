function output = tvm_labelFileToVertex(configuration)

memtic
subjectDirectory    = configuration.SubjectDirectory;
numberOfLabels = length(configuration.LabelFiles);

%If configuration.Hemisphere is one string, all labels are located on that
%hemisphere. If it is a cell, consider all labels to be located on the
%hemisphere as indicated. 
if iscell(configuration.Hemisphere)
    hemisphere = cell(size(configuration.Hemisphere));
    for h = 1:length(configuration.Hemisphere)
        switch configuration.Hemisphere{h}
            case 'Right'
                hemisphere{h} = 1;
            case 'Left'
                hemisphere{h} = 2;
        end
    end
else
    switch configuration.Hemisphere
        case 'Right'
            hemisphere = num2cell(ones(numberOfLabels, 1));
        case 'Left'
            hemisphere = num2cell(2 * ones(numberOfLabels, 1));
    end
end

% 2 because there are two hemispheres
verticesOfInterest = cell(numberOfLabels, 2);
%Loops over all Labels{:}
for label = 1:numberOfLabels
    if iscell(configuration.LabelFiles{label})
        v = [];
        for i = 1:length(configuration.LabelFiles{label})
             v = vertcat(v, importLabelFile([subjectDirectory configuration.LabelFiles{label}{i}]));
        end
        verticesOfInterest{label, hemisphere{label}} = unique(v);
    else
        verticesOfInterest{label, hemisphere{label}} = importLabelFile([subjectDirectory configuration.LabelFiles{label}]);
    end
end

save([subjectDirectory configuration.VerticesOfInterest], 'verticesOfInterest');

output = memtoc;

end %end function







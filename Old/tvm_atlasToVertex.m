function output = tvm_atlasToVertex(configuration)

memtic
subjectDirectory    = configuration.SubjectDirectory;
numberOfLabels = length(configuration.InterestLabels);

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

load([subjectDirectory configuration.Boundaries], 'wSurface', 'pSurface');

annotationFilenameLeft  = strrep([subjectDirectory configuration.Atlas], '?', 'l');
annotationFilenameRight = strrep([subjectDirectory configuration.Atlas], '?', 'r');
[~, listLeft, colourTable] = read_annotation(annotationFilenameLeft);
[~, listRight] = read_annotation(annotationFilenameRight);

% 2 because there are two hemispheres
verticesOfInterest = cell(numberOfLabels, 2);
%Loops over all Labels{:}
for label = 1:numberOfLabels
    indices = cell(length(configuration.InterestLabels{label}), 2);
    %Loops over all Labels{label}(:)
    for l = 1:length(configuration.InterestLabels{label})
        if hemisphere{label} == 1
            indices{l, hemisphere{label}} = find(listRight == colourTable.table(configuration.InterestLabels{label}(l), 5));
        elseif hemisphere{label} == 2
            indices{l, hemisphere{label}} = find(listLeft == colourTable.table(configuration.InterestLabels{label}(l), 5));
        else
            error('TVM:tvm_atlasToVertex:WrongHemisphere', '');
        end
    end
    verticesOfInterest{label, hemisphere{label}} = unique(vertcat(indices{:, hemisphere{label}}));

end
clear x y z selectionGrid

save([subjectDirectory configuration.VerticesOfInterest], 'verticesOfInterest');

output = memtoc;

end %end function







function hemispheres = getHemispheres(hemisphereList, labels)

if ~iscell(labels) && ~iscell(hemisphereList)
    %single label: e.g. 'Left'
    switch hemisphereList
        case 'Right'
            hemispheres = 1;
        case 'Left'
            hemispheres = 2;
    end  
    return
end

%label is a cell
if iscell(labels) && iscell(hemisphereList)
    if ~iscell(labels{1}) && ~iscell(hemisphereList{1})
        %e.g. {'Left', 'Left'}
        hemispheres = cell(size(labels));
        for i = 1:size(labels, 1)
            for j = 1:size(labels, 2)
                switch hemisphereList{i, j}
                    case 'Right'
                        hemispheres{i, j} = 1;
                    case 'Left'
                        hemispheres{i, j} = 2;
                end      
            end
        end
        return
    elseif iscell(labels{1}) && iscell(hemisphereList{1})
        %e.g. {{'Left', 'Right'}, {'Left', 'Right'}, {'Left', 'Right'}}
        hemispheres = cell(size(labels));
        for i = 1:length(hemispheres)
            hemispheres{i} = cell(size(size(labels{i})));
        end
        for i = 1:length(hemispheres)
            for j = 1:length(hemispheres{i})
                switch hemisphereList{i}{j}
                    case 'Right'
                        hemispheres{i}{j} = 1;
                    case 'Left'
                        hemispheres{i}{j} = 2;
                end  
            end
        end
        return
    end
end

error('The hemisphere list and the label list are of unequal dimensions');


end %end function



















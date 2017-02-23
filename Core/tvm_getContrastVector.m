function currentContrast = tvm_getContrastVector(contrast, designMatrix, regressorLabels)
% @todo: is designMatrix really necessary as input?
if isnumeric(contrast) %1s, 0s and -1s
    if length(contrast) < size(designMatrix, 2)
        currentContrast =[contrast, zeros(1, size(designMatrix, 2) - length(contrast))];
    end
else %cell array with strings
    currentContrast = zeros(1, size(designMatrix, 2));
    for j = 1:length(contrast)
        if contrast{j}(1) == '-'
            contrast{j} = contrast{j}(2:end);
            sign = -1;
        else
            sign = 1;
        end
%         regressorsOfInterest = find(~cellfun(@isempty, strfind(design.RegressorLabel, contrast{j})));
        regressorsOfInterest = find(strcmp(regressorLabels, contrast{j}));
        currentContrast(regressorsOfInterest) = sign * 1;
        if isempty(regressorsOfInterest)
            warning('Regressors ''%s'' do not exist\n', contrast{j});
            continue;
        end
    end
end
end






function vertices = changeDimensions(vertices, dimensionInitial, dimensionTarget)
%VERTICES = CHANGEDIMENSIONS(VERTICES, DI, DT)

if size(dimensionInitial) ~= size(dimensionTarget)
    error('TVM:changeDimensions:InvalidDimension','The input dimension is invalid')
end

for hemisphere = 1:2
    vertices{hemisphere} = [-vertices{hemisphere}(:, 1) + 1, vertices{hemisphere}(:, 2) + 1, vertices{hemisphere}(:, 3)];
    vertices{hemisphere} = bsxfun(@plus, vertices{hemisphere}, dimensionTarget / 2);
    vertices{hemisphere} = [vertices{hemisphere}, ones(length(vertices{hemisphere}), 1)];
end

end %end function



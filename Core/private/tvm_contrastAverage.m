function c = tvm_contrastAverage(transformation, arrayW, arrayP, voxelGrid, modeSettings, configuration)

%% Parse configuration
pivot =                 tvm_getOption(configuration, 'Pivot', mean(arrayW));
    % mean(arrayW)
reverseContrast =       tvm_getOption(configuration, 'ReverseContrast', false);
    % false
optimisationMethod =    tvm_getOption(configuration, 'OptimisationMethod', 'GreveFischl');

contrastConfiguration = configuration;
%%

%the cost function for fminsearch to determine the contrast value

defaultTransformation = [0, 0, 0, 1, 1, 1, 0, 0, 0];
defaultTransformation(modeSettings) = transformation;
[rx, ry, rz, sx, sy, sz, tx, ty, tz] = deal(defaultTransformation(1), defaultTransformation(2), defaultTransformation(3), defaultTransformation(4), defaultTransformation(5), defaultTransformation(6), defaultTransformation(7), defaultTransformation(8), defaultTransformation(9));

if reverseContrast
    Mv = -1;
else
    Mv = 1;
end

%transforms the mesh, computes the contrast, sums it and gives a scalar measure for the contrast 
contrastValues = findContrast(transformMesh(arrayW, [rx, ry, rz], [sx, sy, sz], [tx, ty, tz], pivot), ...
                              transformMesh(arrayP, [rx, ry, rz], [sx, sy, sz], [tx, ty, tz], pivot), ...
                              voxelGrid, contrastConfiguration);
switch optimisationMethod
    case 'GreveFischl'
        Q0 = 0;
        c = -sum(tanh(Mv * (contrastValues - Q0)));
    case 'sum'
        c = -Mv * sum(contrastValues);
    case 'count'
        c = sum(contrastValues > 0);
    case 'centred'
        contrasts = contrastValues;
        [~, indices] = sort(contrasts);
        indices = indices(round(length(contrasts) * 0.10):round(length(contrasts) * 0.9));
        c = -sum(tanh(Mv * contrasts(indices)));
    otherwise
        Q0 = 0;
        c = -sum(tanh(Mv * (contrastValues - Q0)));
end

end %end function


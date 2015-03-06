function tvm_applyFieldmap(configuration)
%
%
%   Copyright (C) 2015, Tim van Mourik, DCCN

%% Parse configuration
subjectDirectory =      	tvm_getOption(configuration, 'i_SubjectDirectory');
    %no default
fieldMapFile =            	fullfile(subjectDirectory, tvm_getOption(configuration, 'i_FieldMap'));
    %no default
boundariesFileIn =          fullfile(subjectDirectory, tvm_getOption(configuration, 'i_Boundaries'));
    %no default
boundariesFileOut =         fullfile(subjectDirectory, tvm_getOption(configuration, 'o_Boundaries'));
    %no default
    
definitions = tvm_definitions();
%%
load(boundariesFileIn, definitions.WhiteMatterSurface, definitions.PialSurface);
wSurface        = eval(definitions.WhiteMatterSurface);
pSurface        = eval(definitions.PialSurface);

fieldMap = spm_read_vols(spm_vol(fieldMapFile));

%%
configuration.InterpolationMethod = 'Trilinear';
wTemp = cell(size(wSurface));
pTemp = cell(size(pSurface));
for hemisphere = 1:length(wSurface)
    for i = 1:3
        %todo, what to do with Nans?
        wTemp{hemisphere}(:, i) = wSurface{hemisphere}(:, i) + tvm_sampleVoxels(fieldMap(:, :, :, i), wSurface{hemisphere}(:, 1), wSurface{hemisphere}(:, 2), wSurface{hemisphere}(:, 3), configuration);
        pTemp{hemisphere}(:, i) = pSurface{hemisphere}(:, i) + tvm_sampleVoxels(fieldMap(:, :, :, i), pSurface{hemisphere}(:, 1), pSurface{hemisphere}(:, 2), pSurface{hemisphere}(:, 3), configuration);
    end
end
wSurface = wTemp;
pSurface = pTemp;

save(boundariesFileOut, definitions.WhiteMatterSurface, definitions.PialSurface);

end %end function


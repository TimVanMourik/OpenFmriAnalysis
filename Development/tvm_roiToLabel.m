function tvm_roiToLabel(configuration)
% TVM_ROITOLABEL
%   TVM_ROITOLABEL(configuration)
%   
%
%   Copyright (C) Tim van Mourik, 2015, DCCN
%
%   configuration.SubjectDirectory
%   configuration.i_Boundaries
%   configuration.i_ROI
%   configuration.i_Hemisphere
%   configuration.o_LabelFiles
%

%% Parse configuration
subjectDirectory 	= tvm_getOption(configuration, 'i_SubjectDirectory', '.');
    %no default
boundaryFile        = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_Boundaries'));
    %no default
roiFile             = fullfile(subjectDirectory, tvm_getOption(configuration, 'i_ROI'));
    %no default
hemispheres         = tvm_getOption(configuration, 'i_Hemispheres');
    %no default
labelFiles          = fullfile(subjectDirectory, tvm_getOption(configuration, 'o_LabelFiles', []));
    %no default
    
%%
load(boundaryFile, 'wSurface', 'pSurface', 'faceData');

roi = spm_vol(roiFile);
roi.volume = ~~spm_read_vols(roi);    
%dilate it a little bit: if the voxels fall within the cortex, the
%labels aren't selected otherwise.
roi.volume = tvm_dilate3D(roi.volume, 2);

hemisphere = cell(size(hemispheres));
for h = 1:length(hemispheres)
    switch hemispheres{h}
        case 'Right'
            hemisphere = 1;
        case 'Left'
            hemisphere = 2;
    end
    w = round(wSurface{hemisphere});
    insideVolume = all(~bsxfun(@gt, w(:, 1:3), roi.dim), 2) & all(bsxfun(@gt, w(:, 1:3), [0, 0, 0]), 2);
    selected = roi.volume(sub2ind(roi.dim, w(insideVolume, 1), w(insideVolume, 2), w(insideVolume, 3)));
    wIndices = find(insideVolume);
    wIndices = wIndices(selected);
    
    p = round(pSurface{hemisphere});
    insideVolume = all(~bsxfun(@gt, p(:, 1:3), roi.dim), 2) & all(bsxfun(@gt, p(:, 1:3), [0, 0, 0]), 2);
    selected = roi.volume(sub2ind(roi.dim, p(insideVolume, 1), p(insideVolume, 2), p(insideVolume, 3)));
    pIndices = find(insideVolume);
    pIndices = pIndices(selected);
    
    label = unique([wIndices; pIndices]);
    
    tvm_exportFreesurferLabel(labelFiles{h}, label);
end


end %end function







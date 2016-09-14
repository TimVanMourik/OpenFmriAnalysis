function tvm_movieFrom4D(configuration)
% TVM_
%   TVM_(configuration)
%   
%
%   Copyright (C) Tim van Mourik, 2015, DCCN
%

%% Parse configuration
subjectDirectory =      tvm_getOption(configuration, 'i_SubjectDirectory', pwd());
    %no default
volumeFile =            fullfile(subjectDirectory, tvm_getOption(configuration, 'i_VolumeFile'));
    %no default    %no default
iterationAxis =         tvm_getOption(configuration, 'i_Axis', 'transversal');
    % a horizontal slice
fps =                   tvm_getOption(configuration, 'i_FramesPerSecond', 5);
    % 5 frames per second
quality =               tvm_getOption(configuration, 'i_MovieQuality', 80);
    % 80% 
% frameSize =             tvm_getOption(configuration, 'i_MovieSize', [1042, 968]);
    % 
colorLimits =           tvm_getOption(configuration, 'i_ColorLimits', []);
    % 
slice =                 tvm_getOption(configuration, 'i_Slice', 1);
    % 1
contrastSetting =       tvm_getOption(configuration, 'i_Contrast', 1);
    % 1
movieFile =             fullfile(subjectDirectory, tvm_getOption(configuration, 'o_Movie'));
    %no default
    
%%

switch iterationAxis
    case {'x', 'coronal'}
        dimension = 1;
    case {'y', 'sagittal'}
        dimension = 2;
    case {'z', 'transversal', 'transverse', 'horizontal'}
        dimension = 3;
    otherwise
        error('Invalid Axis');
end

for i = 1:length(volumeFile)
    reference = spm_vol(volumeFile{i});
    referenceVolume = spm_read_vols(reference);
    referenceSlice = permute(referenceVolume, [setxor(1:4, dimension), dimension]);
    referenceSlice = referenceSlice(:, :, :, slice);

    numberOfFrames = size(referenceSlice, 3);
    videoObject = VideoWriter(movieFile{i});
    videoObject.Quality = quality;
    videoObject.FrameRate = fps;
    open(videoObject);

    if isempty(colorLimits)
        colorLimits = [min(referenceSlice(:)), max(referenceSlice(:))];
    end

    n = 64;
    colorMap = -contrastSetting:2 * contrastSetting / (n - 1):contrastSetting;
    colorMap = 1 ./ (1 + exp(-colorMap));
    colorMap = (colorMap - colorMap(1)) ./ (colorMap(end) - colorMap(1));
    colorMap = repmat(colorMap, 3, 1)';
    colormap(colorMap);

    visibility = 'off';
    screenSize = get(0, 'ScreenSize');
    for j = 1:numberOfFrames

        overlayImage = figure('Visible', visibility, 'units', 'normalized', 'outerposition', [0, 0, 1, 1]);
        
        subplot('position', [0, 0, 1, 1]);
        axis('equal', 'tight', 'off');
        set(gcf, ...
            'units', 'normalized', ...
            'outerposition', [0, 0, screenSize(4) / screenSize(3), 1]);

        imagesc(referenceSlice(:, :, j), colorLimits);
        colormap('gray');

        %@todo: give the getframe function a rectangle, such that dimensions
        %are guaranteed to be consistent for every frame
        writeVideo(videoObject, getframe(overlayImage));
        close(overlayImage);
    end
    close(videoObject);
end


end %end function










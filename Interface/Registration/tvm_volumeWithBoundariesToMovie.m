function tvm_volumeWithBoundariesToMovie(configuration)
% TVM_VOLUMEWITHBOUNDARIESTOMOVIE(configuration)
%   TVM_VOLUMEWITHBOUNDARIESTOMOVIE(configuration)
%   @todo Add description
%   
%
%   Copyright (C) Tim van Mourik, 2015, DCCN
%
% Input:
%   i_SubjectDirectory
%   i_ReferenceVolume
%   i_Boundaries
%   i_Axis
%   i_FramesPerSecond
%   i_MovieQuality
%   i_ContourColors
%   i_RegionOfInterest
%   i_ColorLimits
%   i_Rotation
%   i_Contrast
% Output:
%   o_RegistrationMovie
%

%% Parse configuration
subjectDirectory =      tvm_getOption(configuration, 'i_SubjectDirectory', pwd());
    % default: current working directory
referenceFile =         fullfile(subjectDirectory, tvm_getOption(configuration, 'i_ReferenceVolume'));
    %no default
boundariesFiles =       fullfile(subjectDirectory, tvm_getOption(configuration, 'i_Boundaries'));
    %no default
iterationAxis =         tvm_getOption(configuration, 'i_Axis', 'transversal');
    % a horizontal slice
fps =                   tvm_getOption(configuration, 'i_FramesPerSecond', 5);
    % 5 frames per second
quality =               tvm_getOption(configuration, 'i_MovieQuality', 80);
    % 80% 
frameSize =             tvm_getOption(configuration, 'i_MovieSize', [1042, 968]);
    % 
contourColours =        tvm_getOption(configuration, 'i_ContourColors', {'y', 'r', 'g', 'b'});
    % default: yellow, red, green, blue
roiFiles =              tvm_getOption(configuration, 'i_RegionOfInterest', []);
    % default: empty
colorLimits =           tvm_getOption(configuration, 'i_ColorLimits', []);
    % default: empty
rotation =              tvm_getOption(configuration, 'i_Rotation', '');
    % default: empty
contrastSetting =       tvm_getOption(configuration, 'i_Contrast', 1);
    % 1
movieFile =             fullfile(subjectDirectory, tvm_getOption(configuration, 'o_RegistrationMovie'));
    %no default
    
%%
if ~iscell(boundariesFiles)
    boundariesFiles = {boundariesFiles};
end

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

reference = spm_vol(referenceFile);
reference.volume = spm_read_vols(reference);

if ~isempty(roiFiles)
    regionOfInterest = [];
    for i = 1:length(roiFiles)
        roi = spm_vol(fullfile(subjectDirectory, roiFiles{i}));
        roi.volume = spm_read_vols(roi);
        if isempty(regionOfInterest)
            regionOfInterest = roi.volume;
        else
            regionOfInterest = regionOfInterest + roi.volume;
        end
    end
else
    regionOfInterest = zeros(reference.dim);
end

numberOfFrames  = reference.dim(dimension);
videoObject = VideoWriter(movieFile);
videoObject.Quality = quality;
videoObject.FrameRate = fps;
open(videoObject);

if isempty(colorLimits)
    colorLimits = [min(reference.volume(:)), max(reference.volume(:))];
end

n = 64;
colorMap = -contrastSetting:2 * contrastSetting / (n - 1):contrastSetting;
colorMap = 1 ./ (1 + exp(-colorMap));
colorMap = (colorMap - colorMap(1)) ./ (colorMap(end) - colorMap(1));
colorMap = repmat(colorMap, 3, 1)';
colormap(colorMap);

configuration = [];
configuration.i_Volume = reference.volume;

variableNames = who('-file', boundariesFiles{1});
if any(strcmp(variableNames, 'vertices')) && any(strcmp(variableNames, 'faceData'))    
    load(boundariesFiles{1}, 'vertices', 'faceData');
    configuration.i_Vertices = cell(length(vertices), 1);
    configuration.i_Faces = cell(length(faceData), 1);
    for i = 1:length(vertices)
        configuration.i_Vertices{i} = vertices(i);
        configuration.i_Faces{i} = faceData(i);
    end
elseif any(strcmp(variableNames, 'wSurface')) && any(strcmp(variableNames, 'pSurface')) && any(strcmp(variableNames, 'faceData'))
    configuration.i_Vertices = cell(2 * length(boundariesFiles), 1);
    configuration.i_Faces = cell(2 * length(boundariesFiles), 1);
   for i = 1:length(boundariesFiles)
        load(boundariesFiles{i}, 'wSurface', 'pSurface', 'faceData');
        configuration.i_Faces{i * 2 - 1} = faceData;
        configuration.i_Vertices{i * 2 - 1} = wSurface;
        configuration.i_Faces{i * 2} = faceData;
        configuration.i_Vertices{i * 2} = pSurface;
    end
end

configuration.i_Rotation = rotation;
configuration.i_Axis = iterationAxis;
configuration.i_Visibility = 'off';
configuration.i_ROI = regionOfInterest;
visibility = 'off';
configuration.i_ColorLimits = colorLimits;
configuration.i_ContourColors = contourColours;
configuration.i_ColorMap = colorMap;

screenSize = get(0, 'ScreenSize');

for i = 1:numberOfFrames
    configuration.i_Slice = i;
    
    overlayImage = figure('Visible', visibility, 'units', 'normalized', 'outerposition', [0, 0, 1, 1]);
    subplot('position', [0, 0, 1, 1]);
    axis('equal', 'tight', 'off');
    set(gcf, ...
        'units', 'normalized', ...
        'outerposition', [0, 0, screenSize(4) / screenSize(3), 1]);
 
    tvm_showObjectContourOnSlice(configuration);
    
    %@todo: sometimes the picture hasn't been drawn before the getframe.
    %Not sure to what extent the drawnow() is a stable fix.
    drawnow();
    writeVideo(videoObject, getframe(overlayImage));
    close(overlayImage);
end
close(videoObject);

end %end function










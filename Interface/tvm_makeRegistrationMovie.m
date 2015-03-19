function tvm_makeRegistrationMovieWithMoreBoundaries(configuration)
% TVM_
%   TVM_(configuration)
%   
%
%   Copyright (C) Tim van Mourik, 2015, DCCN
%

%% Parse configuration
subjectDirectory =      tvm_getOption(configuration, 'i_SubjectDirectory');
    %no default
referenceFile =         fullfile(subjectDirectory, tvm_getOption(configuration, 'i_ReferenceVolume'));
    %no default
boundariesFiles =       fullfile(subjectDirectory, tvm_getOption(configuration, 'i_Boundaries'));
    %no default
movieFile =             fullfile(subjectDirectory, tvm_getOption(configuration, 'o_RegistrationMovie'));
    %no default
iterationAxis =         tvm_getOption(configuration, 'p_Axis', 'transversal');
    % a horizontal slice
fps =                   tvm_getOption(configuration, 'p_FramesPerSecond', 5);
    % 5 frames per second
quality =               tvm_getOption(configuration, 'p_MovieQuality', 80);
    % 80% 
frameSize =             tvm_getOption(configuration, 'p_MovieSize', [1042, 968]);
    % 
contourColours =        tvm_getOption(configuration, 'p_ContourColors', {'y', 'r', 'g', 'b'});
    %no default
colorLimits =           tvm_getOption(configuration, 'p_ColorLimits', []);
    % 
    
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

reference = spm_vol(referenceFile);
reference.volume = spm_read_vols(reference);

numberOfFrames  = reference.dim(dimension);
videoObject = VideoWriter(movieFile);
videoObject.Quality = quality;
videoObject.FrameRate = fps;
open(videoObject);

if isempty(colorLimits)
    colorLimits = [min(reference.volume(:)), max(reference.volume(:))];
end

configuration = [];
configuration.i_Volume = reference.volume;


configuration.i_Vertices = cell(2 * length(boundariesFiles), 1);
configuration.i_Faces = cell(2 * length(boundariesFiles), 1);

for i = 1:length(boundariesFiles)
    load(boundariesFiles{i}, 'wSurface', 'pSurface', 'faceData');
    configuration.i_Faces{i * 2 - 1} = faceData;
    configuration.i_Faces{i * 2} = faceData;
    configuration.i_Vertices{i * 2 - 1} = wSurface;
    configuration.i_Vertices{i * 2} = pSurface;
end

configuration.p_Axis = iterationAxis;
configuration.p_Visibility = 'off';
configuration.p_ColorLimits = colorLimits;
configuration.p_ContourColors = contourColours;

for i = 1:numberOfFrames
    configuration.i_Slice = i;
    overlayImage = tvm_showObjectContourOnSlice(configuration);
    writeVideo(videoObject, getframe(overlayImage));
    close(overlayImage);
end
close(videoObject);

end %end function










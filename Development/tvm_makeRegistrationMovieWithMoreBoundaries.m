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
boundariesFile =        fullfile(subjectDirectory, tvm_getOption(configuration, 'i_Boundaries'));
    %no default
boundariesFileExtra =   fullfile(subjectDirectory, tvm_getOption(configuration, 'i_BoundariesExtra'));
    %no default
movieFile =             fullfile(subjectDirectory, tvm_getOption(configuration, 'o_RegistrationMovie'));
    %no default
iterationAxis =         tvm_getOption(configuration, 'p_Axis', 'transversal');
    % a horizontal slice
fps =                   tvm_getOption(configuration, 'p_FramesPerSecond', 5);
    % 5 frames per second
quality =               tvm_getOption(configuration, 'p_MovieQuality', 80);
    % 80% 
contourColours =        tvm_getOption(configuration, 'p_ContourColors', {'y', 'r', 'g', 'b'});
    %no default
frameSize =             tvm_getOption(configuration, 'p_MovieSize', [1042, 968]);
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

load(boundariesFile, 'wSurface', 'pSurface', 'faceData')
reference = spm_vol(referenceFile);
reference.volume = spm_read_vols(reference);

numberOfFrames  = reference.dim(dimension);
videoObject = VideoWriter(movieFile);
videoObject.Quality = quality;
videoObject.FrameRate = fps;
open(videoObject);

configuration = [];
configuration.i_Volume = reference.volume;
configuration.i_Vertices = cell(2, 1);
configuration.i_Vertices{1} = wSurface;
% configuration.i_Vertices{2} = pSurface;
configuration.i_Faces = faceData;
configuration.p_Axis = iterationAxis;
configuration.p_Visibility = 'off';
configuration.p_ColorLimits = [min(reference.volume(:)), max(reference.volume(:))];
configuration.p_ContourColors = contourColours;

load(boundariesFileExtra, 'wSurface', 'pSurface')
configuration.i_Vertices{3} = wSurface;
configuration.i_Vertices{2} = pSurface;


for i = 1:numberOfFrames
    configuration.i_Slice = i;
    overlayImage = tvm_showObjectContourOnSlice(configuration);
    writeVideo(videoObject, getframe(overlayImage));
    close(overlayImage);
end
close(videoObject);

end %end function










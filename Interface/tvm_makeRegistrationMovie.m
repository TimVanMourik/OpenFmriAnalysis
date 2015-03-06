function tvm_makeRegistrationMovie(configuration)
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
movieFile =             fullfile(subjectDirectory, tvm_getOption(configuration, 'o_RegistrationMovie'));
    %no default
iterationAxis =         tvm_getOption(configuration, 'p_Axis', 'transversal');
    %no default
fps =                   tvm_getOption(configuration, 'p_FramesPerSecond', 5);
    %no default
    
definitions = tvm_definitions();    
%%

load(boundariesFile, definitions.WhiteMatterSurface, definitions.PialSurface, definitions.FaceData);
wSurface = eval(definitions.WhiteMatterSurface);
pSurface = eval(definitions.PialSurface);
faceData = eval(definitions.FaceData);

reference = spm_vol(referenceFile);
reference.volume = spm_read_vols(reference);

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

numberOfFrames  = reference.dim(dimension);
videoObject = VideoWriter(movieFile);
videoObject.Quality = 100;
videoObject.FrameRate = fps;
open(videoObject);

configuration = [];
configuration.i_Volume = reference.volume;
configuration.i_Vertices = cell(2, 1);
configuration.i_Vertices{1} = wSurface;
configuration.i_Vertices{2} = pSurface;
configuration.i_Faces = faceData;
configuration.p_Axis = iterationAxis;
configuration.p_Visibility = 'off';
configuration.p_ColorLimits = [min(reference.volume(:)), max(reference.volume(:))];

for i = 1:numberOfFrames
    configuration.i_Slice = i;
    overlayImage = tvm_showObjectContourOnSlice(configuration);
    writeVideo(videoObject, getframe(overlayImage));
    close(overlayImage);
end
close(videoObject);

end %end function










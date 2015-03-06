function varargout = loadFreeSurferAsciiFile(fileNames)
%LOADFREESURFERASCIIFILE(DATAFILENAMES)
%Loads FreeSurfer output
%
%Example: 
%   fileNames = []
%   fileNames.SurfaceWhite     = '?h.white.asc';
%   fileNames.SurfacePial      = '?h.pial.asc';
%   fileNames.CurvatureWhite   = '?h.curv.asc';
%   fileNames.CurvaturePial    = '?h.curv.pial.asc';
%   fileNames.Thickness        = '?h.thickness.asc';
%   fileNames.Neighbours       = '?h.neighbours.asc';
%   [W, P, CW, CP, T, N] = loadFreeSurferAsciiFile(fileNames);
%
% The core of this function was written by Peter Koopmans and was later
% modified by Tim van Mourik


%The number of vertices will be set in the surface white part. For that
%reason this function (for now) will crash when the surface white is not an
%input.
if ~isfield(fileNames, 'SurfaceWhite')
    error('TVM:loadFreeSurferAsciiFile:NoWhiteMatterSurface', 'A white matter surface must be specified');
end
numberOfVerticesRight = 0;
numberOfVerticesLeft = 0;

if isfield(fileNames, 'SurfaceWhite')
    %right hemisphere:
    tmp = strrep(fileNames.SurfaceWhite, '?', 'r');
    tmp = importdata(tmp);
    numberOfVerticesRight = tmp.data(1, 1);
    tmp.data(1, :)= [];
    %delete all faces
    tmp = [tmp.data(1:2:2 * numberOfVerticesRight, :),    tmp.data(2:2:2 * numberOfVerticesRight, 1)];
    W{1} = tmp(:, 1:3); 
    %left hemisphere:
    tmp = strrep(fileNames.SurfaceWhite, '?', 'l');
    tmp = importdata(tmp);
    numberOfVerticesLeft = tmp.data(1, 1);
    tmp.data(1, :)= [];
    %delete all faces
    tmp = [tmp.data(1:2:2 * numberOfVerticesLeft, :),     tmp.data(2:2:2 * numberOfVerticesLeft, 1)];
    W{2} = tmp(:, 1:3); 
    varargout{1} = W;
end

if isfield(fileNames, 'SurfacePial')
    %right hemisphere:
    tmp = strrep(fileNames.SurfacePial, '?', 'r');
    tmp = importdata(tmp);
    numberOfVerticesRight = tmp.data(1, 1);
    tmp.data(1,:)=[];
    %delete all faces
    tmp = [tmp.data(1:2:2 * numberOfVerticesRight, :),    tmp.data(2:2:2 * numberOfVerticesRight, 1)];
    P{1} = tmp(:, 1:3); 
    %left hemisphere:    
    tmp = strrep(fileNames.SurfacePial, '?', 'l');
    tmp = importdata(tmp);
    numberOfVerticesLeft = tmp.data(1, 1);
    tmp.data(1, :) = [];
    %delete all faces
    tmp = [tmp.data(1:2:2 * numberOfVerticesLeft, :),     tmp.data(2:2:2 * numberOfVerticesLeft, 1)];
    P{2} = tmp(:, 1:3);
    varargout{2} = P;
end

if isfield(fileNames, 'CurvatureWhite')
    tmp = strrep(fileNames.CurvatureWhite, '?', 'r');
    tmp = importdata(tmp);
    CW{1} = tmp(:, 5);
    tmp = strrep(fileNames.CurvatureWhite, '?', 'l');
    tmp = importdata(tmp);
    CW{2} = tmp(:, 5); 
    varargout{3} = CW;
end
if isfield(fileNames, 'CurvaturePial')
    tmp = strrep(fileNames.CurvaturePial, '?', 'r');
    tmp = importdata(tmp);
    CP{1} = tmp(:, 5);
    tmp = strrep(fileNames.CurvaturePial, '?', 'l');
    tmp = importdata(tmp);
    CP{2} = tmp(:, 5);
    varargout{4} = CP;
end
if isfield(fileNames, 'Thickness')   
    tmp = strrep(fileNames.Thickness, '?', 'r');
    tmp = importdata(tmp);
    T{1} = tmp(:, 5);
    tmp = strrep(fileNames.Thickness, '?', 'l');
    tmp = importdata(tmp);
    T{2} = tmp(:, 5);
    varargout{5} = T;
end
if isfield(fileNames, 'Neighbours')    
    N{1} = cell(numberOfVerticesRight, 1);
    N{2} = cell(numberOfVerticesLeft,  1);
    tmp = strrep(fileNames.Neighbours, '?', 'r');
    fid = fopen(tmp, 'r');
    for k=1:numberOfVerticesRight
        tmp = str2num(fgetl(fid)); %#ok<*ST2NM>
        N{1}{k}(1 )= tmp(2);
        N{1}{k}(2:1 + tmp(2)) = tmp(3:2 + tmp(2)) + 1; % +1 because FreeSurfer numbering starts at 0
    end
    fclose(fid);
    tmp = strrep(fileNames.Neighbours, '?', 'l');
    fid = fopen(tmp, 'r');
    for k = 1:numberOfVerticesLeft
        tmp = str2num(fgetl(fid));
        N{2}{k}(1) = tmp(2);
        N{2}{k}(2:1 + tmp(2)) = tmp(3:2 + tmp(2)) + 1; % +1 because FreeSurfer numbering starts at 0
    end
    fclose(fid);
    varargout{6} = N;
end
    
end %end function




function outputData = tvm_loadFreeSurferAsciiFile(fileNames)
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
%   Copyright (C) Tim van Mourik, 2014, DCCN
%   Major adaption (C) Tim van Mourik, 2015, DCCN

if isfield(fileNames, 'SurfaceWhite')
   %right hemisphere:
    fileName = strrep(fileNames.SurfaceWhite, '?', 'r');
    fileName = convertToAscii(fileName);
    
    [vertices, faces] = tvm_importFreesurferSurfaceData(fileName);
    F{1} = faces;
    W{1} = vertices;
    
   %left hemisphere:
    fileName = strrep(fileNames.SurfaceWhite, '?', 'l');
    fileName = convertToAscii(fileName);    
    
    [vertices, faces] = tvm_importFreesurferSurfaceData(fileName);
    F{2} = faces;
    W{2} = vertices;
    
    %assign to output
    outputData.SurfaceWhite = W;
    outputData.Faces = F;
end

if isfield(fileNames, 'SurfacePial')
   %right hemisphere:
    fileName = strrep(fileNames.SurfacePial, '?', 'r');
    fileName = convertToAscii(fileName);
    
    [vertices, faces] = tvm_importFreesurferSurfaceData(fileName);
    F{1} = faces;
    P{1} = vertices;
    
   %left hemisphere:
    fileName = strrep(fileNames.SurfacePial, '?', 'l');
    fileName = convertToAscii(fileName);    
    
    [vertices, faces] = tvm_importFreesurferSurfaceData(fileName);
    F{2} = faces;
    P{2} = vertices;
    
    %assign to output
    outputData.SurfacePial = P;
    outputData.Faces = F;
end

if isfield(fileNames, 'CurvatureWhite')
    fileName = strrep(fileNames.CurvatureWhite, '?', 'r');
    fileName = convertToAscii(fileName);
    surfaceData = importdata(fileName);
    CW{1} = surfaceData(:, 5);
    fileName = strrep(fileNames.CurvatureWhite, '?', 'l');
    fileName = convertToAscii(fileName);
    surfaceData = importdata(fileName);
    CW{2} = surfaceData(:, 5); 
    outputData.CurvatureWhite = CW;
end
if isfield(fileNames, 'CurvaturePial')
    fileName = strrep(fileNames.CurvaturePial, '?', 'r');
    fileName = convertToAscii(fileName);
    surfaceData = importdata(fileName);
    CP{1} = surfaceData(:, 5);
    fileName = strrep(fileNames.CurvaturePial, '?', 'l');
    fileName = convertToAscii(fileName);
    surfaceData = importdata(fileName);
    CP{2} = surfaceData(:, 5);
    outputData.CurvaturePial = CP;
end
if isfield(fileNames, 'Thickness')   
    fileName = strrep(fileNames.Thickness, '?', 'r');
    fileName = convertToAscii(fileName);
    surfaceData = importdata(fileName);
    T{1} = surfaceData(:, 5);
    fileName = strrep(fileNames.Thickness, '?', 'l');
    fileName = convertToAscii(fileName);
    surfaceData = importdata(fileName);
    T{2} = surfaceData(:, 5);
    outputData.Thickness = T;
end
if isfield(fileNames, 'Neighbours')    
    surfaceData = strrep(fileNames.Neighbours, '?', 'r');
    fid = fopen(surfaceData, 'r');
    k = 1;
    while ~feof(fid)
        surfaceData = str2num(fgetl(fid)); %#ok<*ST2NM>
        N{1}{k}(1 )= surfaceData(2);
        N{1}{k}(2:1 + surfaceData(2)) = surfaceData(3:2 + surfaceData(2)) + 1; % +1 because FreeSurfer numbering starts at 0
        k = k + 1;
    end
    fclose(fid);
    fileName = strrep(fileNames.Neighbours, '?', 'l');
    fid = fopen(fileName, 'r');
    k = 1;
    while ~feof(fid)
        surfaceData = str2num(fgetl(fid)); %#ok<*ST2NM>
        N{2}{k}(1 )= surfaceData(2);
        N{2}{k}(2:1 + surfaceData(2)) = surfaceData(3:2 + surfaceData(2)) + 1; % +1 because FreeSurfer numbering starts at 0
        k = k + 1;
    end
    fclose(fid);
    N{1} = N{1}(:); 
    N{2} = N{2}(:); 
    outputData.Neighbours = N;
end
    
end %end function


function fileName = convertToAscii(fileName)

if length(fileName) < 4
    return;
end

if strcmp(fileName(end - 3:end), '.asc')
    return;
end

unix(['mris_convert ' fileName ' ' fileName '.asc;']);
fileName = [fileName '.asc'];

end %end function









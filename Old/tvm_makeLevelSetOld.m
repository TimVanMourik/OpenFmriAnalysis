function output = tvm_makeLevelSet(configuration)

memtic
%Load the volume data
subjectDirectory = configuration.SubjectDirectory;

load([subjectDirectory configuration.Boundaries]);

for hemisphere = 1:2
%1 = right
    if hemisphere == 1
        inputFileName = strrep([subjectDirectory configuration.SurfaceWhite], '?', 'r');
%         outputFileName = strrep([subjectDirectory configuration.ObjWhite], '?', 'r');
    elseif hemisphere == 2
        inputFileName = strrep([subjectDirectory configuration.SurfaceWhite], '?', 'l');
%         outputFileName = strrep([subjectDirectory configuration.ObjWhite], '?', 'l');
    else
            %crash
    end
    %import the ascii file
    objData = importdata(inputFileName);
    %The first row contains the number of vertices (1) and faces (2)
    description = objData.data(1, :);
    %Remove the first line
    objData.data(1, :) = [];
    %The 2-column data should be trandformed to 4-column data
    firstHalf = objData.data(1:2:sum(description * 2), :);
    secondHalf = objData.data(2:2:sum(description * 2), :);
    objData.data = [firstHalf secondHalf];
    objData.data(1:description(1), 1:3) = wSurface{1}(1:description(1), 1:3);

    tri = 1 + objData.data((description(1) + 1):(description(1) + description(2)), 1:3);
    x = objData.data(1:description(1), 1:3);
    origin = [0, 0, 0];
    dx = 1;
    ni = 204;
    nj = 204;
    nk = 96;
    exact_band = -1;
    tic
    phi = makeLevelSet(tri, x, origin, dx, ni, nj, nk, exact_band);
    toc
    
    if hemisphere == 1
        inputFileName = strrep([subjectDirectory configuration.SurfacePial], '?', 'r');
%         outputFileName = strrep([subjectDirectory configuration.ObjPial], '?', 'r');
    elseif hemisphere == 2
        inputFileName = strrep([subjectDirectory configuration.SurfacePial], '?', 'l');
%         outputFileName = strrep([subjectDirectory configuration.ObjPial], '?', 'l');
    else
    end
    %import the ascii file
    objData = importdata(inputFileName);
    %The first row contains the number of vertices (1) and faces (2)
    description = objData.data(1, :);
    %Remove the first line
    objData.data(1, :) = [];
    %The 2-column data should be trandformed to 4-column data
    firstHalf = objData.data(1:2:sum(description * 2), :);
    secondHalf = objData.data(2:2:sum(description * 2), :);
    objData.data = [firstHalf secondHalf];
    objData.data(1:description(1), 1:3) = pSurface{1}(1:description(1), 1:3);
    
    outputFile = fopen(outputFileName, 'w');
    %print number of vertices / faces
    fprintf(outputFile, '%3d\t%3d\n', description);
    %print vertices
    fprintf(outputFile, 'v %f\t%f\t%f\n', objData.data(1:description(1), 1:3));
    %print faces
    fprintf(outputFile, 'f %3d\t%3d\t%3d\n', 1 + objData.data((description(1) + 1):(description(1) + description(2)), 1:3));
    %close the file
    fclose(outputFile);
end  

output = memtoc;

end %end function
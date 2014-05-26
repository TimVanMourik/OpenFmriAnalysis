function output = tvm_boundariesToObj(configuration)
%
%
% make sure the boundary information is stored as 'wSurface' and 'pSurface'


memtic
%Load the volume data
subjectDirectory = configuration.SubjectDirectory;

load([subjectDirectory configuration.Boundaries]);

for hemisphere = 1:2
%1 = right
    if hemisphere == 1
        inputFileName = strrep([subjectDirectory configuration.SurfaceWhite], '?', 'r');
        outputFileName = strrep([subjectDirectory configuration.ObjWhite], '?', 'r');
    elseif hemisphere == 2
        inputFileName = strrep([subjectDirectory configuration.SurfaceWhite], '?', 'l');
        outputFileName = strrep([subjectDirectory configuration.ObjWhite], '?', 'l');
    else
        %crash
    end
    unix(['fs2obj ' inputFileName ' ' inputFileName '.obj']);
    unix(['mris_convert ' inputFileName ' ' inputFileName '.asc']);
    inputFileName = [inputFileName '.asc'];
    
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
    %minus 1 in order to compensate for the shifting from zero-indexing to
    %one-indexing
    objData.data(1:description(1), 1:3) = wSurface{hemisphere}(1:description(1), 1:3) - 1;
    
    objData.data = objData.data';

    outputFile = fopen(outputFileName, 'w');
    %print vertices
    fprintf(outputFile, 'v %f\t%f\t%f\n', objData.data(1:3, 1:description(1)));
    %print faces, plus one, because the ascii is zero-indexed and the obj
    %is one-indexed
    fprintf(outputFile, 'f %3d\t%3d\t%3d\n', 1 + objData.data(1:3, (description(1) + 1):(description(1) + description(2))));
    %close the file
    fclose(outputFile);

    if hemisphere == 1
        inputFileName = strrep([subjectDirectory configuration.SurfacePial], '?', 'r');
        outputFileName = strrep([subjectDirectory configuration.ObjPial], '?', 'r');
    elseif hemisphere == 2
        inputFileName = strrep([subjectDirectory configuration.SurfacePial], '?', 'l');
        outputFileName = strrep([subjectDirectory configuration.ObjPial], '?', 'l');
    else
        %crash
    end
    unix(['fs2obj ' inputFileName ' ' inputFileName '.obj']);
    unix(['mris_convert ' inputFileName ' ' inputFileName '.asc']);
    inputFileName = [inputFileName '.asc'];
    
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
    %minus 1 in order to compensate for the shifting from zero-indexing to
    %one-indexing
    objData.data(1:description(1), 1:3) = pSurface{hemisphere}(1:description(1), 1:3) - 1;
    objData.data = objData.data';
    
    outputFile = fopen(outputFileName, 'w');
    %print vertices
    fprintf(outputFile, 'v %f\t%f\t%f\n', objData.data(1:3, 1:description(1)));
    %print faces, plus one, because the ascii is zero-indexed and the obj
    %is one-indexed
    fprintf(outputFile, 'f %3d\t%3d\t%3d\n', 1 + objData.data(1:3, (description(1) + 1):(description(1) + description(2))));
    %close the file
    fclose(outputFile);
end  

output = memtoc;

end %end function
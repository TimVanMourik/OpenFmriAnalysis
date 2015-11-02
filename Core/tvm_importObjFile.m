function [vertices, faces] = tvm_importObjFile(fileName)
% this is extremely fast but will crash when there are #-comments in the
% file other than on top. Similarly it won't like vertex normals. 

f = fopen(fileName);
while true
    line = fgetl(f);
    if ~strcmp(line(1), '#')
        %ignore and rewind by 1
        fseek(f, -(length(line) + 1), 0);
        break
    end
end
objData = textscan(f, '%c %f %f %f') ;
fclose(f);

whatLine = [objData{1}];
vertexLines = whatLine == 'v';
faceLines = whatLine == 'f';

vertices = zeros(sum(vertexLines), 3);
vertices(:, 1) = objData{2}(vertexLines);
vertices(:, 2) = objData{3}(vertexLines);
vertices(:, 3) = objData{4}(vertexLines);

faces = zeros(sum(faceLines), 3);
faces(:, 1) = objData{2}(faceLines);
faces(:, 2) = objData{3}(faceLines);
faces(:, 3) = objData{4}(faceLines);

end %end function







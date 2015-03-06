function [vertices, faces] = tvm_importFreesurferSurfaceData(fileName)

f = fopen(fileName);

while true
    line = fgetl(f);
    if ~strcmp(line(1), '#')
        %the first numbers after the commetn block should be the number of
        %vertices and faces
        numbers = sscanf(line, '%d %d');
        numberOfVertices = numbers(1);
        numberOfFaces = numbers(2);
        break
    end
end
vertices = textscan(f, '%f %f %f %f', numberOfVertices);
vertices = [vertices{1}, vertices{2}, vertices{3}];
vertices(:, 4) = 1;
faces = textscan(f, '%d %d %d %d', numberOfFaces);
faces = [faces{1}, faces{2}, faces{3}] + 1;

fclose(f);

end %end function









function labels = tvm_importFreesurferLabel(fileName)

f = fopen(fileName);

while true
    line = fgetl(f);
    if ~strcmp(line(1), '#')
        %the first numbers after the commetn block should be the number of
        %vertices and faces
        numberOfVertices = sscanf(line, '%d');
        break
    end
end

labels = textscan(f, '%d %f %f %f %f', numberOfVertices);
labels = labels{1} + 1;

fclose(f);

end %end function









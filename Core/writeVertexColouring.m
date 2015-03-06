function writeVertexColouring(data, fileName)

f = fopen(fileName, 'w');
fprintf(f, 'Variable\n');
fprintf(f, '%g\n', data);
fclose(f);

end %end function
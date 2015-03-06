function labels = importLabelFile(fileName)

labelFile = importdata(fileName);
%plus one because MATLAB starts counting at one, but FreeSurfer starts at
%zero
labels = labelFile.data(2:5:length(labelFile.data)) + 1;

end %end function




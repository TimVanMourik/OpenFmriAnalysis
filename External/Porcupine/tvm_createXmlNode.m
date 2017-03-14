function tvm_createXmlNode(categories, filename, inputFields, outputFields, saveLocation)

[~, file, ~] = fileparts(filename);

docNode = com.mathworks.xml.XMLUtils.createDocument('node');
docRoot = docNode.getDocumentElement();

category = docRoot; 
for i = 1:length(categories)
    currentNode = docNode.createElement('category');
    currentNode.setAttribute('name', categories(i));
    category.appendChild(currentNode);
    category = currentNode;
end

currentNode = docNode.createElement('title');
currentNode.setAttribute('name', file);
codeBlock = tvm_addCodeBlock(docNode, 'MATLAB', file, '');
currentNode.appendChild(codeBlock);
docRoot.appendChild(currentNode);

for i = 1:length(inputFields)
    currentNode = docNode.createElement('input-output');
    currentNode.setAttribute('name', inputFields(i));
    codeBlock = tvm_addCodeBlock(docNode, 'MATLAB', inputFields{i}, '');
    currentNode.appendChild(codeBlock);
    docRoot.appendChild(currentNode);
end

for i = 1:length(outputFields)
    currentNode = docNode.createElement('output');
    currentNode.setAttribute('name', outputFields(i));
    codeBlock = tvm_addCodeBlock(docNode, 'MATLAB', outputFields{i}, '');
    currentNode.appendChild(codeBlock);
    docRoot.appendChild(currentNode);
end

xmlFileName = fullfile(saveLocation, [file,'.node']);
xmlwrite(xmlFileName, docNode);
% type(xmlFileName);

end %end function














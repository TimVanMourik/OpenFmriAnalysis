
%% Node Files
toolboxLocation = '/home/mrphys/timvmou/MATLAB/Toolboxes/LaminarAnalysis';
cd(fullfile(toolboxLocation, 'Interface'));
saveLocation = fullfile(toolboxLocation, 'External/Porcupine/Nodes');

%
directories = dir();
directories = directories(3:end);
files = cell(0);
nF = 1;
for i = 1:length(directories)
    filenames = dir(fullfile(directories(i).name, 'tvm_*'));
    for j = 1:length(filenames)
        inputFields  = cell(0);
        outputFields = cell(0);
        nI = 1;
        nO = 1;
        
        file = fullfile(directories(i).name, filenames(j).name);
        f = fopen(file);
        while true
            line = fgetl(f);
            if strfind(line, '%') ~= 1
                break;
            elseif strfind(line, '%   i_') == 1
                inputFields(nI) = {line(5:end)};
                nI = nI + 1;
            elseif strfind(line, '%   o_') == 1
                outputFields(nO) = {line(5:end)};
                nO = nO + 1;
            end
        end
        fclose(f);
        
        tvm_createXmlNode({'TVM', directories(i).name}, filenames(j).name, inputFields, outputFields, saveLocation);
        files(nF) = {filenames(j).name};
        nF = nF + 1;
    end
end

%% Resource File
saveLocation = fullfile(toolboxLocation, 'External/Porcupine/');

docNode = com.mathworks.xml.XMLUtils.createDocument('RCC');
docRoot = docNode.getDocumentElement();

%
currentNode = docNode.createElement('qresource');
currentNode.setAttribute('prefix', '/');

fileNode = docNode.createElement('file');
fileNode.setAttribute('alias', 'node_schema.xsd');
fileNode.appendChild(docNode.createTextNode('node.xsd'));
currentNode.appendChild(fileNode);

fileNode = docNode.createElement('file');
fileNode.setAttribute('alias', 'datatype_schema.xsd');
fileNode.appendChild(docNode.createTextNode('datatype.xsd'));
currentNode.appendChild(fileNode);

docRoot.appendChild(currentNode);

%
currentNode = docNode.createElement('qresource');
currentNode.setAttribute('prefix', '/Images');

fileNode = docNode.createElement('file');
fileNode.setAttribute('alias', 'RepeatingBrains.png');
fileNode.appendChild(docNode.createTextNode('Images/RepeatingBrains.png'));
currentNode.appendChild(fileNode);
docRoot.appendChild(currentNode);

%
directory = 'Dictionaries/tvm_nodes';
currentNode = docNode.createElement('qresource');
currentNode.setAttribute('prefix', directory);

for i = 1:length(files)
    fileNode = docNode.createElement('file');
    fileNode.setAttribute('alias', sprintf('node_%02d.xml', i - 1));
    
    [~, file, ~] = fileparts(files{i});
    fileNode.appendChild(docNode.createTextNode(fullfile(directory, [file, '.node'])));
    currentNode.appendChild(fileNode);
end
docRoot.appendChild(currentNode);

xmlFileName = fullfile(saveLocation, 'resourcesTvM.qrc');
xmlwrite(xmlFileName, docNode);
type(xmlFileName);















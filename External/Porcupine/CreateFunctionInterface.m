
%% Node Files
toolboxLocation = '/home/mrphys/timvmou/matlab/Toolboxes/OpenFmriAnalysis';
cd(fullfile(toolboxLocation, 'Interface'));
saveLocation = fullfile(toolboxLocation, 'GIRAFFE');

%
categoryName = 'TvM';
directories = dir();
directories = directories([directories(:).isdir]);
directories = directories(3:end);

categories = cell(1, length(directories));
for i = 1:length(directories)
    filenames = dir(fullfile(directories(i).name, 'tvm_*'));
    nodes = cell(1, length(filenames));
    for j = 1:length(filenames)
        node = [];
        file = fullfile(directories(i).name, filenames(j).name);
        f = fopen(file);
        numberOfPorts = 0;
        ports = [];
        while true
            line = fgetl(f);
            if strfind(line, '%') ~= 1
                break;
            elseif strfind(line, '%   i_') == 1
                numberOfPorts = numberOfPorts + 1;
                ports(numberOfPorts).input = true;
                ports(numberOfPorts).output = true;
                ports(numberOfPorts).visible = true;
                ports(numberOfPorts).editable = true;
                ports(numberOfPorts).name = line(5:end);
                code = [];
                code.language = categoryName;
                code.argument.name = line(5:end);
                ports(numberOfPorts).code = {code};
                
            elseif strfind(line, '%   o_') == 1
                numberOfPorts = numberOfPorts + 1;
                ports(numberOfPorts).input = false;
                ports(numberOfPorts).output = true;
                ports(numberOfPorts).visible = true;
                ports(numberOfPorts).editable = true;
                ports(numberOfPorts).name = line(5:end);
                code = [];
                code.language = categoryName;
                code.argument.name = line(5:end);
                ports(numberOfPorts).code = {code};
            end
                
        end
        fclose(f);
        code = [];
        code.language = categoryName;
        code.comment  = '';
        code.argument.name = filenames(j).name(1:end - 2);

        node.toolbox = categoryName;
        node.category = {categoryName, directories(i).name};
        node.name = filenames(j).name(1:end - 2);
        node.code = {code};
        node.web_url = ['https://github.com/TimVanMourik/OpenFmriAnalysis/tree/master/Interface/', directories(i).name];
        node.ports = ports;
        
        nodes{j} = node;
    end
    category = [];
    category.name = directories(i).name;
    category.nodes = nodes;
    
    index = 1 + i / length(directories);
    r = floor(sin(pi * index + 0         ) * 63 + 128);
    g = floor(sin(pi * index + 2 * pi / 3) * 63 + 128);
    b = floor(sin(pi * index + 4 * pi / 3) * 63 + 128);
    category.colour = ['#', sprintf('%02X', [r, g, b])];
    categories{i} = category;
end

toolbox = [];
tvm = [];
tvm.name = categoryName;
tvm.categories = categories;

%%
f = fopen(fullfile(saveLocation, 'tvm_nodes.json'), 'w');
options.ParseLogical = true;
options.Compact = true;
fwrite(f, savejson('toolboxes', {tvm}, options));
fclose(f);








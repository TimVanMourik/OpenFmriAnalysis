
%% Node Files
toolboxLocation = '/home/mrphys/timvmou/MATLAB/Toolboxes/OpenFmriAnalysis';
cd(fullfile(toolboxLocation, 'Interface'));
saveLocation = fullfile(toolboxLocation, 'External/Porcupine');

%
categoryName = 'TvM';
directories = dir();
directories = directories([directories(:).isdir]);
directories = directories(3:end);

nF = 1;
nodes = [];
for i = 1:length(directories)
    filenames = dir(fullfile(directories(i).name, 'tvm_*'));
    for j = 1:length(filenames)
        
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
        title = [];
        title.web_url = ['https://github.com/TimVanMourik/OpenFmriAnalysis/tree/master/Interface/', directories(i).name];
        title.name = filenames(j).name(1:end - 2);
        title.code = [];
        code = [];
        code.language = categoryName;
        code.comment  = '';
        code.argument.name = filenames(j).name(1:end - 2);
        title.code = {code};
        nodes(nF).category = {categoryName, directories(i).name};
        nodes(nF).title = title;
        nodes(nF).ports = ports;
        
        nF = nF + 1;
    end
end

%%
f = fopen(fullfile(saveLocation, 'tvm.JSON'), 'w');
options.ParseLogical = true;
fwrite(f, savejson('nodes', nodes, options));
fclose(f);








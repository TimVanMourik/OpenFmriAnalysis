function tvm_makeDirectory(folder)
    if exist(folder, 'dir') ~= 7
        mkdir(folder);
    end
end
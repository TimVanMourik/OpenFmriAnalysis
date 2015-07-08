error
showOutput = true;
saveOutput = false;
%% Move to the current directory
%This only works when the whole file is executed, not when just this block
%is executed
rootDirectory = mfilename('fullpath');
rootDirectory = rootDirectory(1:end - length(mfilename()));
cd([rootDirectory '/Functions']);
path(pwd, path);
cd(rootDirectory);

%%
mprage = spm_vol('Volumes/MPRAGE.img');
mprage.volume = spm_read_vols(mprage);
load('Boundaries/Boundaries.mat', 'W', 'P');
mprage.W = W;
mprage.P = P;
%% Translate the mesh to see if the correct transformation can be retrieved
translation = [1        0       0       0;
               0        1       0       0;
               0        0       1       0;
               2        -1.6   0.5     1];
for hemisphere = 1:2
    mprage.W{hemisphere} = mprage.W{hemisphere} * translation;
    mprage.P{hemisphere} = mprage.P{hemisphere} * translation;
end
%% Show and save a slice with the original boundaries
slicePercentage = 50;
if showOutput
    showSlice(mprage.volume, round(slicePercentage / 100 * size(mprage.volume, 3)), mprage.W, mprage.P);  
    if saveOutput
        saveas(gca, [rootDirectory 'Images/MPRAGE_original.png']);
        saveas(gca, [rootDirectory 'Images/MPRAGE_original.fig']);
    end
end

%%
bbrConfiguration = [];
bbrConfiguration.ReverseContrast    = false;
bbrConfiguration.ContrastMethod     = 'gradient';
bbrConfiguration.OptimisationMethod = 'sum';
bbrConfiguration.Mode               = 't';
bbrConfiguration.Display            = 'on';
bbrConfiguration.Stages             = '12345';
bbrConfiguration.Accuracy           = 30;
for hemisphere = 1:2            
    T = boundaryBasedRegistration(mprage.W{hemisphere}, mprage.P{hemisphere}, mprage.volume, bbrConfiguration);
    mprage.WBbr{hemisphere} = mprage.W{hemisphere} * T;
    mprage.PBbr{hemisphere} = mprage.P{hemisphere} * T;
end
WBbr = mprage.WBbr{hemisphere};
PBbr = mprage.PBbr{hemisphere};  
save('Boundaries/Registered Boundaries', 'WBbr', 'PBbr')

%% Show and save a slice with the original boundaries
slicePercentage = 50;
if showOutput
    showSlice(mprage.volume, round(slicePercentage / 100 * size(mprage.volume, 3)), mprage.WBbr, mprage.PBbr);  
    if saveOutput
        saveas(gca, [rootDirectory 'Images/MPRAGE_BBR.png']);
        saveas(gca, [rootDirectory 'Images/MPRAGE_BBR.fig']);
    end
end






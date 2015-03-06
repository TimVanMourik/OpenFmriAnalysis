function output = tvm_melodic(configuration)

memtic

subjectDirectory = configuration.SubjectDirectory;
% folder = [subjectDirectory configuration.ICA];
% if exist(folder, 'dir') == 7
%     unix(['rm -r ' folder]);
% end
% unix(sprintf('melodic -i %s -o %s --nomask --nobet -d %d --Ostats', [subjectDirectory configuration.VertexInformation '.gz'], [subjectDirectory configuration.ICA], configuration.NumberOfComponents));

% unix(['gunzip ' subjectDirectory configuration.ICA '/melodic_IC.nii.gz']);
% components = spm_vol([subjectDirectory configuration.ICA '/melodic_IC.nii']);
% 
% for component = 1:configuration.NumberOfComponents
%     components(component).volume = spm_read_vols(components(component));
% end
% 
% load([subjectDirectory configuration.Profiles], 'profiles');
% 
% for component = 1:configuration.NumberOfComponents
%     intensity = components(component).volume(:);
%     intensity = (intensity - min(intensity)) / (max(intensity) - min(intensity));
%     
%     
%     writeVertexColouring(intensity(1:length(profiles{1})), sprintf('%s%s%s%02d%s', subjectDirectory, configuration.Blender, '/component', component, '.rh.asc'));
%     writeVertexColouring(intensity(length(profiles{1})+1:length(profiles{1}) + length(profiles{2})), sprintf('%s%s%s%02d%s', subjectDirectory, configuration.Blender, '/component', component, '.lh.asc'));
% end

load([subjectDirectory configuration.Profiles], 'profiles');

for component = 1:configuration.NumberOfComponents
    fileName = sprintf('%s%s%s%d%s', subjectDirectory, configuration.ICA, '/stats/thresh_zstat', component, '.nii');
    if exist([fileName '.gz'], 'file')
        unix(['gunzip ' fileName '.gz']);
    end
    icaComponent = spm_vol(fileName);
    icaComponent.volume = spm_read_vols(icaComponent);

    intensity = icaComponent.volume(:);
    
    maxNegative = max(intensity(intensity < 0));
    minNegative = min(intensity(intensity < 0));
    intensity(intensity < 0) = -(intensity(intensity < 0) - minNegative) / (maxNegative - minNegative);
    
    maxPositive = max(intensity(intensity > 0));
    minPositive = min(intensity(intensity > 0));
    intensity(intensity > 0) = (intensity(intensity > 0) - minPositive) / (maxPositive - minPositive);
    
    writeVertexColouring(intensity(1:length(profiles{1})), sprintf('%s%s%s%02d%s', subjectDirectory, configuration.Blender, '/component', component, '.rh.asc'));
    writeVertexColouring(intensity(length(profiles{1})+1:length(profiles{1}) + length(profiles{2})), sprintf('%s%s%s%02d%s', subjectDirectory, configuration.Blender, '/component', component, '.lh.asc'));
end


output = memtoc;


end %end function







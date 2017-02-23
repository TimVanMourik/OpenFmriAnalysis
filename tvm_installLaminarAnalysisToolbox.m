function tvm_installLaminarAnalysisToolbox(configuration)
% TVM_INSTALLLAMINARANALYSISTOOLBOX
%   TVM_INSTALLLAMINARANALYSISTOOLBOX(configuration)
%   
%
%   Copyright (C) Tim van Mourik, 2015, DCCN
%


%%
rootDirectory = mfilename('fullpath');
rootDirectory = fileparts(rootDirectory);

%% Parse configuration
if nargin == 0
    configuration = [];
end
display =       tvm_getOption(configuration, 'Display',     true);
    % true
core =          tvm_getOption(configuration, 'Core',        true);
    % true
interface =     tvm_getOption(configuration, 'Interface',   true);
    % true
development =   tvm_getOption(configuration, 'Development', false);
    % true

%%
addpath(rootDirectory);
if core
    addpath(fullfile(rootDirectory, 'Core'));
    addpath(fullfile(rootDirectory, 'Core/BoundaryRegistration'));
    addpath(fullfile(rootDirectory, 'Core/Curvature'));
    addpath(fullfile(rootDirectory, 'External'));
end
if interface
    addpath(fullfile(rootDirectory, 'Interface'));
    addpath(fullfile(rootDirectory, 'Interface/Activation'));
    addpath(fullfile(rootDirectory, 'Interface/DesignMatrix'));
    addpath(fullfile(rootDirectory, 'Interface/LaminarAnalysis'));
    addpath(fullfile(rootDirectory, 'Interface/Preprocessing'));
    addpath(fullfile(rootDirectory, 'Interface/Registration'));
    addpath(fullfile(rootDirectory, 'Interface/Utilities'));
end
if development
    addpath(fullfile(rootDirectory, 'Development'));
end

if display
    if core
         tvm_workInProgress();
         fprintf('You''re very welcome to use the Laminar Analysis toolbox, \nbut please be aware this version is in continuous development\n');
    end
end

end %end function


%This function is defined in the toolbox, but as this function is there to
%load the toolbox, we don't know about this function yet
function optionValue = tvm_getOption(configuration, optionName, default)
%TVM_GETOPTION Finds an option in a parameter
%   VALUE = GETOPTION(OPTIONS,'NAME', DEFAULT) 
%   This is an adaptation of the MATLAB getoptim() function. If the option
%   NAME is given in the cell array OPTIONS, the VALUE is the assigned
%   value. Otherwise, the default value is returned.
%
%   Copyright (C) 2012-2016, Tim van Mourik, DCCN

if nargin == 2
    if isfield(configuration, optionName)
        optionValue = configuration.(optionName);
        return
    else
        error('TVM:getOption:MandatoryOption', [optionName ' is a mandatory option']);
    end
end

if isfield(configuration, optionName)
    optionValue = configuration.(optionName);
else
    optionValue = default;
end

end %end function





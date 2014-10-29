function optionValue = tvm_getOption(configuration, optionName, default)
%TVM_GETOPTION Finds an option in a parameter
%   VALUE = GETOPTION(OPTIONS,'NAME', DEFAULT) 
%   This is an adaptation of the MATLAB getoptim() function. If the option
%   NAME is given in the cell array OPTIONS, the VALUE is the assigned
%   value. Otherwise, the default value is returned.
%
%   Copyright (C) 2012-2013, Tim van Mourik, DCCN

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

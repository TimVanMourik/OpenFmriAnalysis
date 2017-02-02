function tvm_layerPipeline(configuration)
% TVM_LAYERPIPELINE
%   TVM_LAYERPIPELINE(configuration)
%   Wrapper around all layering functions
%   @todo Expand description
%
% Input:
%   i_SubjectDirectory
%   ...
% Output:
%   ...
%

%   Copyright (C) Tim van Mourik, 2014-2016, DCCN
%
% This file is part of the fmri analysis toolbox, see 
% https://github.com/TimVanMourik/FmriAnalysis for the documentation and 
% details.
%
%    This toolbox is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    This toolbox is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with the fmri analysis toolbox. If not, see 
%    <http://www.gnu.org/licenses/>.

%%
try
    tvm_boundariesToObj(configuration);    
    configuration.i_ObjWhite        = configuration.o_ObjWhite;
    configuration.i_ObjPial         = configuration.o_ObjPial;
catch err
    warning('%s\nSkipping tvm_boundariesToObj', err.message);
end
%%
try
    tvm_makeLevelSet(configuration);
    configuration.i_White                   = configuration.o_White;
    configuration.i_Pial                    = configuration.o_Pial;
catch err
    warning('%s\nSkipping tvm_makeLevelSet', err.message);
end
%%
try
    tvm_laplacePotentials(configuration);
    configuration.i_Potential               = configuration.o_LaplacePotential;
    configuration.i_Normalise               = true;
catch err
    warning('%s\nSkipping tvm_laplacePotentials', err.message);
end
%%
try
    tvm_gradient(configuration);
    configuration.i_VectorField             = configuration.o_Gradient ;
    configuration.o_Divergence              = configuration.o_Curvature;
catch err
    warning('%s\nSkipping tvm_gradient', err.message);
end
%%
try
    tvm_computeDivergence(configuration);
    configuration.i_Curvature               = configuration.o_Curvature;
    configuration.i_Gradient                = configuration.o_Gradient;
catch err
    warning('%s\nSkipping tvm_computeDivergence', err.message);
end

%%
try
    tvm_volumetricLayering(configuration);
catch err
    warning('%s\nSkipping tvm_volumetricLayering', err.message);
end

end %end function




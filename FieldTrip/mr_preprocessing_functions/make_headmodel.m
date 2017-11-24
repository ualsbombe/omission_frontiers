function [headmodel] = make_headmodel(cfg, input_variables)
% This function creates a headmodel based on the supplied mesh
%
% cfg can contain anything that ft_prepare_headmodel recognizes

brain_mesh = input_variables{1};
headmodel = ft_prepare_headmodel(cfg, brain_mesh);

headmodel = {headmodel};

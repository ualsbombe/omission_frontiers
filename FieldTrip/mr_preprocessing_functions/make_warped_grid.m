function [warped_grid] = make_warped_grid(cfg, input_variables)
% This function creates a sourcemodel based on the warping of the
% individual mri to a template
%
% cfg can contain anything that ft_prepare_sourcemodel recognizes

mri = input_variables{1};
cfg.mri = mri;
warped_grid = ft_prepare_sourcemodel(cfg);

warped_grid = {warped_grid};

function [brain_mesh] = make_brain_mesh(cfg, input_variables)
% This function creates a brain mesh of the segmented brain
%
% cfg can contain anything that ft_prepare_mesh recognizes

mri_segmented = input_variables{1};
brain_mesh = ft_prepare_mesh(cfg, mri_segmented);

brain_mesh = {brain_mesh};

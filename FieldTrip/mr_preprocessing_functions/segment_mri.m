function [mri_segmented] = segment_mri(cfg, input_variables)
% This function segments an mri into the chosen tissue types
%
% cfg can contain anything that ft_volumesegment recognizes

mri_realigned_digitization_points = input_variables{1};
mri_segmented = ft_volumesegment(cfg, mri_realigned_digitization_points);

mri_segmented = {mri_segmented};

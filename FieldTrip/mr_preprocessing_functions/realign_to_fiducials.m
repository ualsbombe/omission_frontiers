function [mri_realigned_fiducials] = realign_to_fiducials(cfg, input_variables)
% This function creates a mri realigned to the fiducials
%
% cfg can contain anything that ft_volumerealign recognizes

% get mri
mri = input_variables{1};
mri_realigned_fiducials = ft_volumerealign(cfg, mri);

mri_realigned_fiducials = {mri_realigned_fiducials};

function [mri_realigned_digitization_points] = ...
                    realign_to_digitization_points(cfg, input_variables)
% This function creates a mri realigned to the digitization points,
% input should be realigned to fiducials already
%
% cfg must contain
% 
%	cfg.headshape_file = name of the raw file from which the headshape
%	points can be got


% cfg can contain anything that ft_volumerealign recognizes

headshape_path = fullfile(cfg.save_path, cfg.headshape_file);

headshape = ft_read_headshape(headshape_path);
cfg.headshape.headshape = headshape;

mri_realigned_fiducials = input_variables{1};
mri_realigned_digitization_points = ft_volumerealign(cfg, ...
                                                  mri_realigned_fiducials);

mri_realigned_digitization_points = {mri_realigned_digitization_points};
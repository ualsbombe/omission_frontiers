function [leadfield] = make_leadfield(cfg, input_variables)
% This function creates a leadfield based on the warped grid, 
%  the sensor path and the headmodel
%
% cfg must contain
%	
%	cfg.sensors_file = name of the MEG file
%
% cfg can contain anything that ft_prepare_sourcemodel recognizes

warped_grid = input_variables{1};
headmodel = input_variables{2};
sensors_path = fullfile(cfg.save_path, cfg.sensors_file);
sensors = ft_read_sens(sensors_path);

cfg.grad = sensors;
cfg.grid = warped_grid;
cfg.headmodel = headmodel;

leadfield = ft_prepare_leadfield(cfg);

leadfield = {leadfield};

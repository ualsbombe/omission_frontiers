function [handles] = plot_headmodel_inside_grid(cfg, input_variables)
% This function shows the headmodel inside a grid

close all hidden

headmodel = input_variables{1};
warped_grid = input_variables{2};

h1 = figure('units', 'normalized', 'outerposition', [0 0 1 1]);
hold on
ft_plot_mesh(warped_grid);
ft_plot_vol(headmodel);
view(cfg.view);

handles = {h1};
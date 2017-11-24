function [handles] = plot_ica(cfg, input_variables)
% This function shows components on a continuous plot and on a
% topographical plot
%
% cfg must contain:
% 
%   cfg.contiunous = configuration for continuous plot, see ft_databrowser
%   cfg.topo      = configuration for topographical plot, see ft_topoplotIC
% 
% cfg.continuous can contain anything that ft_databrowser recognizes
% cfg.topo can contain anything that ft_topoplotIC recognizes

close all hidden

% continuous figure
ft_databrowser(cfg.continuous, input_variables{1});
% full screen fig
set(gcf, 'units', 'normalized', 'outerposition', [0 0 1 1]); 
h1 = figure(1);

% topographical plot
% full screen fig
figure('units', 'normalized', 'outerposition', [0 0 1 1]); 
ft_topoplotIC(cfg.topo, input_variables{1});
h2 = figure(2);

handles = {h1 h2}; %% return as cell
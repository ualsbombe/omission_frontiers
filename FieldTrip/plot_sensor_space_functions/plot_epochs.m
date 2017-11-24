function [handles] = plot_epochs(cfg, input_variables)
% This function shows epochs on a trial plot
%
% cfg can contain anything that ft_databrowser recognizes

close all hidden

cfg.channel = cfg.channel_sets{1};
% continuous figure
ft_databrowser(cfg, input_variables{1});
% full screen fig
set(gcf, 'units', 'normalized', 'outerposition', [0 0 1 1]); 
h1 = figure(1);

cfg.channel = cfg.channel_sets{2};
% continuous figure
ft_databrowser(cfg, input_variables{1});
% full screen fig
set(gcf, 'units', 'normalized', 'outerposition', [0 0 1 1]); 
h2 = figure(2);

handles = {h1 h2}; %% return as cell
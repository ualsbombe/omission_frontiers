function [handles] = plot_epochs(cfg, input_variables)
% This function shows epochs on a trial plot
%
% cfg can contain anything that ft_databrowser recognizes and may contain:
%   
%    cfg.trial_indices_filename = filename containing the indices to plot

close all hidden

data = input_variables{1};

if isfield(cfg, 'trial_indices_filename')
    indices = dlmread(cfg.trial_indices_filename, '\t');
    cfg_select_data = [];
    cfg_select_data.trials = indices;
    data = ft_selectdata(cfg_select_data, data);
end 

cfg.channel = cfg.channel_sets{1};
% continuous figure
ft_databrowser(cfg, data);
% full screen fig
set(gcf, 'units', 'normalized', 'outerposition', [0 0 1 1]); 
h1 = figure(1);

cfg.channel = cfg.channel_sets{2};
% continuous figure
ft_databrowser(cfg, data);
% full screen fig
set(gcf, 'units', 'normalized', 'outerposition', [0 0 1 1]); 
h2 = figure(2);

handles = {h1 h2}; %% return as cell
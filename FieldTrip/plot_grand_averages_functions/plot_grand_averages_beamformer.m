function [handles] = plot_grand_averages_beamformer(cfg, input_variables)
% This function plots grand average beamformer, input variable should be
% grand average beamformer 
%
% cfg must contain:
% 
%   cfg.events      = cell array of events to plot
%   cfg.title_names = cell array of title strings
% 

close all hidden

data = input_variables{1};
n_events = length(cfg.events);
plot_data = cell(1, n_events);

for event_index = 1:n_events;
    event = cfg.events{event_index};
    field_name = ['event_' num2str(event)];
    plot_data{event_index} = data.(field_name);
end

% plots
for event_index = 1:n_events
    cfg.title = cfg.title_names{event_index};
    ft_sourceplot(cfg, plot_data{event_index});
    h1 = gcf;
    set(h1, 'units', 'normalized', 'outerposition', [0 0 0.40 0.5]);
end

handles = {h1}; %% return as cell
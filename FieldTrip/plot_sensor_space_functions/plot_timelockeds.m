function [handles] = plot_timelockeds(cfg, input_variables)
% This function plots timelockeds
%
% cfg must contain:
% 
%   cfg.singleplot = configuration for singleplot, see ft_singleplotTFR
%   cfg.topoplot  = configuration for topographical plot, see
%   ft_topoplotTFR
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

% singleplot
figure('units', 'normalized', 'outerposition', [0 0 1 1]);% full screen fig
for event_index = 1:n_events
    subplot(2, ceil(n_events/2), event_index)
    ft_multiplotER(cfg.multiplot, plot_data{event_index});
end
h1 = figure(1);

% topographical plot
% full screen fig
figure('units', 'normalized', 'outerposition', [0 0 1 1]);
for event_index = 1:n_events
    subplot(2, ceil(n_events/2), event_index)
    ft_topoplotER(cfg.topoplot, plot_data{event_index});
    title(cfg.topoplot.title_names{event_index})
    if strcmp(cfg.topoplot.custom_colorbar, 'yes') && ...
              event_index == n_events
        c = colorbar('location', 'east');
        c.Position = [c.Position(1) + 0.03 c.Position(2:end)];
        c.Ticks = cfg.topoplot.zlim(1):1e-13:cfg.topoplot.zlim(2);
        c.Label.String = cfg.topoplot.colorbar_label;
        c.Label.Position = [c.Label.Position(1) + 6 ...
                            c.Label.Position(2:end)];
        c.Label.FontSize = 30;
    end       
end
h2 = figure(2);

handles = {h1 h2}; %% return as cell
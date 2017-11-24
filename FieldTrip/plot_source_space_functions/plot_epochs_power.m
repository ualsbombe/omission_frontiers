function [handles] = plot_epochs_power(cfg, input_variables)
% This function plots epochs power
%
% cfg must contain:
% 
%   cfg.events = cell array containg the events to be plotted
%   cfg.combine = structure for ft_combineplanar
%

close all hidden

data = input_variables{1};
baseline = input_variables{2};
n_events = length(cfg.events);
plot_data = cell(1, n_events);

for event_index = 1:n_events;
    event = cfg.events{event_index};
    field_name = ['event_' num2str(event)];
    plot_data{event_index} = data.(field_name);
    plot_data{event_index} = ft_combineplanar(cfg.combine, ...
                                              plot_data{event_index});
end

contrast_field_name = ['event_' num2str(cfg.contrast_event)];
contrast_data = baseline.(contrast_field_name);
n_trials_contrast = length(contrast_data.trialinfo);

% eplot
figure('units', 'normalized', 'outerposition', [0 0 1 1]);% full screen fig
for event_index = 1:n_events
    event = cfg.events{event_index};
    this_data = plot_data{event_index};
    n_trials_event = length(this_data.trialinfo);
    n_trials_baseline = length(contrast_data.trialinfo);
    max_n_trials = max([n_trials_event n_trials_baseline]);
    subplot(2, ceil(n_events/2), event_index)
    hold on
    plot(1:n_trials_event, real(this_data.fourierspctrm(:, :)).^2, 'r')
    plot(1:n_trials_contrast, ...
                       real(contrast_data.fourierspctrm(:, :)).^2, 'b')
    xlabel('Trial No.')
    ylabel('Power of band')
    xlim([1 max_n_trials])
    title(sprintf(['Event ' num2str(event) ...
           ': Red = Event\n\t\t\t\t\t\t\tBlue = Non-Stimulation']))
end
h1 = figure(1);

handles = {h1};
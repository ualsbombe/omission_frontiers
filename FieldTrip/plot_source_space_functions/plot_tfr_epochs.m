function [handles] = plot_tfr_epochs(cfg, input_variables)
% This function plots trials
%
% cfg must contain:
% 
%   cfg.events = cell array containg the events to be plotted

close all hidden

data = input_variables{1};
n_events = length(cfg.events);
plot_data = cell(1, n_events);

for event_index = 1:n_events;
    event = cfg.events{event_index};
    field_name = ['event_' num2str(event)];
    plot_data{event_index} = data.(field_name);
end

% eplot
figure('units', 'normalized', 'outerposition', [0 0 1 1]);% full screen fig
for event_index = 1:n_events
    event = cfg.events{event_index};
    this_data = plot_data{event_index};
    n_trials = length(this_data.trial);
    subplot(2, ceil(n_events/2), event_index)
    hold on
    for trial_index = 1:n_trials
        plot(this_data.time{trial_index}, ...
             this_data.trial{trial_index}(1, :), 'b');
    end
    xlabel('Time (s)')
    xlim(cfg.xlim);
    ylabel('Magnetic Field Gradient (T/m)') %% check this
    title(['Event ' num2str(event)])
end
h1 = figure(1);

handles = {h1};
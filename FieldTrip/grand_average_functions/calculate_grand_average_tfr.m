function [grand_average_tfrs] = calculate_grand_average_tfr(cfg, data_cell)
% This function calculates the tfr grand averages
%
% cfg must contain:
%
%   cfg.events = a cell array containing the events numbers for all events
%   to be grand averaged
%
% cfg can contain anything that ft_freqgrandaverage recognizes

events = cfg.events;
n_events = length(events);
tfrs = data_cell;
grand_average_tfrs = [];
n_subjects = length(tfrs);

for event_index = 1:n_events
    data_event = cell(1, n_subjects); %% events
    event = events{event_index};
    field_name = ['event_' num2str(event)];
    for subject_index = 1:n_subjects
        this_tfr = tfrs{subject_index}{1}.(field_name);
        data_event{subject_index} = this_tfr;
    end
    this_ga = ft_freqgrandaverage(cfg, data_event{:});
    grand_average_tfrs.(field_name) = this_ga;
end

grand_average_tfrs = {grand_average_tfrs}; %% return as cell
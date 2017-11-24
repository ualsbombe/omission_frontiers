function [grand_average_beamformers] = ...
        calculate_grand_average_beamformer(cfg, data_cell)
% This function calculates the beamformer source grand averages
%
% cfg must contain:
%
%   cfg.events = a cell array containing the events numbers for all events
%   to be grand averaged
%
% cfg can contain anything that ft_sourcegrandaverage recognizes

events = cfg.events;
n_events = length(events);
beamformer_contrasts = data_cell;
grand_average_beamformers = [];
n_subjects = length(beamformer_contrasts);
template_grid = load(cfg.template_path);

for event_index = 1:n_events
    data_event = cell(1, n_subjects); %% events
    event = events{event_index};
    field_name = ['event_' num2str(event)];
    for subject_index = 1:n_subjects
        this_beamformer = ...
                       beamformer_contrasts{subject_index}{1}.(field_name);
        this_beamformer.pos = template_grid.sourcemodel.pos; 
        data_event{subject_index} = this_beamformer;
    end
    this_ga = ft_sourcegrandaverage(cfg, data_event{:});
    this_ga = rmfield(this_ga, 'cfg'); %% takes up a lot of space
    grand_average_beamformers.(field_name) = this_ga;
end

grand_average_beamformers = {grand_average_beamformers}; %% return as cell
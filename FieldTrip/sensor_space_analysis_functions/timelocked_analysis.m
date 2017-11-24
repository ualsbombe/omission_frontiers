function [timelocked_data] = timelocked_analysis(cfg, input_variables)
% This function averages data at each time sample
%
% cfg must contain:
% 
%   cfg.events = a cell array containing the event numbers for all events
%   to be timelocked
% 
% cfg can contain anything that ft_timelockanalysis recognizes

events = cfg.events;
n_events = length(events);
timelocked_data = [];

for event_index = 1:n_events
    event = events{event_index};
    field_name = ['event_' num2str(event)];
    cfg.trials = input_variables{1}.trialinfo == event;
    this_timelock = ft_timelockanalysis(cfg, input_variables{1});
    timelocked_data.(field_name) = this_timelock;
end                                                  
    
timelocked_data = {timelocked_data}; %% return as cell  
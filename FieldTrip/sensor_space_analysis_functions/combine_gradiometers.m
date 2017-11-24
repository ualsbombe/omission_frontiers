function [combined_tfr] = combine_gradiometers(cfg, input_variables)
% This function combines gradiometers for the input data
%
% cfg must contain:
% 
%   cfg.events = a cell array containing the event numbers for all events
%   to be calculated
% 
% cfg can contain anything that ft_combineplanar recognizes

events = cfg.events;
n_events = length(events);
tfr = input_variables{1}; % make a copy
combined_tfr = [];

for event_index = 1:n_events
    event = events{event_index};
    field_name = ['event_' num2str(event)];
    this_tfr = tfr.(field_name);
    this_combined = ft_combineplanar(cfg, this_tfr);
    combined_tfr.(field_name) = this_combined;
end                                                  
    
combined_tfr = {combined_tfr}; %% return as cell
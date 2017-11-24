function [tfr] = time_frequency_representation(cfg, input_variables)
% This function calculates the time-frequency representation for the input
%
% cfg must contain:
% 
%   cfg.events = a cell array containing the event numbers for all events
%   to be calculated
% 
% cfg can contain anything that ft_freqlockanalysis recognizes

events = cfg.events;
n_events = length(events);
tfr = [];

for event_index = 1:n_events
    event = events{event_index};
    field_name = ['event_' num2str(event)];
    cfg.trials = input_variables{1}.trialinfo == event;
    this_tfr = ft_freqanalysis(cfg, input_variables{1});
    tfr.(field_name) = this_tfr;
end                                                  
    
tfr = {tfr}; %% return as cell
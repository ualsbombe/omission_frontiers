function [cropped_data] = crop_data(cfg, input_variables)
% This function crops the events by the toi
%
% cfg must contain:
% 
%   cfg.events          = a cell array containing the event numbers
%   cfg.redefine_trial  = structure for ft_redefinetrial
%   cfg.select_data     = structure fot ft_selectdata


events = cfg.events;
n_events = length(events);
cropped_data = [];
untimelocked_data = input_variables{1};

for event_index = 1:n_events
    event = events{event_index};
    field_name = ['event_' num2str(event)];
    cfg.trials = untimelocked_data.trialinfo == event;
    this_untimelocked_data = ft_selectdata(cfg, untimelocked_data);
    
    this_cropped_data = ft_redefinetrial(cfg.redefine_trial, ...
        this_untimelocked_data);
    this_cropped_data = ft_selectdata(cfg.select_data, this_cropped_data);
    cropped_data.(field_name) = this_cropped_data;
end                                                  
    
cropped_data = {cropped_data}; %% return as cell
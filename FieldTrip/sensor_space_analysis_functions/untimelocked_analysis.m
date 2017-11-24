function [untimelocked_data] = untimelocked_analysis(cfg, input_variables)
% This function removed the trial average from each at each time sample
%
% cfg must contain:
% 
%   cfg.events = a cell array containing the event numbers for all events
%   to be untimelocked
%
% input_variable{1} should be epoched data and input_variable{2} should be
% timelocked

events = cfg.events;
n_events = length(events);
untimelocked_data = input_variables{1}; %% make a copy
timelockeds = input_variables{2};

for event_index = 1:n_events
    event = events{event_index};
    field_name = ['event_' num2str(event)];
    this_timelocked = timelockeds.(field_name);
    trial_indices = find(untimelocked_data.trialinfo == event)';
    
    disp(['Removing average responses from: ' field_name]);
    for trial_index = trial_indices
        untimelocked_data.trial{trial_index} = ...
            untimelocked_data.trial{trial_index} - this_timelocked.avg;
    end
   
end
        
untimelocked_data = {untimelocked_data}; %% return as cell
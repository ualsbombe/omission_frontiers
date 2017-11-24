function [trials, events] = trial_function(cfg)
% trial function for reading in the data


%% read the header and events and data

header = ft_read_header(cfg.dataset);
events = ft_read_event(cfg.dataset);

%% create relevant events

event_type = cfg.event_type; 
events = events(strcmp(event_type, {events.type}));
n_events = length(events);
to_be_removed_indices = []; % indices of trials to be removed

for event_index = 1:n_events
    if events(event_index).value == 16 %% a spurious value in some files
        to_be_removed_indices = [to_be_removed_indices event_index]; %#ok<*AGROW>
    end
end

events(to_be_removed_indices) = []; %% remove the spurious triggers

%% number of samples before and after triggers

pretrigger = -round(cfg.pretrigger * header.Fs);
posttrigger = round(cfg.posttrigger * header.Fs);

%% trial structure

n_events = length(events);

trials = zeros(n_events, 4);

remove_indiced_trials = [];

for trial_index = 1:n_events
    event_value = events(trial_index).value; %% the trigger value
    % time before trigger
    trial_begin = events(trial_index).sample + pretrigger;
    % time after trigger
    trial_end = events(trial_index).sample + posttrigger;
    offset = pretrigger;
    % if/else statements only add trials that don't span two files
    if trial_begin < 1 % means that it is outside the file (in last file)
        remove_indiced_trials = [remove_indiced_trials trial_index];
    end
    % only include the trial if it doesn't end outside the file
    if trial_end <= header.nSamples 
        new_trial = [trial_begin trial_end offset];
        trials(trial_index, 1:3) = new_trial;
        trials(trial_index, 4) = event_value;
    else
        remove_indiced_trials = [remove_indiced_trials trial_index];
    end

end

if ~isempty(remove_indiced_trials)
    % remove the trials that span two files
    trials(remove_indiced_trials, :) = [];
end
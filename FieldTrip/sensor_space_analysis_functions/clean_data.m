function [cleaned_data] = clean_data(cfg, input_variables)
% This function cleans preprocessed data
%
% cfg must contain:
% 
%   cfg.channel_sets = a cell array of sets of channels that should be
%   cleaned
%   cfg.filename     = name of tsv file for saving the removed indices
% 
% cfg can contain anything that ft_rejectvisual recognizes

preprocessed_data = input_variables{1}; %% to compare cleaned data against
n_channel_sets = length(cfg.channel_sets);

cleaned_data_sets = cell(1, n_channel_sets);

for channel_set_index = 1:n_channel_sets
    % clean 
    cfg.channel = cfg.channel_sets{channel_set_index}; 
    cleaned_data_sets{channel_set_index} = ...
        ft_rejectvisual(cfg, preprocessed_data);   
end

% get the indices from the removed trials and remove them from the cleaned
% data
removed_trial_indices = [];
n_trials = length(preprocessed_data.trial);
for channel_set_index = 1:n_channel_sets
    this_cleaned_data = cleaned_data_sets{channel_set_index};
    for trial_index = 1:n_trials
        if isnan(this_cleaned_data.trial{trial_index}(1))
            removed_trial_indices = [removed_trial_indices ...
                                     trial_index]; %#ok<AGROW>
        end
    end
end

removed_trial_indices = unique(removed_trial_indices);

remaining_trials = 1:n_trials;
remaining_trials(removed_trial_indices) = []; % remove these indices

cfg_choose_trials = [];
cfg_choose_trials.trials = remaining_trials;

cleaned_data = ft_selectdata(cfg_choose_trials, preprocessed_data);

% write indices
filename = fullfile(cfg.save_path, cfg.filename);
dlmwrite(filename, removed_trial_indices, 'delimiter', '\t');
disp(['Wrote: ' filename]);

cleaned_data = {cleaned_data}; %% return as cell
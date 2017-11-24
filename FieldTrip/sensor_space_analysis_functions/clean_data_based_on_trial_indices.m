function [cleaned_data] = ...
                    clean_data_based_on_trial_indices(cfg, input_variables)
% This function removes trials from data
%
% cfg can contain anything that ft_selectdata recognizes
%
% input_variable{1} should be non-cleaned_data

non_cleaned_data = input_variables{1};
filename = fullfile(cfg.save_path, cfg.filename);
indices = dlmread(filename, '\t');

trials = 1:length(non_cleaned_data.trial);
trials(indices) = []; %% remove trials

cfg.trials = trials;

cleaned_data = ft_selectdata(cfg, non_cleaned_data);

cleaned_data = {cleaned_data};
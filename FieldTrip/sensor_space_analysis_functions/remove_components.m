function [ica_cleaned_data] = remove_components(cfg, input_variables)
% This function removes components from processed data
%
% cfg must contain:
% 
%   cfg.component_file = a csv-file containing the components for the
%   subject
% 
% cfg can contain anything that ft_rejectcomponent recognizes
%
% input_variable{1} should be components, input_variable{2} should be
% epoched data

filename = fullfile(cfg.save_path, cfg.filename);

component_ids = dlmread(filename, '\t', 1, 0);% read in components file
component_ids = component_ids(~isnan(component_ids)); %% remove NaNs

cfg.component = component_ids;

ica_cleaned_data = ft_rejectcomponent(cfg, input_variables{1}, ...
                                           input_variables{2});
                                       
ica_cleaned_data = {ica_cleaned_data}; %% return as cell                                       
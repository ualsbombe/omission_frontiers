function [fourier_transforms] = get_fourier_transforms(cfg, ...
                                                        input_variables)
% This function finds the fourier transforms for the supplied events
%
% cfg must contain:
% 
%  cfg.events = a cell array containing the event numbers for all csds to
%  find
%
%  cfg can contain anything that ft_freqanalysis recognizes
%

events = cfg.events;
n_events = length(events);
cropped_data = input_variables{1}; % make a copy
% prepare output
fourier_transform_exp       = [];
fourier_transform_contrast  = [];
fourier_transform_combined  = [];

% get contrast data
contrast_field_name = ['event_' num2str(cfg.contrast_event)];
contrast_cropped = cropped_data.(contrast_field_name);
contrast_freq = ft_freqanalysis(cfg, contrast_cropped);
fourier_transform_contrast.(contrast_field_name) = contrast_freq;                                        

% loop through experimental conditions
for event_index = 1:n_events
    event = events{event_index};
    field_name = ['event_' num2str(event)];
    % experimental condition, frequency analysis
    this_cropped = cropped_data.(field_name);
    this_freq_exp = ft_freqanalysis(cfg, this_cropped);
    fourier_transform_exp.(field_name) = this_freq_exp;
    
    % combination of experimental condition and contrast condition
    this_combined_cropped = ft_appenddata([], ...
                                          this_cropped, contrast_cropped);
    this_freq_combined = ft_freqanalysis(cfg, this_combined_cropped);
    fourier_transform_combined.(field_name) = this_freq_combined;
                                      
end                                                  
    
fourier_transforms = {fourier_transform_exp ...
                      fourier_transform_contrast ...
                      fourier_transform_combined}; %% return as cell

function [beamformer_contrasts_interpolated] = ...
            interpolate_beamformer(cfg, input_variables)
% This function interpolates the beamformer contrasts onto a common
% template
%
% cfg must contain:
% 
%  cfg.events = a cell array containing the event numbers for all events
%  whose beamformer source reconstructions should be interpolated
%

events = cfg.events;
n_events = length(events);
beamformer_contrasts = input_variables{1}; % make a copy
% read in template
mri = ft_read_mri(cfg.template_path);
% prepare output
beamformer_contrasts_interpolated = [];

% loop through experimental conditions
for event_index = 1:n_events
    event = events{event_index};
    field_name = ['event_' num2str(event)];
    this_beamformer = beamformer_contrasts.(field_name);
    this_beamformer_interpolated = ft_sourceinterpolate(cfg, ...
                                                    this_beamformer, mri);
    beamformer_contrasts_interpolated.(field_name) = ...
                                              this_beamformer_interpolated;
                                      
end                                                  
% return as cell    
beamformer_contrasts_interpolated = {beamformer_contrasts_interpolated};

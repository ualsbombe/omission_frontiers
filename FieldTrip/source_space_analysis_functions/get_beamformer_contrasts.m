function [beamformer_contrasts] = ...
                get_beamformer_contrasts(cfg, input_variables)
% This function gets the beamformer contrasts by contrasting
% experimental_conditions_fourier with non_stimulation_fourier
% cfg must contain
%
%   cfg.events          = a cell array containing the event numbers for all
%                         beamformer contrast to estimate
%	cfg.contrast_event  = event to be contrasted against
%
% cfg can contain anything that ft_sourceanalysis recognizes

experimental_conditions_fourier = input_variables{1};
non_stimulation_fourier         = input_variables{2};
combined_fourier                = input_variables{3};
headmodel                       = input_variables{4};
leadfield                       = input_variables{5};

cfg.headmodel = headmodel;


events = cfg.events;
n_events = length(events);

beamformer_contrasts = [];

field_name = ['event_' num2str(cfg.contrast_event)];
fourier_non_stimulation = non_stimulation_fourier.(field_name);

% loop through experimental conditions
for event_index = 1:n_events
    event = events{event_index};
    field_name = ['event_' num2str(event)];
    % combined condition, beamformer
	% grid to be set each time, so last round's common filter is not reused
    cfg.grid = leadfield;
    fourier_combined = combined_fourier.(field_name);
    this_beamformer_combined = ft_sourceanalysis(cfg, fourier_combined);
	cfg.grid.filter = this_beamformer_combined.avg.filter; % get combined filter
	fourier_exp = experimental_conditions_fourier.(field_name);
	this_beamformer_exp = ft_sourceanalysis(cfg, fourier_exp);
	this_beamformer_non_stimulation = ...
                            ft_sourceanalysis(cfg, fourier_non_stimulation);
	% get contrast
	this_contrast = this_beamformer_exp;
	this_contrast.avg.pow = ...
        (this_beamformer_exp.avg.pow - ...
            this_beamformer_non_stimulation.avg.pow) ./ ...
                this_beamformer_non_stimulation.avg.pow;
	
    beamformer_contrasts.(field_name) = this_contrast;
                        
end                                                  
    
beamformer_contrasts = {beamformer_contrasts};

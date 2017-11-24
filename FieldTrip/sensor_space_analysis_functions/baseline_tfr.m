function [baselined_tfr] = baseline_tfr(cfg, input_variables)
% This function baselines the tfr events by baseline_event
%
% cfg must contain:
% 
%   cfg.events          = a cell array containing the event numbers for all 
%   events to be baselined
%   cfg.baseline_event  = event to baseline with
%

events = cfg.events;
n_events = length(events);
baselined_tfr = [];
tfr = input_variables{1};
% calculate baseline data
field_name = ['event_' num2str(cfg.baseline_event)];
baseline_data = tfr.(field_name);
% mean_baseline_data modelled on ft_preproc_baselinecorrect
mean_baseline_data = ...
                repmat(nanmean(baseline_data.powspctrm(:, :, :), 3), ...
                    [1 1 size(baseline_data.powspctrm, 3)]);

for event_index = 1:n_events
    event = events{event_index};
    field_name = ['event_' num2str(event)];
    this_tfr = tfr.(field_name);
    disp(['Baselining ' field_name ' with non-stimulation trials']);
    this_tfr_baselined = this_tfr; % make a copy
    this_tfr_baselined.powspctrm = this_tfr.powspctrm ./ ...
                                                    mean_baseline_data;
    baselined_tfr.(field_name) = this_tfr_baselined;
end                                                  
    
baselined_tfr = {baselined_tfr}; %% return as cell
function [statistics_beamformer_interpolated] = ...
            interpolate_statistics_beamformer(cfg, input_variables)
% This function interpolated the statistics from beamformer source
% reconstructions onto a template brain
%
% cfg must contain:
% 
%  cfg.event_comparison = a cell array containing the event numbers for all
%  event comparisons whose stats should be interpolated
%  cfg.template_path = path to template
%

comparisons = cfg.event_comparisons;
n_comparisons = length(comparisons);
stat = input_variables{1}; % make a copy
% read in template
mri = ft_read_mri(cfg.template_path);
% prepare output
statistics_beamformer_interpolated = [];

% loop through experimental conditions
for comparison_index = 1:n_comparisons
    event_1 = comparisons{comparison_index}(1);
    event_2 = comparisons{comparison_index}(2);
    field_name_1 = ['event_' num2str(event_1)];
    field_name_2 = ['event_' num2str(event_2)];
    comparison_name = [field_name_1 '_vs_' field_name_2];
    this_stat = stat.(comparison_name);
    disp(this_stat)
    this_stat_interpolated = ft_sourceinterpolate(cfg, this_stat, mri);
    statistics_beamformer_interpolated.(comparison_name) =  ...
                                            this_stat_interpolated;
                                      
end                                                  
% return as cell    
statistics_beamformer_interpolated = {statistics_beamformer_interpolated};

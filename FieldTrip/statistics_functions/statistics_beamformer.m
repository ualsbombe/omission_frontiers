function [statistics_beamformer] = statistics_beamformer(cfg, data_cell)
% This function calculates the statistics for the beamformer events
%
% cfg must contain:
%
%   cfg.event_comparisons = a cell array containing the events numbers for
%   the events to be compared
%
% cfg can contain anything that ft_sourcestatistics recognizes

event_comparisons = cfg.event_comparisons;
n_comparisons = length(event_comparisons);
beamformers = data_cell;
statistics_beamformer = [];
n_subjects = length(beamformers);
template_grid = load(cfg.template_path);
template_pos = template_grid.sourcemodel.pos;

for comparison_index = 1:n_comparisons
    data_comparison = cell(1, 2*n_subjects); % make room for two conditions
    event_1 = event_comparisons{comparison_index}(1);
    event_2 = event_comparisons{comparison_index}(2);
    field_name_1 = ['event_' num2str(event_1)];
    field_name_2 = ['event_' num2str(event_2)];
    comparisons_name = [field_name_1 '_vs_' field_name_2];
    for subject_index = 1:n_subjects
        this_beamformer_1 = beamformers{subject_index}{1}.(field_name_1);
        this_beamformer_2 = beamformers{subject_index}{1}.(field_name_2);
        this_beamformer_1.pos = template_pos;
        this_beamformer_2.pos = template_pos;
        data_comparison{subject_index} = this_beamformer_1;
        data_comparison{subject_index + n_subjects} = this_beamformer_2;
    end
    this_stat = ft_sourcestatistics(cfg, data_comparison{:});
    this_stat = rmfield(this_stat, 'cfg');
    statistics_beamformer = setfield(statistics_beamformer, ...
                                     comparisons_name, this_stat);
end

statistics_beamformer = {statistics_beamformer}; %% return as cell
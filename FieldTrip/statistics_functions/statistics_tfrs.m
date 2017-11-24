function [statistics_tfrs] = statistics_tfrs(cfg, data_cell)
% This function calculates the statistics for the tfr events
%
% cfg must contain:
%
%   cfg.event_comparisons = a cell array containing the events numbers for
%   the events to be compared
%
% cfg can contain anything that ft_freqstatistics recognizes

event_comparisons = cfg.event_comparisons;
n_comparisons = length(event_comparisons);
tfrs = data_cell;
statistics_tfrs = [];
n_subjects = length(tfrs);

for comparison_index = 1:n_comparisons
    data_comparison = cell(1, 2*n_subjects); %% make room for two conditions
    event_1 = event_comparisons{comparison_index}(1);
    event_2 = event_comparisons{comparison_index}(2);
    field_name_1 = ['event_' num2str(event_1)];
    field_name_2 = ['event_' num2str(event_2)];
    comparisons_name = [field_name_1 '_vs_' field_name_2];
    for subject_index = 1:n_subjects
        this_tfr_1 = tfrs{subject_index}{1}.(field_name_1);
        this_tfr_2 = tfrs{subject_index}{1}.(field_name_2);
        data_comparison{subject_index} = this_tfr_1;
        data_comparison{subject_index + n_subjects} = this_tfr_2;
    end
    this_stat = ft_freqstatistics(cfg, data_comparison{:});
    this_stat = rmfield(this_stat, 'cfg');
    statistics_tfrs = setfield(statistics_tfrs, comparisons_name, this_stat);
end

statistics_tfrs = {statistics_tfrs}; %% return as cell
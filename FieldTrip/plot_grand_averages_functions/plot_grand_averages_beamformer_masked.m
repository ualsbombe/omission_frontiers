function [handles] = plot_grand_averages_beamformer_masked(cfg, ...
                                                        input_variables)
% This function plots grand average beamfomers, first input variable should
% be grand average beamformer and second should be statistics
%
% cfg must contain:
% 
% cfg.event_comparisons = cell array of comparisons, e.g. {[3 15]};
% cfg.title_names = cell array of title names
% 

close all hidden

data = input_variables{1};
stat = input_variables{2};
n_comparisons = length(cfg.event_comparisons);

differences = cell(1, n_comparisons);

for comparison_index = 1:n_comparisons;
    event_1 = cfg.event_comparisons{comparison_index}(1);
    event_2 = cfg.event_comparisons{comparison_index}(2);
    field_name_1 = ['event_' num2str(event_1)];
    field_name_2 = ['event_' num2str(event_2)];
    comparison_name = [field_name_1 '_vs_' field_name_2];
    plot_data_1 = data.(field_name_1);
    plot_data_2 = data.(field_name_2);
    cfg_math = [];
    cfg_math.operation = 'x1 - x2';
    cfg_math.parameter = 'pow';
    difference = ft_math(cfg_math, plot_data_1, plot_data_2);
    stat_comparison = stat.(comparison_name);
    difference.mask = stat_comparison.mask;
%     difference.mask = difference.mask == 1;
    difference.coordsys = 'mni';
    difference.anatomy = plot_data_1.anatomy;
    differences{comparison_index} = difference;
end

handles = cell(1, n_comparisons);
% sourceplot
for comparison_index = 1:n_comparisons
    cfg.title = cfg.title_names{comparison_index};
    
    ft_sourceplot(cfg, differences{comparison_index});
    h = gcf;
    set(h, 'units', 'normalized', 'outerposition', [0 0 1 1]);
    handles{comparison_index} = h;
end

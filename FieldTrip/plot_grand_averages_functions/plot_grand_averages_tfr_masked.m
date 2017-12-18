function [handles] = plot_grand_averages_tfr_masked(cfg, input_variables)
% This function plots grand average tfrs, first input variable should be
% grand average tfr and second is optional, but should be statistics
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
    cfg_math.parameter = 'powspctrm';
    difference = ft_math(cfg_math, plot_data_1, plot_data_2);
    stat_comparison = stat.(comparison_name);
    difference.mask = stat_comparison.mask;
    differences{comparison_index} = difference;
end

if n_comparisons == 1
    subplot_row = 1;
else
    subplot_row = 2;
end
% singleplot
figure('units', 'normalized', 'outerposition', [0 0 1 1]);% full screen fig
for comparison_index = 1:n_comparisons
    cfg.singleplot.title = cfg.title_names{comparison_index};
    cfg.singleplot.colorbar = 'no';
    subplot(subplot_row, ceil(n_comparisons/subplot_row), comparison_index)
    ft_singleplotTFR(cfg.singleplot, differences{comparison_index});
    xlabel('Time (s)')
    ylabel('Frequency (Hz)')
    c = colorbar('location', 'east');
    c.Position = [c.Position(1) + 0.05 c.Position(2:end)];
    c.Ticks = cfg.singleplot.zlim(1):0.1:cfg.singleplot.zlim(2);
    c.Label.String = cfg.singleplot.colorbar_label;
    c.Label.Position = [c.Label.Position(1) + 8 ...
                          c.Label.Position(2:end)];
    c.Label.FontSize = 30;
end
h1 = figure(1);

% topographical plot
% full screen fig
figure('units', 'normalized', 'outerposition', [0 0 1 1]);
for comparison_index = 1:n_comparisons
    subplot(subplot_row, ceil(n_comparisons/subplot_row), comparison_index)
    title(cfg.title_names{comparison_index})
    ft_multiplotTFR(cfg.multiplot, differences{comparison_index});
end
h2 = figure(2);

handles = {h1 h2}; %% return as cell
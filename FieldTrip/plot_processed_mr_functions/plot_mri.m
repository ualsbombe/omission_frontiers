function [handles] = plot_mri(cfg, input_variables)
% This function shows an mri structure
%
% cfg can contain anything that ft_sourceplot recognizes

close all hidden
n_input_variables = length(input_variables);
handles = cell(1, n_input_variables);

for input_index = 1:n_input_variables
    ft_sourceplot(cfg, input_variables{1});
    % full screen fig
    set(gcf, 'units', 'normalized', 'outerposition', [0 0 1 1]); 
    h = gcf;
    handles{input_index} = h;    
end

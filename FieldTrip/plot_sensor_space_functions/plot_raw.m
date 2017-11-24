function [handles] = plot_raw(cfg, save_path)
% This function shows the raw data (MaxFiltered) in a continuous plot
%
% cfg must contain:
% 
%   cfg.continuous = configuration for continuous plot, see ft_databrowser
%   cfg.topo      = configuration for topographical plot, see ft_topoplotIC
% 
% cfg.continuous can contain anything that ft_databrowser recognizes
% cfg.topo can contain anything that ft_topoplotIC recognizes

close all hidden

% find split files
split_extension = 1; %% first split file extension number
directory = dir(save_path); %% get all files
all_filenames = {directory.name};
split_filenames = {};

% check if filename exists
filename = [cfg.input_file cfg.input_extension];
split_filenames{split_extension} = filename;
filename_exists = sum(strcmp(filename, all_filenames));
if ~filename_exists
    error(['Filename: ' filename ' does not exist on path: ' save_path])
end

% find number of split files
while true %% run until break
    split_filename = [cfg.input_file '-' num2str(split_extension) ...
                      cfg.input_extension];
    split_filename_exists = sum(strcmp(split_filename, ...
                                            all_filenames));
    if split_filename_exists
        split_extension = split_extension + 1;  % increment
        split_filenames{split_extension} = split_filename;
    else
        break %% break when no more files can be found
    end
end

n_split_files = length(split_filenames);
split_files = cell(1, n_split_files);
cfg_preprocessing = [];

for split_file_index = 1:n_split_files
    split_filename = split_filenames{split_file_index};
    cfg_preprocessing.dataset = fullfile(save_path, split_filename);
    split_files{split_file_index} = ft_preprocessing(cfg_preprocessing);
end
% aopend the split files
cfg_append = [];

raw_data = ft_appenddata(cfg_append, split_files{:});

% continuous figure
ft_databrowser(cfg, raw_data);
% full screen fig
set(gcf, 'units', 'normalized', 'outerposition', [0 0 1 1]); 
h1 = figure(1);

handles = {h1}; %% return as cell
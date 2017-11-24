function [preprocessed_data] = define_trials_and_preprocess_data(cfg, ...
                                                            save_path)
% This function defines trials and preprocesses the data according to the
% configuration ("cfg").
%
% cfg must contain:
% 
%   cfg.input_file       = name of raw file (first part if split file)
%   cfg.trial_definition = trial definition structure, see ft_definetrial
%   cfg.preprocessing    = preprocessing structure, see ft_preprocessing
%   cfg.adjust_timeline  = offset for adjusting timeline msec
%   cfg.downsample_to    = resampling frequency (Hz)

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

% loop through split files
split_files = cell(1, n_split_files); %% where to put preprocessed files
for split_file_index = 1:n_split_files
    split_filename = split_filenames{split_file_index};
    % add dataset
    cfg.trial_definition.dataset = fullfile(save_path, split_filename);
    % trial definition
    cfg_defined_trials = ft_definetrial(cfg.trial_definition); 
    
    preprocessing_fields = fieldnames(cfg.preprocessing);
    for preprocessing_field_index = 1:length(preprocessing_fields)
        preprocessing_field = preprocessing_fields{preprocessing_field_index};
        cfg_defined_trials.(preprocessing_field) = ...
                                cfg.preprocessing.(preprocessing_field);
    end
    % preprocess data
    split_files{split_file_index} = ft_preprocessing(cfg_defined_trials);
end

% append split data
cfg_appended_data = [];

appended_data = ft_appenddata(cfg_appended_data, split_files{:});

% adjust timeline
cfg_adjust_timeline = [];
cfg_adjust_timeline.offset = cfg.adjust_timeline;

adjusted_data = ft_redefinetrial(cfg_adjust_timeline, appended_data);

cfg_downsample = [];
cfg_downsample.resamplefs = cfg.downsample_to;

preprocessed_data = ft_resampledata(cfg_downsample, adjusted_data);

preprocessed_data = {preprocessed_data}; % return as cell

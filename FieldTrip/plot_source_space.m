%% SET PATHS

restoredefaultpath; %% set a clean path
home_dir = '/home/lau/'; %% change according to your path
analysis_dir = 'analyses/omission_frontiers_BIDS-FieldTrip/';

matlab_dir = fullfile(home_dir, 'matlab'); % change according to your path
data_dir = fullfile(home_dir, analysis_dir, '/data');
figures_dir = fullfile(home_dir, analysis_dir, 'figures');
script_dir = fullfile(home_dir, analysis_dir, 'scripts', 'matlab');

%% ADD PATHS

% add your fieldtrip
addpath(fullfile(matlab_dir, 'fieldtrip-20170906'));
ft_defaults %% initialize FieldTrip defaults

% functions needed for analysis
addpath(fullfile(script_dir, 'general_functions'));
addpath(fullfile(script_dir, 'plot_source_space_functions'));

%% SUBJECTS
% these are the subjects names

subjects = {
        
             'sub-01'
             'sub-02'
             'sub-03'
             'sub-04'
             'sub-05'
             'sub-06'
             'sub-07'
             'sub-08'
             'sub-09'
             'sub-10'
             'sub-11'
             'sub-12'
             'sub-13'
             'sub-14'
             'sub-15'
             'sub-16'
             'sub-17'
             'sub-18'
             'sub-19'
             'sub-20'
                     
                     };
                 
%% TEST ONLY ONE SUBJECT
% index subjects from 1:20 according to how many you want to run (:) all

subjects = subjects(1);
                
%% SET PLOT DEFAULTS

set(0, 'defaultaxesfontsize', 18, 'defaultaxesfontweight', 'bold')

%% PLOT BETA TIMELOCKED
% uses: ft_selectdata

% options for the function
overwrite = false;
input = {'cropped_untimelocked_data'};
output = {'epochs/tfr_epochs'};
function_name = 'plot_tfr_epochs';

% build configuration
cfg = [];
cfg.select_data.channel = 'MEGGRAD';
cfg.events = {1 2 3 13 14 15};
cfg.xlim = [0.500 0.900];

% Run "loop_through_subjects" function
loop_through_subjects(subjects, data_dir, function_name, ...
                      cfg, output, input, figures_dir, overwrite);
                  
%% PLOT BETA POWER
% uses: ft_combineplanar

% options for the function
overwrite = false;
input = {'experimental_conditions_fourier' 'non_stimulation_fourier'};
output = {'epochs/epochs_power'};
function_name = 'plot_epochs_power';

% build configuration
cfg = [];
cfg.events = {1 2 3 13 14 15};
cfg.contrast_event = 21;

cfg.combine = [];
cfg.combine.method = 'svd';

% Run "loop_through_subjects" function
loop_through_subjects(subjects, data_dir, function_name, ...
                      cfg, output, input, figures_dir, overwrite);                  
%% SET PATHS

clear variables
restoredefaultpath; %% set a clean path
home_dir = '/home/lau/'; %% change according to your path
analysis_dir = 'analyses/omission_frontiers_BIDS-FieldTrip/';

matlab_dir = fullfile(home_dir, 'matlab'); % change according to your path
data_dir = fullfile(home_dir, analysis_dir, '/data');
figures_dir = []; % means no figures are saved
script_dir = fullfile(home_dir, analysis_dir, 'scripts', 'matlab');

%% ADD PATHS

% add your fieldtrip
addpath(fullfile(matlab_dir, 'fieldtrip-20170906'));
ft_defaults %% initialize FieldTrip defaults

% functions needed for analysis
addpath(fullfile(script_dir, 'general_functions'));
addpath(fullfile(script_dir, 'sensor_space_analysis_functions'));

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

%% DEFINE TRIALS AND PREPROCESS
% uses: ft_definetrial; ft_preprocessing, ft_appenddata,
% ft_redefinetrial and ft_resampledata

% options for the function
overwrite = false; %% should existing files be overwritten
input = {}; %% no MATLAB file format input
output = {'preprocessed_data'};
function_name = 'define_trials_and_preprocess_data';

% build configuration
cfg = []; %% initialize
cfg.input_file = 'oddball_absence-tsss-mc_meg';
cfg.input_extension = '.fif';
cfg.adjust_timeline = -41;% adjust offset of timeline by 41 msec (trigger delay)
cfg.downsample_to = 200; %% Hz, this speeds up processing

% Below two sub-configurations are built, for TRIAL DEFINITION and
% PREPROCESSING respectively

% TRIAL DEFINITION
cfg.trial_definition = [];
cfg.trial_definition.event_type = 'STI101'; %% trigger channel
cfg.trial_definition.pretrigger = 1.459; % s, preparing adjustment of 41 ms
cfg.trial_definition.posttrigger = 1.541; % s, same as above
cfg.trial_definition.trialfun = 'trial_function'; %trial func. (script_dir)

% PREPROCESSING
cfg.preprocessing = [];
cfg.preprocessing.demean = 'yes'; %% demean by baseline
cfg.preprocessing.baselinewindow = [-Inf Inf]; %% from beginning to end

% Run "loop_through_subjects" function
loop_through_subjects(subjects, data_dir, function_name, ...
                      cfg, output, input, figures_dir, overwrite);
                  
%% CLEAN DATA
% uses: ft_rejectvisual and ft_selectdata

% options for the function
overwrite = false;
input = {'preprocessed_data'};
output = {'cleaned_data'};
function_name = 'clean_data';

% build configuration
cfg = [];
cfg.channel_sets = {'MEGMAG' 'MEGGRAD'}; %% clean sequentially
cfg.keepchannel = 'yes'; % channels cannot be rejected, see ft_rejectvisual
cfg.layout = 'neuromag306all.lay'; % only MEG channels
cfg.keeptrial = 'nan'; % otherwise removed trials indices can't be written
cfg.filename = 'removed_trial_indices.tsv'; % name of tsv-file

% Run "loop_through_subjects" function
loop_through_subjects(subjects, data_dir, function_name, ...
                      cfg, output, input, figures_dir, overwrite);
                  
%% CLEAN DATA BASED ON TRIAL INDICES
% uses: ft_selectdata

% options for the function
overwrite = false;
input = {'preprocessed_data'};
output = {'cleaned_data'};
function_name = 'clean_data_based_on_trial_indices';

% build configuration
cfg =  [];
cfg.filename = 'removed_trial_indices.tsv';

% Run "loop_through_subjects" function
loop_through_subjects(subjects, data_dir, function_name, ...
                      cfg, output, input, figures_dir, overwrite);
           
%% DO INDEPENDENT COMPONENT ANALYSIS
% uses: ft_componentanalysis

% options for the function
overwrite = false;
input = {'cleaned_data'};
output = {'ica'};
function_name = 'run_ica';

% build configuration
cfg = [];
cfg.method = 'runica'; %% method see ft_componentanalysis
cfg.numcomponent = 60; %% number of components to decompose into
cfg.demean = 'no'; %% it has already been demeaned
cfg.channel = 'MEG'; %% only use MEG channels

% Run "loop_through_subjects" function
loop_through_subjects(subjects, data_dir, function_name, ...
                      cfg, output, input, figures_dir, overwrite);
                  
%% REMOVE COMPONENTS
% uses: ft_rejectcomponent

% options for the function
overwrite = false;
input = {'ica' 'cleaned_data'};
output = {'ica_cleaned_data'};
function_name = 'remove_components';

% build configuration
cfg = [];
cfg.demean = 'no';
cfg.filename = 'ica_components.tsv';

% Run "loop_through_subjects" function
loop_through_subjects(subjects, data_dir, function_name, ...
                      cfg, output, input, figures_dir, overwrite);
                                    
%% TIMELOCKED ANALYSIS
% uses: ft_timelockanalysis

% options for the function
overwrite = false;
input = {'ica_cleaned_data'};
output = {'timelocked_data'};
function_name = 'timelocked_analysis';

% build configuration
cfg = [];
cfg.events = {1 2 3 13 14 15 21};

% Run "loop_through_subjects" function
loop_through_subjects(subjects, data_dir, function_name, ...
                      cfg, output, input, figures_dir, overwrite);
                  
%% REMOVE AVERAGE RESPONSE FROM EACH EPOCH
% uses: None

% options for the function
overwrite = false;
input = {'ica_cleaned_data' 'timelocked_data'};
output = {'untimelocked_data'};
function_name = 'untimelocked_analysis';

% build configuration
cfg = [];
cfg.events = {1 2 3 13 14 15 21};

% Run "loop_through_subjects" function
loop_through_subjects(subjects, data_dir, function_name, ...
                      cfg, output, input, figures_dir, overwrite);
                  
%% TIME-FREQUENCY REPRESENTATION
% uses: ft_freqanalysis

% options for the function
overwrite = false;
input = {'untimelocked_data'};
output = {'tfr'};
function_name = 'time_frequency_representation';

% build configuration
cfg = [];
cfg.method = 'wavelet';
cfg.width = 7; %% width of wavelet
cfg.foilim = [1 40]; %% frequency limits (Hz)
cfg.toi = -1.500:0.005:1.500; %% times of interest (s)
cfg.pad = 'nextpow2';
cfg.events = {1 2 3 13 14 15 21};

% Run "loop_through_subjects" function
loop_through_subjects(subjects, data_dir, function_name, ...
                      cfg, output, input, figures_dir, overwrite);
                  
%% COMBINE GRADIOMETERS
% uses: ft_combineplanar

% options for the function
overwrite = false;
input = {'tfr'};
output = {'combined_tfr'};
function_name = 'combine_gradiometers';

% build configuration
cfg = [];
cfg.events = {1 2 3 13 14 15 21};

% Run "loop_through_subjects" function
loop_through_subjects(subjects, data_dir, function_name, ...
                      cfg, output, input, figures_dir, overwrite);
                  
%% BASELINE WITH NON-STIMULATION
% uses: None

% options for the function
overwrite = false;
input = {'combined_tfr'};
output = {'baselined_combined_tfr'};
function_name = 'baseline_tfr';

% build configuration
cfg = [];
cfg.events = {1 2 3 13 14 15};
cfg.baseline_event = 21;

% Run "loop_through_subjects" function
loop_through_subjects(subjects, data_dir, function_name, ...
                      cfg, output, input, figures_dir, overwrite);
%% SET PATHS

clear variables
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
addpath(fullfile(script_dir, 'plot_sensor_space_functions'));

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

set(0, 'defaultaxesfontsize', 30, 'defaultaxesfontweight', 'bold')
                 
%% PLOT RAW
% uses: ft_preprocessing, ft_appenddata and ft_databrowser

% options for the function
overwrite = true;
input = {};
output = {'raw/continuous'};
function_name = 'plot_raw';

% build configuration
cfg = [];
cfg.continuous = 'yes';
cfg.viewmode = 'vertical';
cfg.channel = 'MEG';
cfg.input_file = 'oddball_absence-tsss-mc_meg';
cfg.input_extension = '.fif';

% Run "loop_through_subjects" function
loop_through_subjects(subjects, data_dir, function_name, ...
                      cfg, output, input, figures_dir, overwrite);

%% PLOT EPOCHS
% uses: ft_databrowser

% options for the function
overwrite = false;
input = {'cleaned_data'};
output = {'epochs/butterfly_mag' 'epochs/butterfly_grad'};
function_name = 'plot_epochs';

% build configuration
cfg = [];
cfg.continuous = 'yes';
cfg.viewmode = 'butterfly';
cfg.channel_sets = {'MEGMAG' 'MEGGRAD'};

% Run "loop_through_subjects" function
loop_through_subjects(subjects, data_dir, function_name, ...
                      cfg, output, input, figures_dir, overwrite);
                  
%% PLOT BAD EPOCHS
% uses: ft_databrowser

% options for the function
overwrite = true;
input = {'preprocessed_data'};
output = {'epochs/butterfly_mag_bad' 'epochs/butterfly_grad_bad'};
function_name = 'plot_epochs';

% build configuration
cfg = [];
cfg.continuous = 'yes';
cfg.viewmode = 'butterfly';
cfg.channel_sets = {'MEGMAG' 'MEGGRAD'};
cfg.trial_indices_filename = 'removed_trial_indices.tsv';

% Run "loop_through_subjects" function
loop_through_subjects(subjects, data_dir, function_name, ...
                      cfg, output, input, figures_dir, overwrite);

%% PLOT INDEPENDENT COMPONENTS
% uses: ft_databrowser and ft_topoplotIC

% options for the function
overwrite = false;
input = {'ica'};
output = {'ica/ica_continuous' 'ica/ica_topoplot'};
function_name = 'plot_ica';

% build configuration
cfg = [];

cfg.continuous = [];
cfg.continuous.layout = 'neuromag306mag.lay';
cfg.continuous.viewmode = 'component';

cfg.topo = [];
cfg.topo.component = 1:60;
cfg.topo.layout = 'neuromag306mag.lay';
cfg.topo.comment = 'no';

% Run "loop_through_subjects" function
loop_through_subjects(subjects(1), data_dir, function_name, ...
                      cfg, output, input, figures_dir, overwrite);

%% PLOT TIMELOCKEDS
% uses: ft_multiplotER, ft_topoplotER

% options for the function
overwrite = false;
input = {'timelocked_data'};
output = {'timelockeds/multiplot' 'timelockeds/topoplot'};
function_name = 'plot_timelockeds';

% build configuration
cfg = [];
cfg.events = {1 2 3 13 14 15 21};

cfg.multiplot = [];
cfg.multiplot.layout = 'neuromag306mag.lay';

cfg.topoplot = [];
cfg.topoplot.layout = 'neuromag306mag.lay';
cfg.topoplot.xlim = [0.050 0.070]; % s
cfg.topoplot.zlim = [-3e-13 3e-13]; % Tesla (T)
cfg.topoplot.title_names = {'Standard 1' 'Standard 2' 'Standard 3' ...
                            'Omission 4' 'Omission 5' 'Omission 6' ...
                            'Non-Stimulation'};
cfg.topoplot.comment = 'no';
cfg.topoplot.custom_colorbar = 'yes';
cfg.topoplot.colorbar_label = 'Field Strength (T)';
    
% Run "loop_through_subjects" function
loop_through_subjects(subjects, data_dir, function_name, ...
                      cfg, output, input, figures_dir, overwrite);

%% PLOT TIME FREQUENCY REPRESENTATIONS
% uses: ft_singleplotTFR, ft_topoplotTFR

% options for the function
overwrite = false;
input = {'baselined_combined_tfr'};
output = {'tfr/singleplot' 'tfr/topoplot'};
function_name = 'plot_tfr';

% build configuration
cfg = [];
cfg.events = {1 2 3 13 14 15};
cfg.title_names = {'Standard 1' 'Standard 2' 'Standard 3' ...
    'Omission 4' 'Omission 5' 'Omission 6'};

cfg.singleplot = [];
cfg.singleplot.layout = 'neuromag306cmb.lay';
cfg.singleplot.channel = 'MEG0432+0433'; %% combined "tactile" channel
cfg.singleplot.zlim = [0.8 1.6];
cfg.singleplot.fontsize = 30;

cfg.topoplot = [];
cfg.topoplot.layout = 'neuromag306cmb.lay';
cfg.topoplot.xlim = [0.500 0.900]; % s
cfg.topoplot.ylim = [15 21]; % Hz
cfg.topoplot.zlim = [0.8 1.3]; % Power-ratio relative to non-stimulation
cfg.topoplot.comment = 'no';
cfg.topoplot.custom_colorbar = 'yes';
cfg.topoplot.colorbar_label = 'Power relative to non-stimulation';

% Run "loop_through_subjects" function
loop_through_subjects(subjects, data_dir, function_name, ...
                      cfg, output, input, figures_dir, overwrite);

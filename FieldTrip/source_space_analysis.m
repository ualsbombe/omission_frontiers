%% SET PATHS

clear variables
restoredefaultpath; %% set a clean path
home_dir = '/home/lau/'; %% change according to your path
analysis_dir = 'analyses/omission_frontiers_BIDS-FieldTrip/';

matlab_dir = fullfile(home_dir, 'matlab'); % change according to your path
data_dir = fullfile(home_dir, analysis_dir, '/data');
figures_dir = []; %fullfile(home_dir, analysis_dir, 'figures');
script_dir = fullfile(home_dir, analysis_dir, 'scripts', 'matlab');

%% ADD PATHS

% add your fieldtrip
addpath(fullfile(matlab_dir, 'fieldtrip-20170906'));
ft_defaults %% initialize FieldTrip defaults

% functions needed for analysis
addpath(fullfile(script_dir, 'general_functions'));
addpath(fullfile(script_dir, 'source_space_analysis_functions'));

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

subjects = subjects(11:20);

%% CROP DATA INTO TIMES OF INTEREST
% uses: ft_redefinetrial and ft_selectdata

% options for the function
overwrite = true;
input = {'untimelocked_data'};
output = {'cropped_untimelocked_data'};
function_name = 'crop_data';

% build configuration
cfg = [];
cfg.events = {1 2 3 13 14 15 21};

cfg.redefine_trial = [];
cfg.redefine_trial.toilim = [0.800 1.200]; % s

cfg.select_data = [];
cfg.select_data.channel = 'MEGGRAD'; % only gradiometers

% Run "loop_through_subjects" function
loop_through_subjects(subjects, data_dir, function_name, ...
                      cfg, output, input, figures_dir, overwrite);
                  
%% GET FOURIER ANALYSES
% uses: ft_freqanalysis and ft_appenddata

% options for the function
overwrite = true;
input = {'cropped_untimelocked_data'};
output = {'experimental_conditions_fourier' 'non_stimulation_fourier' ...
          'combined_fourier'};
function_name = 'get_fourier_transforms';

% build configuration
cfg = [];
cfg.events = {1 2 3 13 14 15};
cfg.contrast_event = 21;
cfg.method = 'mtmfft';
cfg.output = 'fourier';
cfg.pad = 'nextpow2';
cfg.taper = 'hanning';
cfg.channel = 'MEGGRAD';
cfg.foilim = [18 18];
cfg.keeptrials = 'yes';

% Run "loop_through_subjects" function
loop_through_subjects(subjects, data_dir, function_name, ...
                      cfg, output, input, figures_dir, overwrite);
                  
%% BEAMFORMER SOURCE RECONSTRUCTION
% uses: ft_sourceanalysis

% options for the function
overwrite = true;
input = {'experimental_conditions_fourier' 'non_stimulation_fourier' ...
         'combined_fourier' 'headmodel' 'leadfield'};
output = {'beamformer_contrasts'};
function_name = 'get_beamformer_contrasts';

% build configuration
cfg = [];
cfg.method = 'dics'; % Dynamic Imaging of Coherent Sources
cfg.frequency = 18; % Hz
cfg.channel = 'MEGGRAD';
cfg.senstype = 'MEG';
cfg.dics.projectnoise = 'yes';
cfg.dics.keepfilter = 'yes';
cfg.dics.realfilter = 'yes';
cfg.events = {1 2 3 13 14 15};
cfg.contrast_event = 21;

% Run "loop_through_subjects" function
loop_through_subjects(subjects, data_dir, function_name, ...
                      cfg, output, input, figures_dir, overwrite);
                  
%% INTERPOLATE ONTO COMMON TEMPLATE
% uses: ft_sourceinterpolate

% options for the function
overwrite = true;
input = {'beamformer_contrasts'};
output = {'beamformer_contrasts_interpolated'};
function_name = 'interpolate_beamformer';

% build configuration
cfg = [];
cfg.parameter = 'pow';
cfg.downsample = 2;
cfg.events = {1 2 3 13 14 15};
cfg.template_path = fullfile(matlab_dir, ['fieldtrip/template/' ...
                                          'headmodel/standard_mri.mat']);

% Run "loop_through_subjects" function
loop_through_subjects(subjects, data_dir, function_name, ...
                      cfg, output, input, figures_dir, overwrite); 
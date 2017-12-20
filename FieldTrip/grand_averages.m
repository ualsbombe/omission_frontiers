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
addpath(fullfile(script_dir, 'grand_average_functions'));

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

%% GRAND AVERAGE TIME-FREQUENCY REPRESENTATIONS
% uses: ft_freqgrandaverage

% options for the function
overwrite = false;
running_on_grand_average = false;
input = {'baselined_combined_tfr'};
output = {'grand_average_tfr'};
function_name = 'calculate_grand_average_tfr';

% build configuration
cfg = [];
cfg.events = {1 2 3 13 14 15};
cfg.foilim = 'all';
cfg.toilim = 'all';
cfg.channel = 'MEGGRAD';
cfg.parameter = 'powspctrm';
cfg.keepindividual = 'no'; 

% Run "apply_across_subjects" function
apply_across_subjects(subjects, data_dir, function_name, ...
                      cfg, output, input, figures_dir, overwrite, ...
                      running_on_grand_average);
                  
%% GRAND AVERAGE BEAMFORMER
% uses: ft_sourcegrandaverage

% options for the function
overwrite = false;
running_on_grand_average = false;
input = {'beamformer_contrasts'};
output = {'grand_average_beamformer'};
function_name = 'calculate_grand_average_beamformer';

% build configuration
cfg = [];
cfg.events = {1 2 3 13 14 15};
cfg.parameter = 'pow';
cfg.keepindividual = 'no';
cfg.template_path = fullfile(matlab_dir, 'fieldtrip', 'template', ...
                            'sourcemodel', ...
                            'standard_sourcemodel3d10mm.mat');

% Run "apply_across_subjects" function
apply_across_subjects(subjects, data_dir, function_name, ...
                      cfg, output, input, figures_dir, overwrite, ...
                      running_on_grand_average);
                  
%% INTERPOLATE GRAND AVERAGE BEAMFORMER
% uses: ft_sourceinterpolate

% options for the function
overwrite = false;
running_on_grand_average = true;
input = {'grand_average_beamformer'};
output = {'grand_average_beamformer_interpolated'};
function_name = 'interpolate_grand_average_beamformer';

% build configuration
cfg = [];
cfg.events = {1 2 3 13 14 15};
cfg.parameter = {'pow' 'inside'};
cfg.downsample = 2;
cfg.interpmethod = 'linear';
cfg.template_path = fullfile(matlab_dir, 'fieldtrip', 'template', ...
                            'headmodel', 'standard_mri.mat');

% Run "apply_across_subjects" function
apply_across_subjects(subjects, data_dir, function_name, ...
                      cfg, output, input, figures_dir, overwrite, ...
                      running_on_grand_average);
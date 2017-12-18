%% SET PATHS

clear variables
restoredefaultpath; %% set a clean path
home_dir = '/home/lau/'; %% change according to your path
analysis_dir = 'analyses/omission_frontiers_BIDS-FieldTrip';

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
addpath(fullfile(script_dir, 'plot_grand_averages_functions'));

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
                 
%% SET PLOT DEFAULTS

set(0, 'defaultaxesfontsize', 30, 'defaultaxesfontweight', 'bold')

%% PLOT GRAND AVERAGE TIME-FREQUENCY REPRESENTATION
% uses: ft_singleplotTFR and ft_topoplotTFR

% options for the function
overwrite = false;
running_on_grand_average = true;
input = {'grand_average_tfr'};
output = {'sensor_space/singleplot_tfr' 'sensor_space/topoplot_tfr'};
function_name = 'plot_grand_averages_tfr';

% build configuration
cfg = [];
cfg.events = {1 2 3 13 14 15};
cfg.title_names = {'Standard 1' 'Standard 2' 'Standard 3' ...
    'Omission 4' 'Omission 5' 'Omission 6'};

cfg.singleplot = [];
cfg.singleplot.layout = 'neuromag306cmb.lay';
cfg.singleplot.channel = 'MEG0432+0433'; %% combined "tactile" channel
cfg.singleplot.zlim = [0.8 1.6];

cfg.topoplot = [];
cfg.topoplot.layout = 'neuromag306cmb.lay';
cfg.topoplot.xlim = [0.500 0.900]; % s
cfg.topoplot.ylim = [15 21]; % Hz
cfg.topoplot.zlim = [0.8 1.3]; % Power-ratio relative to non-stimulation
cfg.topoplot.comment = 'no';
cfg.topoplot.custom_colorbar = 'yes';
cfg.topoplot.colorbar_label = 'Power relative to non-stimulation';

% Run "apply_across_subjects" function
apply_across_subjects(subjects, data_dir, function_name, ...
                      cfg, output, input, figures_dir, overwrite, ...
                      running_on_grand_average);
                  
%% PLOT GRAND AVERAGE TIME-FREQUENCY COMPARISON MASKED
% uses: ft_math, ft_singleplotTFR and ft_multiplotTFR

% options for the function
overwrite = true;
running_on_grand_average = true;
input = {'grand_average_tfr' 'statistics/statistics_tfr'};
output = {'sensor_space/singleplot_tfr_masked' ...
          'sensor_space/multiplot_tfr_masked'};
function_name = 'plot_grand_averages_tfr_masked';

% build configuration
cfg = [];
cfg.event_comparisons = {[1 3]};
cfg.title_names = {'Standard 1 vs Standard 3'};

cfg.singleplot = [];
cfg.singleplot.layout = 'neuromag306cmb.lay';
cfg.singleplot.channel = 'MEG0712+0713'; %% combined "tactile" channel
cfg.singleplot.zlim = [-0.1 0.1];
cfg.singleplot.colorbar_label = 'Difference';
cfg.singleplot.maskparameter = 'mask';

cfg.multiplot = [];
cfg.multiplot.layout = 'neuromag306cmb.lay';
% cfg.multiplot.xlim = [0.500 0.900]; % s
% cfg.mutliplot.ylim = [15 21]; % Hz
% cfg.topoplot.zlim = [0.8 1.3]; % Power-ratio relative to non-stimulation
cfg.multiplot.maskparameter = 'mask';

% Run "apply_across_subjects" function
apply_across_subjects(subjects, data_dir, function_name, ...
                      cfg, output, input, figures_dir, overwrite, ...
                      running_on_grand_average);
                  
%% PLOT GRAND AVERAGE BEAMFORMER
% uses: ft_sourceplot

% options for the function
overwrite = true;
running_on_grand_average = true;
input = {'grand_average_beamformer'};
output = {'source_space/surface_beamformer'};
function_name = 'plot_grand_averages_beamformer';

% build configuration
cfg = [];
cfg.events = {3};
cfg.title_names = {'Standard 3'}; %{'Standard 3'};
cfg.method = 'surface';
cfg.funparameter = 'pow';
cfg.colorbar = 'yes';
cfg.funcolorlim = [-0.25 0.25];
% cfg.atlas = fullfile(matlab_dir, 'fieldtrip', 'template', 'atlas', ...
%     'aal', 'ROI_MNI_V4.nii');

% Run "apply_across_subjects" function
apply_across_subjects(subjects, data_dir, function_name, ...
                      cfg, output, input, figures_dir, overwrite, ...
                      running_on_grand_average);
                  
%% PLOT GRAND AVERAGE BEAMFORMER MASKED
% uses: ft_math, ft_sourceplot

% options for the function
overwrite = true;
running_on_grand_average = true;
input = {'grand_average_beamformer_interpolated' ...
         'statistics/statistics_beamformer_interpolated'};
output = {'source_space/beamformer_masked'};
function_name = 'plot_grand_averages_beamformer_masked';

% build configuration
cfg = [];
cfg.event_comparisons = {[1 3]};
cfg.title_names = {'Standard 1 vs Standard 3'};
cfg.method = 'ortho';
cfg.funparameter = 'pow';
cfg.maskparameter = 'mask';
cfg.funcolormap = 'jet';
cfg.funcolorlim = [-0.2 0.2];
cfg.crosshair = 'no';
cfg.location = [-34 -21 58];
cfg.atlas = fullfile(matlab_dir, 'fieldtrip', 'template', 'atlas', ...
    'aal', 'ROI_MNI_V4.nii');

% Run "apply_across_subjects" function
apply_across_subjects(subjects, data_dir, function_name, ...
                      cfg, output, input, figures_dir, overwrite, ...
                      running_on_grand_average);                 
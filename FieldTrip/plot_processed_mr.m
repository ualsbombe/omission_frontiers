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
addpath(fullfile(script_dir, 'plot_processed_mr_functions'));

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

subjects = subjects(2);
                
%% SET PLOT DEFAULTS

set(0, 'defaultaxesfontsize', 30, 'defaultaxesfontweight', 'bold')

%% PLOT MRI
% uses: ft_sourceplot

% options for the function
overwrite = false;
input = {'mri' 'mri_realigned_fiducials' ...
         'mri_realigned_digitization_points'};
output = {'mri/mri_original' 'mri/mri_realigned_fiducals' ...
          'mri/mri_realigned_digitization'};
function_name = 'plot_mri';

% build configuration
cfg = [];

% Run "loop_through_subjects" function
loop_through_subjects(subjects, data_dir, function_name, ...
                      cfg, output, input, figures_dir, overwrite);
                  
%% PLOT QUALITY FIGURES
% uses: ft_sourceplot, ft_plot_sens, ft_plot_headshape, ft_plot_vol,
% ft_plot_axes, ft_plot_ortho, ft_plot_montage, ft_prepare_mesh,
% ft_convert_units and ft_plot_mesh

% options for the function
overwrite = true;
input = {'headmodel' 'mri_realigned_digitization_points' 'mri_segmented'};
output = {'mri/sens_headshape_mri_axes' ...
          'mri/anat_mriseg' ...
          'mri/plot_ortho' ...
          'mri/MRI_headmontage' ...
          'mri/MRI_pol' ...
          'mri/MRI_anat' ...
          'mri/scalp_anat'
          };
function_name = 'plot_quality_control_figures';

% build configuration
cfg = [];
cfg.headshape_file = 'oddball_absence-tsss-mc_meg.fif';

% Run "loop_through_subjects" function
loop_through_subjects(subjects, data_dir, function_name, ...
                      cfg, output, input, figures_dir, overwrite);

%% PLOT HEAD MODEL AND GRID 
% uses: ft_plot_mesh and ft_plot_vol

% options for the function
overwrite = true;
input = {'headmodel' 'warped_grid'};
output = {'mri/headmodel_inside_grid';
          };
function_name = 'plot_headmodel_inside_grid';

% build configuration
cfg = [];
cfg.view = [222 18];

% Run "loop_through_subjects" function
loop_through_subjects(subjects, data_dir, function_name, ...
                      cfg, output, input, figures_dir, overwrite);

%% SET PATHS

clear variables
restoredefaultpath; %% set a clean path
home_dir = '/home/lau/'; %% change according to your path
analysis_dir = 'analyses/omission_frontiers_BIDS-FieldTrip/';

matlab_dir = fullfile(home_dir, 'matlab'); % change according to your path
data_dir = fullfile(home_dir, analysis_dir, '/figures');
figures_dir = fullfile(home_dir, analysis_dir, 'figures');
script_dir = fullfile(home_dir, analysis_dir, 'scripts', 'matlab');

%% ADD PATHS

% add your fieldtrip
addpath(fullfile(matlab_dir, 'fieldtrip-20170906'));
ft_defaults %% initialize FieldTrip defaults

% functions needed for analysis
addpath(fullfile(script_dir, 'general_functions'));

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

%% CREATE IMAGE FILES FROM FIGURE FILES
% uses: None

% options for the function
overwrite = false; %% should existing files be overwritten
input = {
%          'epochs/butterfly_mag' 
%          'epochs/epochs_power' 
%          'epochs/tfr_epochs' 
%          'ica/ica_topoplot' 
%          'raw/continuous' 
%          'tfr/singleplot' 
%          'tfr/topoplot' 
%          'timelockeds/multiplot' 
%          'timelockeds/topoplot' 
%          'mri/sens_headshape_mri_axes'
%          'mri/headmodel_inside_grid'
         };
format = '-djpeg'; % see matlab print command
resolution = '-r300';

% Run "create_image_files_from_figure_files" function
create_image_files_from_figure_files(subjects, figures_dir, ...
                                     input, format, resolution, overwrite);
                                 
%% CREATE IMAGE FILES FROM FIGURE FILES GRAND AVERAGE
% uses: None

% options for the function
overwrite = false; %% should existing files be overwritten
input = {
%          'sensor_space/singleplot_tfr'
         'sensor_space/singleplot_tfr_masked' 
%          'sensor_space/multiplot_tfr_masked'
%          'sensor_space/topoplot_tfr'
%          'source_space/surface_beamformer' 
%          'source_space/beamformer_masked' 
%          'source_space/surface_beamformer_for_cookbook'
         };
format = '-djpeg'; % see matlab print command
resolution = '-r300';
subjects = {'grand_averages'};

% Run "create_image_files_from_figure_files" function
create_image_files_from_figure_files(subjects, ...
                                    figures_dir, input, format, ...
                                    resolution, overwrite);
%% SET PATHS

clear variables
restoredefaultpath; %% set a clean path
home_dir = '/home/lau/'; % change according to your path, also analysis_dir
analysis_dir = 'analyses/omission_frontiers_BIDS-FieldTrip/';

matlab_dir = fullfile(home_dir, 'matlab'); % change according to your path
data_dir = fullfile(home_dir, analysis_dir, 'data');
figures_dir = fullfile(home_dir, analysis_dir, 'figures');
script_dir = fullfile(home_dir, analysis_dir, 'scripts', 'matlab');

%% SUBJECTS

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
                 
%% CREATE DATA AND FIGURE DIRECTORIES

n_subjects = length(subjects);
figure_subfolders = {'ica' 'raw' 'epochs' 'timelockeds' 'tfr' 'mri' ...
                     'beamformer'};
n_figure_subfolders = length(figure_subfolders);

for subject_index = 1:n_subjects
    
    subject = subjects{subject_index};
    MEG_path_subject = fullfile(data_dir, subject, 'ses-meg', 'meg');
    MRI_path_subject = fullfile(data_dir, subject, 'ses-mri', 'anat');
    % create subject folder MEG
    [SUCCESS_MEG, ~, ~] = mkdir(MEG_path_subject);
    [SUCCESS_MRI, ~, ~] = mkdir(MRI_path_subject);
    if SUCCESS_MEG
        disp([MEG_path_subject ' was created'])
    else
        error(['Something is wrong with the path you set: ' ...
                MEG_path_subject]);
    end
    if SUCCESS_MRI
        disp([MRI_path_subject ' was created']);
    else
        error(['Something is wrong with the path you set: ' ...
               MRI_path_subject]);
    end
        
    % create figure subfolders
    for figure_subfolder_index = 1:n_figure_subfolders
        
        figure_subfolder = figure_subfolders{figure_subfolder_index};
        figure_subfolder_path = fullfile(figures_dir, subject, ...
                                figure_subfolder);
        [SUCCESS, ~, ~] = mkdir(figure_subfolder_path);
        if SUCCESS
            disp([figure_subfolder_path ' was created'])
        else
            error(['Something is wrong with the path you set: ' ...
                    figure_subfolder_path]);
        end
        
    end
    
end

% create grand average folders (with statistics sub-directory)
grand_average_path = fullfile(data_dir, 'grand_averages', 'statistics');
[SUCCESS, ~, ~] = mkdir(grand_average_path);
if SUCCESS
    disp([grand_average_path ' was created'])
else
    error(['Something is wrong with the path you set: ' ...
                    grand_average_path]);
end
% and grand averages figures path
figure_subfolders = {'sensor_space' 'source_space/statistics'};
n_figure_subfolders = length(figure_subfolders);

for figure_subfolder_index = 1:n_figure_subfolders
    figure_subfolder = figure_subfolders{figure_subfolder_index};
    grand_average_figure_path = fullfile(figures_dir, 'grand_averages', ...
                                         figure_subfolder);
    [SUCCESS, ~, ~] = mkdir(grand_average_figure_path);
    if SUCCESS
        disp([grand_average_figure_path ' was created'])
    else
        error(['Something is wrong with the path you set' ...
               grand_average_figure_path]);
    end                           
end
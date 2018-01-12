# -*- coding: utf-8 -*-
"""
Pipeline for group analysis of MEG data
@author: Lau Møller Andersen
@email: lau.moller.andersen@ki.se | lau.andersen@cnru.dk
@github: https://github.com/ualsbombe/omission_frontiers.git
"""

#==============================================================================
# SET HOME PATH
#%%============================================================================

home_path = '/home/lau/' ## change this according to needs

#==============================================================================
# IMPORTS 
#%%============================================================================

from os.path import join
from analysis_functions_frontiers import operations_functions as operations
from analysis_functions_frontiers import io_functions as io
from analysis_functions_frontiers import plot_functions as plot

#==============================================================================
# PATHS 
#%%============================================================================

project_name = 'analyses/omission_frontiers_BIDS-MNE-Python/'
data_path = join(home_path, project_name, 'data/')
subjects_dir = join(home_path, project_name, 'data/FreeSurfer/')
name = 'oddball_absence'
save_dir_averages = data_path + 'grand_averages/'
figures_path = join(home_path, project_name, 'figures/')

subjects = [
                         'sub-01',
                         'sub-02',
                         'sub-03',
                         'sub-04',
                         'sub-05',
                         'sub-06',
                         'sub-07',
                         'sub-08',
                         'sub-09',
                         'sub-10',
                         'sub-11',
                         'sub-12',
                         'sub-13',
                         'sub-14',
                         'sub-15',
                         'sub-16',
                         'sub-17',
                         'sub-18',
                         'sub-19',
                         'sub-20'
                     ]
subjects_to_run = (None, None) ## means all subjects
#subjects_to_run = (0, 1)# subject indices to run, if you don't want to run all
                              
#==============================================================================
# OPERATIONS                     
#%%============================================================================
operations_to_apply = dict(

                    ## OS commands

                    populate_data_directory=0,
                    
                    ## WITHIN SUBJECT                    
                    
                    ## sensor space operations
                    filter_raw=0,
                    find_events=0,
                    epoch_raw=0,
                    run_ica=0,
                    apply_ica=0,
                    get_evokeds=0,
                    
                    ## source space operations
                    import_mri=0,
                    segment_mri=0, # long process (>6 h)
                    apply_watershed=0,
                    make_source_space=0,
                    make_dense_scalp_surfaces=0,
                    make_bem_solutions=0,
                    create_forward_solution=0,
                    estimate_noise_covariance=0, 
                    create_inverse_operator=0,
                    source_estimate=0,
                    morph_to_fsaverage=0,
                    
                    ## BETWEEN SUBJECTS
                    
                    ## compute grand averages
                    grand_averages_evokeds=0, # sensor space                    
                    average_morphed_data=0, # source space
                    
                    ## PLOTTING                    
                    
                    ## plotting sensor space (within subject)
                    plot_maxfiltered=0,
                    plot_filtered=0,
                    plot_power_spectra=0,
                    plot_ica=0,
                    plot_epochs_image=0,
                    plot_evokeds=0,
                    plot_butterfly_evokeds=0,
                    
                    ## plotting source space (within subject)
                    plot_transformation=1,
                    plot_source_space=0,
                    plot_noise_covariance=0,
                    plot_source_estimates=0,
                    
                    ## plotting sensor space (between subjects)
                    plot_grand_averages_evokeds=0,
                    plot_grand_averages_butterfly_evokeds=0,
                    
                    ## plotting source space (between subjects)
                    plot_grand_averages_source_estimates=0,
                    
                    ## statistics in source space
                    statistics_source_space=0,
                    
                    ## plot source space with statistics mask
                    plot_grand_averages_source_estimates_cluster_masked=0
                )
                                  
#==============================================================================
# PARAMETERS                     
#%%============================================================================
## should files be overwritten
overwrite = False ## this counts for all operations below that save output
save_plots = True ## should plots be saved
                    
## raw        
lowpass = 70 ## Hz

bad_channels_dict = dict()
bad_channels_dict[subjects[0]] = []
bad_channels_dict[subjects[1]] = []
bad_channels_dict[subjects[2]] = []
bad_channels_dict[subjects[3]] = []
bad_channels_dict[subjects[4]] = []
bad_channels_dict[subjects[5]] = []
bad_channels_dict[subjects[6]] = ['MEG0111', 'MEG0121']
bad_channels_dict[subjects[7]] = ['MEG1411', 'MEG1421', 'MEG2121']
bad_channels_dict[subjects[8]] = ['MEG1531', 'MEG1541', 'MEG1711', 'MEG0141']
bad_channels_dict[subjects[9]] = []
bad_channels_dict[subjects[10]] = []
bad_channels_dict[subjects[11]] = []
bad_channels_dict[subjects[12]] = ['MEG0111', 'MEG0121']
bad_channels_dict[subjects[13]] = ['MEG0111', 'MEG0121', 'MEG0141']
bad_channels_dict[subjects[14]] = []
bad_channels_dict[subjects[15]] = []
bad_channels_dict[subjects[16]] = ['MEG0111', 'MEG0121']
bad_channels_dict[subjects[17]] = []
bad_channels_dict[subjects[18]] = []
bad_channels_dict[subjects[19]] = []

## events
adjust_timeline_by_msec = 41 ## delay to stimulus            

## epochs
stim_channel = 'STI101'
min_duration = 0.002 # s
event_id = dict(standard_1=1, standard_2=2,
                standard_3=3, standard_4=4, standard_5=5,
                omission_4=13, omission_5=14, omission_6=15,
                non_stimulation=21)
tmin = -0.200 # s
tmax = 1.000 # s
baseline = (None, 0) # from tmin to 0
reject = dict(grad=400e-12, mag=4e-12) # T/cm and T
decim = 1 ## downsampling factor

## source reconstruction
method = 'dSPM'

## grand averages
    ## empty containers to the put the single subjects data in
evoked_data_all = dict(standard_1=[], standard_2=[], standard_3=[],
                            standard_4=[], standard_5=[], omission_4=[],
                            omission_5=[], omission_6=[], non_stimulation=[])
morphed_data_all = evoked_data_all.copy()
                        
## plotting
mne_evoked_time = 0.056 ## s

## statistics
independent_variable_1 = 'standard_3'
independent_variable_2 = 'non_stimulation'
time_window = (0.050, 0.060)
n_permutations = 10000 ## specify as integer

## statistics plotting
p_threshold = 1e-15 ## 1e-15 is the smallest it can get for the way it is coded

## freesurfer and MNE-C commands
n_jobs_freesurfer = 32 ## change according to amount of processors you have
                        # available
source_space_method = ['ico', 5] ## supply a method and a spacing/grade
                                  # see mne_setup_source_space --help in bash
                                  # methods 'spacing', 'ico', 'oct'

#==============================================================================
# PROCESSING LOOP 
#%%============================================================================            
for subject in subjects[subjects_to_run[0]:subjects_to_run[1]]:
        
    subject_index = subjects.index(subject)                                             
    save_dir = join(data_path, subject, 'ses-meg', 'meg')
    dicom_path = join(data_path, subject, 'ses-mri', 'anat')
    bad_channels = bad_channels_dict[subject]
    
    #==========================================================================
    # POPULATE SUBJECT DIRECTORIES
    #==========================================================================

    if operations_to_apply['populate_data_directory']:
        operations.populate_data_directory(home_path, project_name, data_path,
                                           figures_path,
                                           subjects_dir, subjects)        
        
    #==========================================================================
    # FILTER RAW (MAXFILTERED)
    #==========================================================================

    if operations_to_apply['filter_raw']:
        operations.filter_raw(name, save_dir, lowpass, overwrite=overwrite)        
    
    #==========================================================================
    # PLOT RAW DATA
    #========================================================================== 
    
    if operations_to_apply['plot_maxfiltered']:
        plot.plot_maxfiltered(name, save_dir)
        
    if operations_to_apply['plot_filtered']:
        plot.plot_filtered(name, save_dir, lowpass)     
    
    #==========================================================================
    # PLOT POWER SPECTRA
    #==========================================================================        
    
    if operations_to_apply['plot_power_spectra']:
        plot.plot_power_spectra(name, save_dir, lowpass, subject, save_plots,
                                figures_path)
    
    #==========================================================================
    # FIND EVENTS
    #==========================================================================      
    
    if operations_to_apply['find_events']:
        
        operations.find_events(name, save_dir, stim_channel, min_duration,
                               adjust_timeline_by_msec, lowpass,
                               overwrite=overwrite)
                            
    #==========================================================================
    # EPOCHS
    #==========================================================================  
             
    if operations_to_apply['epoch_raw']:                  
        operations.epoch_raw(name, save_dir, lowpass, event_id, tmin,
                          tmax, baseline, reject, bad_channels, decim,
                          overwrite=overwrite)    

    #==========================================================================
    # INDEPENDENT COMPONENT ANALYSIS
    #==========================================================================                              
    
    if operations_to_apply['run_ica']:
        operations.run_ica(name, save_dir, lowpass, overwrite=overwrite)
        
    #===========================================================================
    # PLOT COMPONENTS TO BE REMOVED            
    #===========================================================================
         
    if operations_to_apply['plot_ica']:
        plot.plot_ica(name, save_dir, lowpass, subject, save_plots,
                      figures_path)
        
    #==========================================================================
    # LOAD NON-ICA'ED EPOCHS AND APPLY ICA
    #========================================================================== 
        
    if operations_to_apply['apply_ica']:
        operations.apply_ica(name, save_dir, lowpass, overwrite=overwrite)
        
    #==========================================================================
    # PLOT CLEANED EPOCHS
    #========================================================================== 
        
    if operations_to_apply['plot_epochs_image']:
        plot.plot_epochs_image(name, save_dir, lowpass, subject, save_plots,
                               figures_path)

    #==========================================================================
    # EVOKEDS
    #==========================================================================                                                      

    if operations_to_apply['get_evokeds']:   
        operations.get_evokeds(name, save_dir, lowpass, overwrite=overwrite)
                                                                                                 
    #==========================================================================
    # PLOT EVOKEDS
    #==========================================================================                                                                                                     
        
    if operations_to_apply['plot_evokeds']:
        plot.plot_evokeds(name, save_dir, lowpass, subject, save_plots,
                          figures_path)
    
    if operations_to_apply['plot_butterfly_evokeds']:
        plot.plot_butterfly_evokeds(name, save_dir, lowpass, subject,
                                    save_plots, figures_path)
  
    #==========================================================================
    # NOISE COVARIANCE MATRIX
    #==========================================================================

    if operations_to_apply['estimate_noise_covariance']:
        operations.estimate_noise_covariance(name, save_dir, lowpass, 
                                          overwrite=overwrite)

    if operations_to_apply['plot_noise_covariance']:
        plot.plot_noise_covariance(name, save_dir, lowpass, subject,
                                   save_plots, figures_path)

    #==========================================================================
    # IMPORT AND SEGMENT MRI, RUN WATERSHED (BASH COMMANDS;
    # MAKE SURE SUBJECTS_DIR IS SET CORRECTLY IN BASH)
    #==========================================================================        

    if operations_to_apply['import_mri']:
        operations.import_mri(dicom_path, subject, subjects_dir,
                              n_jobs_freesurfer)

    if operations_to_apply['segment_mri']:
        operations.segment_mri(subject, subjects_dir, n_jobs_freesurfer)

    if operations_to_apply['apply_watershed']:
        operations.apply_watershed(subject, subjects_dir, overwrite)
        
    if operations_to_apply['make_dense_scalp_surfaces']:
        operations.make_dense_scalp_surfaces(subject, subjects_dir, overwrite)
        
    if operations_to_apply['make_source_space']:
        operations.make_source_space(subject, subjects_dir, source_space_method, 
                                     overwrite)
                                     
    if operations_to_apply['make_bem_solutions']:
        operations.make_bem_solutions(subject, subjects_dir)                                     
                                          
    #==========================================================================
    # SOURCE SPACES
    #==========================================================================
                                                                                    
    if operations_to_apply['plot_source_space']:
        plot.plot_source_space(name, subject, subjects_dir, save_plots,
                               figures_path)                                          

    #==========================================================================
    # CO-REGISTRATION
    #==========================================================================                                   

    ## use mne.gui.coregistration()

    if operations_to_apply['plot_transformation']:
        plot.plot_transformation(name, save_dir, subject, subjects_dir,
                                 save_plots, figures_path)                                      

    #==========================================================================
    # CREATE FORWARD MODEL
    #==========================================================================

    if operations_to_apply['create_forward_solution']:
        operations.create_forward_solution(name, save_dir, subject,
                                           subjects_dir, overwrite=overwrite)
                                        
    #==========================================================================
    # CREATE INVERSE OPERATOR
    #==========================================================================                                          
        
    if operations_to_apply['create_inverse_operator']:
        operations.create_inverse_operator(name, save_dir, lowpass,
                                        overwrite=overwrite)                                                
                                                                                           
    #==========================================================================
    # SOURCE ESTIMATE MNE                                
    #==========================================================================

    if operations_to_apply['source_estimate']:
        operations.source_estimate(name, save_dir, lowpass, method, overwrite)
        
    #==========================================================================
    # PLOT SOURCE ESTIMATES MNE
    #==========================================================================                                                      

    if operations_to_apply['plot_source_estimates']:        
        plot.plot_source_estimates(name, save_dir, lowpass,
                                      subject, subjects_dir,
                                      method, mne_evoked_time,
                                      save_plots, figures_path)
                                                                                                       
    #==========================================================================
    # MORPH TO FSAVERAGE
    #==========================================================================                                  
        
    if operations_to_apply['morph_to_fsaverage']:
        stcs = operations.morph_data_to_fsaverage(name, save_dir,
                                        subjects_dir, subject,
                                        lowpass,
                                        method=method,
                                        overwrite=overwrite)
                                        
    #==========================================================================
    # GRAND AVERAGE EVOKEDS (within-subject part)                                     
    #==========================================================================
                                     
    if operations_to_apply['grand_averages_evokeds']:
        evoked_data = io.read_evokeds(name, save_dir, lowpass)
        for evoked in evoked_data:
            trial_type = evoked.comment
            evoked_data_all[trial_type].append(evoked)                                                
  
                                                                                
    #==========================================================================
    # GRAND AVERAGE MORPHED DATA (within-subject part)
    #==========================================================================                       
            
    if operations_to_apply['average_morphed_data'] or \
        operations_to_apply['statistics_source_space']:
        morphed_data = io.read_source_estimates(name, save_dir, lowpass,
                                                method=method,
                                                morphed=True)
        for trial_type in morphed_data:
            morphed_data_all[trial_type].append(morphed_data[trial_type])                                                                           
    
# GOING OUT OF SUBJECT LOOP (FOR AVERAGES)    

#==============================================================================
# GRAND AVERAGES (sensor space and source space)
#==============================================================================

if operations_to_apply['grand_averages_evokeds']:
    operations.grand_average_evokeds(evoked_data_all, save_dir_averages,
                                     lowpass)
    
if operations_to_apply['average_morphed_data']:
    operations.average_morphed_data(morphed_data_all, method,
                                 save_dir_averages, lowpass)
                                 
#==============================================================================
# GRAND AVERAGES PLOTS (sensor space and source space)
#==============================================================================

if operations_to_apply['plot_grand_averages_evokeds']:
    plot.plot_grand_average_evokeds(name, lowpass, save_dir_averages,
                                    evoked_data_all,
                                    save_plots, figures_path)
                                    
if operations_to_apply['plot_grand_averages_butterfly_evokeds']:
    plot.plot_grand_averages_butterfly_evokeds(name, lowpass, save_dir_averages,
                                               save_plots, figures_path)                                    
                                    
if operations_to_apply['plot_grand_averages_source_estimates']:
    plot.plot_grand_averages_source_estimates(name, save_dir_averages, lowpass,
                                              subjects_dir, method,
                                              mne_evoked_time, save_plots,
                                              figures_path)
        
#==============================================================================
# STATISTICS SOURCE SPACE        
#==============================================================================
                                                   
if operations_to_apply['statistics_source_space']:
    operations.statistics_source_space(morphed_data_all, save_dir_averages,
                                       independent_variable_1,
                                       independent_variable_2,
                                       time_window, n_permutations, lowpass,
                                       overwrite)
                                       
#==============================================================================
# PLOT GRAND AVERAGES OF SOURCE ESTIMATES WITH STATISTICS CLUSTER MASK                                        
#==============================================================================

if operations_to_apply['plot_grand_averages_source_estimates_cluster_masked']:
    plot.plot_grand_averages_source_estimates_cluster_masked(
        name, save_dir_averages, lowpass, subjects_dir, method, time_window,
        save_plots, figures_path, independent_variable_1,
        independent_variable_2, mne_evoked_time, p_threshold)

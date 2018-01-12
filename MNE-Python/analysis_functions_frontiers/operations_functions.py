# -*- coding: utf-8 -*-
"""
Pipeline for group analysis of MEG data - operations functions
@author: Lau Møller Andersen
@email: lau.moller.andersen@ki.se | lau.andersen@cnru.dk
@github: https://github.com/ualsbombe/omission_frontiers.git
"""
from __future__ import print_function

import mne
import numpy as np
from os.path import join, isfile, isdir
from scipy import stats
from os import makedirs, listdir, environ
import sys
from . import io_functions as io
import pickle
import subprocess

def filter_string(lowpass):
    
    filter_string = '_' + str(lowpass) + '_Hz'
    
    return filter_string
     
#==============================================================================
# OPERATING SYSTEM COMMANDS    
#==============================================================================
   
def populate_data_directory(home_path, project_name, data_path, figures_path,
                            subjects_dir, subjects):
    
    ## create MEG and MRI paths   
    for subject in subjects:

        full_path_MEG = join(home_path, project_name, data_path, subject,
                             'ses-meg', 'meg')
        full_path_MRI = join(home_path, project_name,
                             data_path, subject, 'ses-mri', 'anat')
        ## create MEG dirs
        try:
            makedirs(full_path_MEG)
            makedirs(full_path_MRI)
            print(full_path_MEG + ' has been created')
            print(full_path_MRI + ' has been created')
        except OSError as exc:
            if exc.errno == 17: ## dir already exists
                pass
            
    ## also create grand averages path with a statistics folder
    grand_average_path = join(home_path, project_name, data_path,
                              'grand_averages/statistics')
    try:
        makedirs(grand_average_path)         
        print(grand_average_path + ' has been created')
    except OSError as exc:
        if exc.errno == 17: ## dir already exists
            pass         

    ## also create figures path
    figure_subfolders = ['power_spectra_raw', 'evokeds', 'ica', 'stcs',
                         'transformation', 'epochs', 'source_space',
                         'noise_covariance']
    for subject in subjects:
        for figure_subfolder in figure_subfolders:
            full_path_figures = join(home_path, project_name, figures_path,
                                     subject, figure_subfolder)
            ## create figure paths
            try:
                makedirs(full_path_figures)
                print(full_path_figures + ' has been created')
            except OSError as exc:
                if exc.errno == 17: ## dir already exists
                    pass
                
    ## also create grand average figures path
    grand_averages_figures_path = join(home_path, project_name, figures_path,
                                      'grand_averages')
    figure_subfolders = ['sensor_space', 'source_space/statistics']
    for figure_subfolder in figure_subfolders:
        try:
            full_path = join(grand_averages_figures_path, figure_subfolder)
            makedirs(full_path)
            print(full_path + ' has been created')
        except OSError as exc:
            if exc.errno == 17: ## dir already exists
                pass
            
    ## also create FreeSurfer path
    freesurfer_path = join(home_path, project_name, subjects_dir)
    try:
        makedirs(freesurfer_path)
        print(freesurfer_path + ' has been created')
    except OSError as exc:
        if exc.errno == 17: ## dir already exists
            pass
                        
#==============================================================================
# PREPROCESSING AND GETTING TO EVOKED AND TFR
#==============================================================================
    
def filter_raw(name, save_dir, lowpass, overwrite):
    
    filter_name = name  + filter_string(lowpass) + '-raw.fif'
    filter_path = join(save_dir, filter_name)
    if overwrite or not isfile(filter_path):
    
        raw = io.read_maxfiltered(name, save_dir)
        raw.filter(None, lowpass)
        
        filter_name = name  + filter_string(lowpass) + '-raw.fif'
        filter_path = join(save_dir, filter_name)
        raw.save(filter_path, overwrite=True)
        
    else:
        print('raw file: ' + filter_path + ' already exists')
    
def find_events(name, save_dir, stim_channel, min_duration,
                adjust_timeline_by_msec, lowpass, overwrite):

    events_name = name + '-eve.fif'
    events_path = join(save_dir, events_name)              
    if overwrite or not isfile(events_path):
                      
        raw = io.read_filtered(name, save_dir, lowpass)
        events = mne.find_events(raw, stim_channel, min_duration=min_duration)
        events[:, 0] = [ts + np.round(adjust_timeline_by_msec * 10**-3 * \
                    raw.info['sfreq']) for ts in events[:, 0]] 
                      
        mne.event.write_events(events_path, events)
            
    else:
        print('event file: '+ events_path + ' already exists')
          
def epoch_raw(name, save_dir, lowpass, event_id, tmin, tmax,
              baseline, reject, bad_channels, decim, overwrite):
                  
    epochs_name = name + filter_string(lowpass) + '-epo.fif'
    epochs_path = join(save_dir, epochs_name)                       
    if overwrite or not isfile(epochs_path):
        
        events = io.read_events(name, save_dir)
        raw = io.read_filtered(name, save_dir, lowpass,)
        raw.info['bads'] = bad_channels
        picks = mne.pick_types(raw.info, meg=True, eog=True, ecg=True, 
                               exclude='bads')
            
        epochs = mne.Epochs(raw, events, event_id, tmin, tmax, baseline,
                            reject=reject, preload=True, picks=picks,
                            decim=decim)
    
        epochs.save(epochs_path)  
        
    else:
        print('epochs file: '+ epochs_path + ' already exists')
            
def run_ica(name, save_dir, lowpass, overwrite):
    
    ica_name = name + filter_string(lowpass) + '-ica.fif'
    ica_path = join(save_dir, ica_name)
    
    if overwrite or not isfile(ica_path):

        raw = io.read_filtered(name, save_dir, lowpass) 
        epochs = io.read_epochs(name, save_dir, lowpass)
        
        ica = mne.preprocessing.ICA(n_components=0.95, method='fastica')
        ica.fit(epochs)
        
        eog_epochs = mne.preprocessing.create_eog_epochs(raw)
        ecg_epochs = mne.preprocessing.create_ecg_epochs(raw)
        
        eog_indices, eog_scores = ica.find_bads_eog(eog_epochs)
        ecg_indices, ecg_scores = ica.find_bads_ecg(ecg_epochs)
        
        ica.exclude += eog_indices
        ica.exclude += ecg_indices

        ica.save(ica_path)
        
    else:
        print('ica file: '+ ica_path + ' already exists')

def apply_ica(name, save_dir, lowpass, overwrite):
    
    ica_epochs_name = name + filter_string(lowpass) + '-ica-epo.fif'        
    ica_epochs_path = join(save_dir, ica_epochs_name)
        
    if overwrite or not isfile(ica_epochs_path):

        epochs = io.read_epochs(name, save_dir, lowpass)
        ica = io.read_ica(name, save_dir, lowpass)
        
        ica_epochs = ica.apply(epochs)
        
        ica_epochs.save(ica_epochs_path)
        
    else:
        print('ica epochs file: '+ ica_epochs_path + ' already exists')

def get_evokeds(name, save_dir, lowpass, overwrite):
    
    evokeds_name = name + filter_string(lowpass) + '-ave.fif'    
    evokeds_path = join(save_dir, evokeds_name)
    if overwrite or not isfile(evokeds_path):

        epochs = io.read_ica_epochs(name, save_dir, lowpass)
    
        evokeds = []
    
        for trial_type in epochs.event_id:     
            evokeds.append(epochs[trial_type].average())
    
        mne.evoked.write_evokeds(evokeds_path, evokeds)
        
    else:
        print('evokeds file: '+ evokeds_path + ' already exists')
        
def grand_average_evokeds(evoked_data_all, save_dir_averages, lowpass):

    grand_averages = dict()
    for trial_type in evoked_data_all:
        grand_averages[trial_type] = \
            mne.evoked.grand_average(evoked_data_all[trial_type])
            
    for trial_type in grand_averages:
        grand_average_path = save_dir_averages + \
            trial_type +  filter_string(lowpass) + \
            '_grand_average-ave.fif'
        mne.evoked.write_evokeds(grand_average_path,
                                 grand_averages[trial_type])
                                                               
#==============================================================================
# BASH OPERATIONS                                 
#==============================================================================
        
## local function used in the bash commands below
def run_process_and_write_output(command, subjects_dir):
    environment = environ.copy()
    environment["SUBJECTS_DIR"] = subjects_dir
    process = subprocess.Popen(command, stdout=subprocess.PIPE,
                               env=environment)
    ## write bash output in python console
    for c in iter(lambda: process.stdout.read(1), b''):
        sys.stdout.write(c.decode('utf-8'))
        
def import_mri(dicom_path, subject, subjects_dir, n_jobs_freesurfer):
    files = listdir(dicom_path)
    first_file = files[0]
    ## check if import has already been done
    if not isdir(join(subjects_dir, subject)):
        ## run bash command
        print('Importing MRI data for subject: ' + subject + \
              ' into FreeSurfer folder.\nBash output follows below.\n\n')
              
        command = ['recon-all',
                   '-subjid', subject,
                   '-i', join(dicom_path, first_file),
                   '-openmp', str(n_jobs_freesurfer)]             
        
        run_process_and_write_output(command, subjects_dir)
    else:
        print('FreeSurfer folder for: ' + subject + ' already exists.' + \
              ' To import data from the beginning, you would have to ' + \
              "delete this subject's FreeSurfer folder")

def segment_mri(subject, subjects_dir, n_jobs_freesurfer):
    
    print('Segmenting MRI data for subject: ' + subject + \
          ' using the Freesurfer "recon-all" pipeline.' + \
          'Bash output follows below.\n\n')
          
    command = ['recon-all',
               '-subjid', subject,
               '-all',
               '-openmp', str(n_jobs_freesurfer)]
    
    run_process_and_write_output(command, subjects_dir)

def apply_watershed(subject, subjects_dir, overwrite):
    
    print('Running Watershed algorithm for: ' + subject + \
          ". Output is written to the bem folder " + \
          "of the subject's FreeSurfer folder.\n" + \
          'Bash output follows below.\n\n')
          
    if overwrite:
        overwrite_string = '--overwrite'
    else:
        overwrite_string = ''
    ## watershed command      
    command = ['mne_watershed_bem',
               '--subject', subject,
               overwrite_string]          

    run_process_and_write_output(command, subjects_dir)
    ## copy commands
    surfaces = dict(
            inner_skull=dict(
                             origin=subject + '_inner_skull_surface',
                             destination='inner_skull.surf'),
            outer_skin=dict(origin=subject + '_outer_skin_surface',
                            destination='outer_skin.surf'),
            outer_skull=dict(origin=subject + '_outer_skull_surface',
                             destination='outer_skull.surf'),
            brain=dict(origin=subject + '_brain_surface',
                       destination='brain_surface.surf')
                    )                           
    
    for surface in surfaces:
        this_surface = surfaces[surface]
        ## copy files from watershed into bem folder where MNE expects to
        # find them
        command = ['cp', '-v',
                   join(subjects_dir, subject, 'bem', 'watershed',
                        this_surface['origin']),
                   join(subjects_dir, subject, 'bem'    ,
                        this_surface['destination'])
                   ]
        run_process_and_write_output(command, subjects_dir)       

def make_source_space(subject, subjects_dir, source_space_method, overwrite):
      
    print('Making source space for ' + \
          'subject: ' + subject + \
          ". Output is written to the bem folder" + \
          " of the subject's FreeSurfer folder.\n" + \
          'Bash output follows below.\n\n')
          
    if overwrite:
        overwrite_string = '--overwrite'
    else:
        overwrite_string = ''
        
    command = ['mne_setup_source_space',
               '--subject', subject,
               '--' + source_space_method[0], str(source_space_method[1]),
               overwrite_string
               ]

    run_process_and_write_output(command, subjects_dir)
    
def make_dense_scalp_surfaces(subject, subjects_dir, overwrite):
    
    print('Making dense scalp surfacing easing co-registration for ' + \
          'subject: ' + subject + \
          ". Output is written to the bem folder" + \
          " of the subject's FreeSurfer folder.\n" + \
          'Bash output follows below.\n\n')
          
    if overwrite:
        overwrite_string = '--overwrite'
    else:
        overwrite_string = ''

    command = ['mne_make_scalp_surfaces',
               '--subject', subject,
               overwrite_string]

    run_process_and_write_output(command, subjects_dir) 
          
def make_bem_solutions(subject, subjects_dir):
       
    print('Writing volume conductor for ' + \
          'subject: ' + subject + \
          ". Output is written to the bem folder" + \
          " of the subject's FreeSurfer folder.\n" + \
          'Bash output follows below.\n\n')
          
    command = ['mne_setup_forward_model',
               '--subject', subject,
               '--homog',
               '--surf',
               '--ico', '4'
               ]
             
    run_process_and_write_output(command, subjects_dir)       

#==============================================================================
# MNE SOURCE RECONSTRUCTIONS
#==============================================================================
    
def create_forward_solution(name, save_dir, subject, subjects_dir,
                            overwrite):

    forward_name = name + '-fwd.fif'
    forward_path = join(save_dir, forward_name)

    if overwrite or not isfile(forward_path):

        info = io.read_info(name, save_dir)
        trans = io.read_transformation(name, save_dir)
        bem = io.read_bem_solution(subject, subjects_dir)
        source_space = io.read_source_space(subject, subjects_dir)

        forward = mne.make_forward_solution(info, trans, source_space, bem,
                                              n_jobs=1)
        
        forward = mne.convert_forward_solution(forward, surf_ori=True)
        
        mne.write_forward_solution(forward_path, forward, overwrite)
        
    else:
        print('forward solution: ' + forward_path + ' already exists')
        
def estimate_noise_covariance(name, save_dir, lowpass, overwrite):
    
    covariance_name = name + filter_string(lowpass) + '-cov.fif'      
    covariance_path = join(save_dir, covariance_name)
    
    if overwrite or not isfile(covariance_path):
        
        epochs = io.read_epochs(name, save_dir, lowpass)
       
        noise_covariance = mne.compute_covariance(epochs, n_jobs=1)
            
        noise_covariance = mne.cov.regularize(noise_covariance,
                                              epochs.info)
                                                  
        mne.cov.write_cov(covariance_path, noise_covariance)
           
    else:
        print('noise covariance file: '+ covariance_path + \
              ' already exists')          
                                               
def create_inverse_operator(name, save_dir, lowpass, overwrite):
    
    inverse_operator_name = name + filter_string(lowpass) +  '-inv.fif'
    inverse_operator_path = join(save_dir, inverse_operator_name)  

    if overwrite or not isfile(inverse_operator_path):
        
        info = io.read_info(name, save_dir)
        noise_covariance = io.read_noise_covariance(name, save_dir, lowpass)
        forward = io.read_forward(name, save_dir)
        
        inverse_operator = mne.minimum_norm.make_inverse_operator(
                            info, forward, noise_covariance)
                            
        mne.minimum_norm.write_inverse_operator(inverse_operator_path,
                                                    inverse_operator)
                                                    
    else:
        print('inverse operator file: '+ inverse_operator_path + \
              ' already exists')
                                                
def source_estimate(name, save_dir, lowpass, method, 
                    overwrite):
    
    inverse_operator = io.read_inverse_operator(name, save_dir, lowpass)
    to_reconstruct = io.read_evokeds(name, save_dir, lowpass)
    evokeds = io.read_evokeds(name, save_dir, lowpass)

    stcs = dict()
    for to_reconstruct_index, evoked in enumerate(evokeds):
        stc_name = name + filter_string(lowpass) + '_' + evoked.comment + \
                '_' + method + '-lh.stc'
        stc_path = join(save_dir, stc_name)
        if overwrite or not isfile(stc_path):
            trial_type = evoked.comment
            
            stcs[trial_type] = mne.minimum_norm.apply_inverse(
                                        to_reconstruct[to_reconstruct_index],
                                        inverse_operator, 
                                        method=method)
        else:
            print('source estimates for: '+  stc_path + \
                  ' already exists')
                                                     
    for stc in stcs:
        stc_name = name + filter_string(lowpass) + '_' + stc + '_' + method
        stc_path = join(save_dir, stc_name)
        if overwrite or not isfile(stc_path + '-lh.stc'):
            stcs[stc].save(stc_path)
            
def morph_data_to_fsaverage(name, save_dir, subjects_dir, subject,
                            lowpass, method, overwrite):

    stcs = io.read_source_estimates(name, save_dir, lowpass, method)

    subject_to = 'fsaverage'  
    stcs_morph = dict()

    for trial_type in stcs:
        stc_morph_name = name + filter_string(lowpass) + '_' + \
        trial_type +  '_' + method + '_morph'
        stc_morph_path = join(save_dir, stc_morph_name)

        if overwrite or not isfile(stc_morph_path + '-lh.stc'):
            stc_from = stcs[trial_type]
            stcs_morph[trial_type] = mne.morph_data(subject, subject_to,
                                                    stc_from,
                                                    subjects_dir=subjects_dir,
                                                    n_jobs=-1)
        else:
            print('morphed source estimates for: '+  stc_morph_path + \
                  ' already exists')
                                                                                               
    for trial_type in stcs_morph:
        stc_morph_name = name + filter_string(lowpass) + '_' + \
        trial_type +  '_' + method + '_morph'
        stc_morph_path = join(save_dir, stc_morph_name)
        if overwrite or not isfile(stc_morph_path + '-lh.stc'):
            stcs_morph[trial_type].save(stc_morph_path)                                                    

def average_morphed_data(morphed_data_all, method, save_dir_averages, lowpass):
 
    averaged_morphed_data = dict()
    
    n_subjects = len(morphed_data_all['standard_1']) 
    for trial_type in morphed_data_all:
        trial_morphed_data = morphed_data_all[trial_type]
        trial_average = trial_morphed_data[0].copy()#get copy of first instance 
        
        for trial_index in range(1, n_subjects):
            trial_average._data += trial_morphed_data[trial_index].data
            
        trial_average._data /= n_subjects
        averaged_morphed_data[trial_type] = trial_average
        
    for trial_type in averaged_morphed_data:
        stc_path = save_dir_averages  + \
            trial_type + filter_string(lowpass) + '_morphed_data_' + method
        averaged_morphed_data[trial_type].save(stc_path)
                                                                
#==============================================================================
# STATISTICS                                                 
#==============================================================================

def statistics_source_space(morphed_data_all, save_dir_averages,
                            independent_variable_1,
                            independent_variable_2,
                            time_window, n_permutations, lowpass, overwrite):
                                
    cluster_name = independent_variable_1 + '_vs_' + independent_variable_2 + \
                    filter_string(lowpass) + '_time_' + \
                    str(int(time_window[0] * 1e3)) + '-' + \
                    str(int(time_window[1] * 1e3)) + '_msec.cluster'
    cluster_path = join(save_dir_averages, 'statistics', cluster_name)
    
    if overwrite or not isfile(cluster_path):
    
        input_data = dict(iv_1=morphed_data_all[independent_variable_1],
                          iv_2=morphed_data_all[independent_variable_2])
        info_data = morphed_data_all[independent_variable_1]                                          
        n_subjects = len(info_data)
        n_sources, n_samples = info_data[0].data.shape
        
        ## get data in the right format    
        statistics_data_1 = np.zeros((n_subjects, n_sources, n_samples))
        statistics_data_2 = np.zeros((n_subjects, n_sources, n_samples))
        
        for subject_index in range(n_subjects):
            statistics_data_1[subject_index, :, :] = input_data['iv_1'][subject_index].data
            statistics_data_2[subject_index, :, :] = input_data['iv_2'][subject_index].data
            print('processing data from subject: ' + str(subject_index))
            
        ## crop data on the time dimension
        times = info_data[0].times
        time_indices = np.logical_and(times >= time_window[0],
                                      times <= time_window[1])
                                      
        statistics_data_1 = statistics_data_1[:, :, time_indices]
        statistics_data_2 = statistics_data_2[:, :, time_indices]

        ## set up cluster analysis
        p_threshold = 0.05
        t_threshold = stats.distributions.t.ppf(1 - p_threshold / 2, n_subjects - 1)
        seed = 7 ## my lucky number
        
        statistics_list = [statistics_data_1, statistics_data_2]
        
        T_obs, clusters, cluster_p_values, H0 =  \
            mne.stats.permutation_cluster_test(statistics_list,
                                                     n_permutations=n_permutations,
                                                     threshold=t_threshold,
                                                     seed=seed,
                                                     n_jobs=-1)
                                                     
        cluster_dict = dict(T_obs=T_obs, clusters=clusters,
                            cluster_p_values=cluster_p_values, H0=H0)
    
        with open(cluster_path, 'wb') as filename:
            pickle.dump(cluster_dict, filename)

        print('finished saving cluster at path: ' + cluster_path)

    else:                                                                            
        print('cluster permutation: '+ cluster_path + \
              ' already exists')

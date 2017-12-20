# -*- coding: utf-8 -*-
"""
Pipeline for group analysis of MEG data - IO functions
@author: Lau Møller Andersen
@email: lau.moller.andersen@ki.se | lau.andersen@cnru.dk
@github: https://github.com/ualsbombe/omission_frontiers.git
"""
from __future__ import print_function

import mne
from os.path import join
import pickle

def filter_string(lowpass):
    
    filter_string = '_' + str(lowpass) + '_Hz'
    
    return filter_string

#==============================================================================
# IO FUNCTIONS
#==============================================================================

def read_info(name, save_dir):
    
    raw_name = name + '-tsss-mc_meg.fif'        
    raw_path = join(save_dir, raw_name)
    info = mne.io.read_info(raw_path)
    
    return info

def read_maxfiltered(name, save_dir):
    
    split_string_number = 0
    read_all_files = False
    raws = []
    while not read_all_files:
        
        if split_string_number > 0:
            split_string_part = '-' + str(split_string_number)
        else:
            split_string_part = ''
            
        raw_name = name + '-tsss-mc_meg' + split_string_part + '.fif'        
        raw_path = join(save_dir, raw_name)
        try:
            raw_part = mne.io.Raw(raw_path, preload=True)
            raws.append(raw_part)
            split_string_number += 1
        except:
            read_all_files = True
            print(str(split_string_number) + ' raw files were read') 
        
    raw = mne.concatenate_raws(raws)
    
    return raw

def read_filtered(name, save_dir, lowpass):
    
    raw_name = name + filter_string(lowpass) + '-raw.fif'
    raw_path = join(save_dir, raw_name)
    raw = mne.io.Raw(raw_path, preload=True)
    
    return raw
    
def read_events(name, save_dir):
    
    events_name = name + '-eve.fif'
    events_path = join(save_dir, events_name)
    events = mne.read_events(events_path, mask=None)
    
    return events
    
    
def read_epochs(name, save_dir, lowpass):    


    epochs_name = name + filter_string(lowpass) + '-epo.fif'
    epochs_path = join(save_dir, epochs_name)                       
    epochs = mne.read_epochs(epochs_path)
    
    return epochs
  
  
def read_ica(name, save_dir, lowpass):

    ica_name = name + filter_string(lowpass) + '-ica.fif'
    ica_path = join(save_dir, ica_name)
    ica = mne.preprocessing.read_ica(ica_path)    
        
    return ica
        
def read_ica_epochs(name, save_dir, lowpass):
    
    ica_epochs_name = name + filter_string(lowpass) + '-ica-epo.fif'
    ica_epochs_path = join(save_dir, ica_epochs_name)
    ica_epochs = mne.read_epochs(ica_epochs_path)
    
    return(ica_epochs)
    
def read_evokeds(name, save_dir, lowpass):
    
    evokeds_name = name + filter_string(lowpass) + '-ave.fif' 
    evokeds_path = join(save_dir, evokeds_name)
    evokeds = mne.read_evokeds(evokeds_path)
    
    return evokeds    
    
def read_forward(name, save_dir):

    forward_name = name + '-fwd.fif'
    forward_path = join(save_dir, forward_name)
    forward = mne.read_forward_solution(forward_path)
    
    return forward
    
def read_noise_covariance(name, save_dir, lowpass):

    covariance_name = name + filter_string(lowpass) + '-cov.fif'
    covariance_path = join(save_dir, covariance_name)
    noise_covariance = mne.read_cov(covariance_path)        
    
    return noise_covariance
        
    
def read_inverse_operator(name, save_dir, lowpass):

    inverse_operator_name = name + filter_string(lowpass) +  '-inv.fif'                 
    inverse_operator_path = join(save_dir, inverse_operator_name)        
    inverse_operator = mne.minimum_norm.read_inverse_operator(inverse_operator_path)
    
    return inverse_operator
        

def read_source_estimates(name, save_dir, lowpass, method, morphed=False):

    evokeds = read_evokeds(name, save_dir, lowpass)
    stcs = dict()
    
    if morphed:
        morph_text = '_morph'
    else:
        morph_text = ''
    
    for evoked in evokeds:
        trial_type = evoked.comment
        stcs[trial_type] = None
        for stc in stcs:
                stc_name = name + filter_string(lowpass) + \
                    '_' + stc + '_' + method + morph_text
                stc_path = join(save_dir, stc_name)
                stcs[stc] = mne.source_estimate.read_source_estimate(stc_path)

    return stcs
                
    
def read_source_space(subject, subjects_dir):

    source_space_path = join(subjects_dir, subject, 'bem',
                             subject + '-ico-5-src.fif')
    source_space = mne.source_space.read_source_spaces(source_space_path)
    
    return source_space
    
def read_transformation(name, save_dir):

    trans_name = name + '_dense-trans.fif'
    trans_path = join(save_dir, trans_name)
    trans = mne.read_trans(trans_path)

    return trans
    
def read_bem_solution(subject, subjects_dir):

    bem_path = join(subjects_dir, subject, 'bem',
                    subject + '-5120-bem-sol.fif')    
    bem = mne.read_bem_solution(bem_path)
    
    return bem
                              
def read_clusters(save_dir_averages, independent_variable_1,
                  independent_variable_2, time_window, lowpass):
                  
    cluster_name = independent_variable_1 + '_vs_' + independent_variable_2 + \
                    filter_string(lowpass) + '_time_' + \
                    str(int(time_window[0] * 1e3)) + '-' + \
                    str(int(time_window[1] * 1e3)) + '_msec.cluster'
    cluster_path = join(save_dir_averages, 'statistics', cluster_name)                    

    with open(cluster_path, 'rb') as filename:
        cluster_dict = pickle.load(filename)
        
    return cluster_dict

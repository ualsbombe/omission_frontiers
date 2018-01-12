# -*- coding: utf-8 -*-
"""
Pipeline for group analysis of MEG data - plotting functions
@author: Lau Møller Andersen
@email: lau.moller.andersen@ki.se | lau.andersen@cnru.dk
@github: https://github.com/ualsbombe/omission_frontiers.git
"""
from __future__ import print_function

import mne
from os.path import join
import matplotlib.pyplot as plt
import mayavi.mlab
from  . import io_functions as io
import numpy as np
from scipy import stats

def filter_string(lowpass):
    
    filter_string = '_' + str(lowpass) + '_Hz'
    
    return filter_string
#==============================================================================
# PLOTTING FUNCTIONS
#==============================================================================
    
def plot_maxfiltered(name, save_dir):
    
    raw = io.read_maxfiltered(name, save_dir) 
    raw.plot()
    
def plot_filtered(name, save_dir, lowpass):
    
     raw = io.read_filtered(name, save_dir, lowpass)
     raw.plot() 
    
def plot_power_spectra(name, save_dir, lowpass, subject, save_plots,
                        figures_path):
    
    raw = io.read_filtered(name, save_dir, lowpass)
    psd_figure = raw.plot_psd(fmax=lowpass, n_jobs=-1)
    
    if save_plots:
        save_path = join(figures_path, subject, 'power_spectra_raw', name + \
                             filter_string(lowpass) + '.jpg')
        psd_figure.savefig(save_path, dpi=600)
        print('figure: ' + save_path + ' has been saved')
    else:
        print('Not saving plots; set "save_plots" to "True" to save')            
    
    
def plot_ica(name, save_dir, lowpass, subject, save_plots, figures_path):
    
    ica = io.read_ica(name, save_dir, lowpass)
    ica_figure = ica.plot_components(ica.exclude)
    
    if save_plots:
        save_path = join(figures_path, subject, 'ica', name + \
            filter_string(lowpass) + '.jpg')
        ica_figure.savefig(save_path, dpi=600)
        print('figure: ' + save_path + ' has been saved')
    else:
        print('Not saving plots; set "save_plots" to "True" to save')            


def plot_epochs_image(name, save_dir, lowpass, subject, save_plots,
                      figures_path):
                          
    channel = 'MEG1812'                          
    epochs = io.read_epochs(name, save_dir, lowpass)
    picks = mne.pick_channels(epochs.info['ch_names'], [channel])
    for trial_type in epochs.event_id:
        epochs_image = mne.viz.plot_epochs_image(epochs[trial_type], picks)
        plt.title(trial_type)

        if save_plots:
            save_path = join(figures_path, subject, 'epochs',
                             trial_type + '_' + channel + '_' + name + \
                             filter_string(lowpass) + '.jpg')          
            epochs_image[0].savefig(save_path, dpi=600)
            print('figure: ' + save_path + ' has been saved')
        else:
            print('Not saving plots; set "save_plots" to "True" to save')            

    
def plot_evokeds(name, save_dir, lowpass, subject, save_plots, figures_path):

    evokeds = io.read_evokeds(name, save_dir, lowpass)
    order = [
        'standard_1', 'standard_2', 'standard_3', 'standard_4', 'standard_5',
        'omission_4', 'omission_5', 'omission_6',
        'non_stimulation']    
    colours = ['white', 'blue', 'green', 'purple', 'yellow',
               'red', 'orange', 'pink',
               'grey']
    
    # sort evokeds
    plot_evokeds = []
    plot_standards = []
    plot_omissions = []
    for evoked_type in order:
        for evoked in evokeds:
            if evoked.comment == evoked_type:
                plot_evokeds.append(evoked)
            if evoked.comment == evoked_type and \
                    (evoked.comment[0] == 's' or evoked.comment[0] == 'n'):
                plot_standards.append(evoked)            
            if evoked.comment == evoked_type and \
                    (evoked.comment[0] == 'o' or evoked.comment[0] == 'n'):
                plot_omissions.append(evoked)                
    
    plt.close('all')
    
    evoked_figure = mne.viz.plot_evoked_topo(plot_evokeds, color=colours)
    evoked_figure.comment = 'all_evokeds_'                                           
    standards_figure = mne.viz.plot_evoked_topo(plot_standards,
                                                color=colours[:5] + colours[8:9])                                         
    standards_figure.comment = 'standards_evokeds_'                                                
    omissions_figure = mne.viz.plot_evoked_topo(plot_omissions,
                                                color=colours[5:9])
    omissions_figure.comment = 'omissions_evokeds_'                                                
                                                
    figures = [evoked_figure, standards_figure, omissions_figure]
    
    if save_plots:
        for figure in figures:
            save_path = join(figures_path, subject, 'evokeds', 
                             figure.comment + name + \
                             filter_string(lowpass) + '.jpg')
            figure.savefig(save_path, dpi=600)
            print('figure: ' + save_path + ' has been saved')
    else:
        print('Not saving plots; set "save_plots" to "True" to save')
        
        
        
def plot_butterfly_evokeds(name, save_dir, lowpass, subject, save_plots,
                                figures_path):

    evokeds = io.read_evokeds(name, save_dir, lowpass)
    for evoked in evokeds:
        figure = evoked.plot()

        if save_plots:
            save_path = join(figures_path, subject, 'evokeds', 
                             'butterfly_' + evoked.comment + '_' + name + \
                             filter_string(lowpass) + '.jpg')
            figure.savefig(save_path, dpi=600)
            print('figure: ' + save_path + ' has been saved')
        else:
            print('Not saving plots; set "save_plots" to "True" to save')        
        
def plot_transformation(name, save_dir, subject, subjects_dir, save_plots,
                        figures_path):
        info = io.read_info(name, save_dir)
        trans = io.read_transformation(name, save_dir)
        
        mne.viz.plot_alignment(info, trans, subject, subjects_dir,
                               surfaces=['head-dense', 'inner_skull', 'brain'])#,
#                               skull=['inner_skull', 'outer_skull'],
#                               brain=True)
                                   
        mayavi.mlab.view(0, -90)                                   
                           
        if save_plots:
            save_path = join(figures_path, subject, 'transformation', name + \
                            '.jpg')
            mayavi.mlab.savefig(save_path)
            print('figure: ' + save_path + ' has been saved')
        else:
            print('Not saving plots; set "save_plots" to "True" to save')
                           
def plot_source_space(name, subject, subjects_dir, save_plots, figures_path):
    
    source_space = io.read_source_space(subject, subjects_dir)
    source_space.plot()
    mayavi.mlab.view(-90, 7)
    
    if save_plots:
        save_path = join(figures_path, subject, 'source_space', name + '.jpg')
        mayavi.mlab.savefig(save_path)
        print('figure: ' + save_path + ' has been saved')

    else:
            print('Not saving plots; set "save_plots" to "True" to save')
            
def plot_noise_covariance(name, save_dir, lowpass, subject, save_plots,
                          figures_path):

    noise_covariance = io.read_noise_covariance(name, save_dir, lowpass)
    info = io.read_info(name, save_dir)
    
    fig_cov = noise_covariance.plot(info, show_svd=False)
    
    if save_plots:
        save_path = join(figures_path, subject, 'noise_covariance', name + \
                    filter_string(lowpass) + '.jpg')
        fig_cov[0].savefig(save_path, dpi=600)
        print('figure: ' + save_path + ' has been saved')
    else:
        print('Not saving plots; set "save_plots" to "True" to save')        
    

def plot_source_estimates(name, save_dir, lowpass, subject,
                          subjects_dir, method, mne_evoked_time,
                          save_plots, figures_path):

    stcs = io.read_source_estimates(name, save_dir, lowpass, method)
    
    brains = dict()
    for trial_type in list(stcs.keys()):
        brains[trial_type] = None
      
    mayavi.mlab.close(None, True)
    
    for brains_figure_counter, stc in enumerate(stcs):
        mayavi.mlab.figure(figure=brains_figure_counter,
                           size=(800, 800))
        brains[stc] = stcs[stc].plot(subject=subject,
                                    subjects_dir=subjects_dir,
                                    time_viewer=False, hemi='both',
                                    figure=brains_figure_counter,
                                    views='dorsal')
        time = mne_evoked_time
        brains[stc].set_time(time)
        message = list(stcs.keys())[brains_figure_counter] 
        brains[stc].add_text(0.01, 0.9, message,
                 str(brains_figure_counter), font_size=14)
                 
        if save_plots:
            save_path = join(figures_path, subject, 'stcs',
                             stc + '_' + name + \
                             filter_string(lowpass) + '_' + str(time * 1e3) + \
                                 '_msec.jpg')                     
            brains[stc].save_single_image(save_path)
            print('figure: ' + save_path + ' has been saved')
            
        else:
            print('Not saving plots; set "save_plots" to "True" to save')             
        
def plot_grand_average_evokeds(name, lowpass, save_dir_averages,
                               evoked_data_all,
                               save_plots, figures_path):
    
    grand_averages = []
    order = [
        'standard_1', 'standard_2', 'standard_3', 'standard_4', 'standard_5',
        'omission_4', 'omission_5', 'omission_6',
        'non_stimulation']    
        
    for evoked_type in order:
        filename = join(save_dir_averages, 
                        evoked_type + filter_string(lowpass) + \
                        '_grand_average-ave.fif')
        evoked = mne.read_evokeds(filename)[0]
        evoked.comment = evoked_type
        grand_averages.append(evoked)                        

    colours = ['white', 'blue', 'green', 'purple', 'yellow',
               'red', 'orange', 'pink',
               'grey']
    
    # sort evokeds
    plot_evokeds = []
    plot_standards = []
    plot_omissions = []
    for evoked_type in order:
        for evoked in grand_averages:
            if evoked.comment == evoked_type:
                plot_evokeds.append(evoked)
            if evoked.comment == evoked_type and \
                    (evoked.comment[0] == 's' or evoked.comment[0] == 'n'):
                plot_standards.append(evoked)            
            if evoked.comment == evoked_type and \
                    (evoked.comment[0] == 'o' or evoked.comment[0] == 'n'):
                plot_omissions.append(evoked)                
    
    plt.close('all')
    
    evoked_figure = mne.viz.plot_evoked_topo(plot_evokeds, color=colours)
    evoked_figure.comment = 'all_evokeds_'                                           
    standards_figure = mne.viz.plot_evoked_topo(plot_standards,
                                                color=colours[:5] + colours[8:9])                                         
    standards_figure.comment = 'standards_evokeds_'                                                
    omissions_figure = mne.viz.plot_evoked_topo(plot_omissions,
                                                color=colours[5:9])
    omissions_figure.comment = 'omissions_evokeds_'  
                                                
    figures = [evoked_figure, standards_figure, omissions_figure]
    
    if save_plots:
        for figure in figures:
            save_path = join(figures_path, 'grand_averages', 'sensor_space',
                             figure.comment + name + \
                             filter_string(lowpass) + '.jpg')
            figure.savefig(save_path, dpi=600)
            print('figure: ' + save_path + ' has been saved')
    else:
        print('Not saving plots; set "save_plots" to "True" to save')
        
        
def plot_grand_averages_butterfly_evokeds(name, lowpass, save_dir_averages,
                                          save_plots, figures_path):
                                              
    grand_averages = []
    order = [
        'standard_1', 'standard_2', 'standard_3', 'standard_4', 'standard_5',
        'omission_4', 'omission_5', 'omission_6',
        'non_stimulation']    
        
    for evoked_type in order:
        filename = join(save_dir_averages, 
                        evoked_type + filter_string(lowpass) + \
                        '_grand_average-ave.fif')
        evoked = mne.read_evokeds(filename)[0]
        evoked.comment = evoked_type
        grand_averages.append(evoked)                                                                    

    for grand_average in grand_averages:
        figure = grand_average.plot()

        if save_plots:
            save_path = join(figures_path, 'grand_averages', 'sensor_space',
                             'butterfly_' + grand_average.comment + '_' + name + \
                             filter_string(lowpass) + '.jpg')
            figure.savefig(save_path, dpi=600)
            print('figure: ' + save_path + ' has been saved')
        else:
            print('Not saving plots; set "save_plots" to "True" to save') 

def plot_grand_averages_source_estimates(name, save_dir_averages, lowpass,
                          subjects_dir, method, mne_evoked_time,
                          save_plots, figures_path):

    stcs = dict()
    order = [
        'standard_1', 'standard_2', 'standard_3', 'standard_4', 'standard_5',
        'omission_4', 'omission_5', 'omission_6',
        'non_stimulation']
        
    for stc_type in order:
        filename = join(save_dir_averages, 
                        stc_type + filter_string(lowpass) + \
                        '_morphed_data_' + method)
        stc = mne.read_source_estimate(filename)
        stc.comment = stc_type
        stcs[stc_type] = stc
          
    brains = dict()
    for trial_type in list(stcs.keys()):
        brains[trial_type] = None
      
    mayavi.mlab.close(None, True)
    
    for brains_figure_counter, stc in enumerate(stcs):
        mayavi.mlab.figure(figure=brains_figure_counter,
                           size=(800, 800))
        brains[stc] = stcs[stc].plot(subject='fsaverage',
                                    subjects_dir=subjects_dir,
                                    time_viewer=False, hemi='both',
                                    figure=brains_figure_counter,
                                    views='dorsal')
        time = mne_evoked_time
        brains[stc].set_time(time)
        message = list(stcs.keys())[brains_figure_counter] 
        brains[stc].add_text(0.01, 0.9, message,
                 str(brains_figure_counter), font_size=14)
                 
        if save_plots:
            save_path = join(figures_path, 'grand_averages', 'source_space',
                             stc + '_' + name + \
                             filter_string(lowpass) + '_' + str(time * 1e3) + \
                                 '_msec.jpg')                     
            brains[stc].save_single_image(save_path)
            print('figure: ' + save_path + ' has been saved')
            
        else:
            print('Not saving plots; set "save_plots" to "True" to save')
            
def plot_grand_averages_source_estimates_cluster_masked(name, 
                          save_dir_averages, lowpass,
                          subjects_dir, method, time_window,
                          save_plots, figures_path,
                          independent_variable_1, independent_variable_2,
                          mne_evoked_time, p_threshold):

    if mne_evoked_time < time_window[0] or mne_evoked_time > time_window[1]:
        raise ValueError('"mne_evoked_time" must be within "time_window"')
    n_subjects = 20 ## should be corrected
    independent_variables = [independent_variable_1, independent_variable_2]                                  
    stcs = dict()        
    for stc_type in independent_variables:
        filename = join(save_dir_averages, 
                        stc_type + filter_string(lowpass) + \
                        '_morphed_data_' + method)
        stc = mne.read_source_estimate(filename)
        stc.comment = stc_type
        stcs[stc_type] = stc
        
    difference_stc = stcs[independent_variable_1] - stcs[independent_variable_2]
    
    ## load clusters
    
    cluster_dict = io.read_clusters(save_dir_averages, independent_variable_1,
                  independent_variable_2, time_window, lowpass)
    cluster_p_values = cluster_dict['cluster_p_values']
    clusters = cluster_dict['clusters']
    T_obs = cluster_dict['T_obs']      
    n_sources = T_obs.shape[0]
    
    cluster_p_threshold = 0.05
    indices = np.where(cluster_p_values <= cluster_p_threshold)[0]
    sig_clusters = []
    for index in indices:    
        sig_clusters.append(clusters[index])
        
    cluster_T = np.zeros(n_sources)
    for sig_cluster in sig_clusters:
        # start = sig_cluster[0].start
        # stop = sig_cluster[0].stop
        sig_indices = np.unique(np.where(sig_cluster == 1)[0])
        cluster_T[sig_indices] = 1                       
    
    t_mask = np.copy(T_obs)
    t_mask[cluster_T == 0] = 0
    cutoff = stats.t.ppf(1 - p_threshold / 2, df=n_subjects - 1)
    
    time_index = int(mne_evoked_time * 1e3 + 200)
    time_window_times = np.linspace(time_window[0], time_window[1], 
                        int((time_window[1] - time_window[0]) * 1e3) + 2)
    time_index_mask = np.where(time_window_times == mne_evoked_time)[0]
    difference_stc._data[:, time_index] = np.reshape(t_mask[:, time_index_mask], n_sources)
      
    mayavi.mlab.close(None, True)
    clim = dict(kind='value', lims=[cutoff, 2*cutoff, 4*cutoff])
    
    mayavi.mlab.figure(figure=0,
                        size=(800, 800))
    brain = difference_stc.plot(subject='fsaverage',
                                subjects_dir=subjects_dir,
                                time_viewer=False, hemi='both',
                                figure=0,
                                clim=clim,
                                views='dorsal')                               
    time = mne_evoked_time
    brain.set_time(time)
    message = independent_variable_1 + ' vs ' + independent_variable_2 
    brain.add_text(0.01, 0.9, message,
                str(0), font_size=14)
                
    if save_plots:
        save_path = join(figures_path, 'grand_averages',
                            'source_space/statistics',
                            message + '_' + name + \
                            filter_string(lowpass) + '.jpg' + '_' + str(time * 1e3) + \
                                '_msec.jpg')                     
        brain.save_single_image(save_path)
        print('figure: ' + save_path + ' has been saved')
        
    else:
        print('Not saving plots; set "save_plots" to "True" to save')

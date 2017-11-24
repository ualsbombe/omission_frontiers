function [handles] = plot_quality_control_figures(cfg, input_variables)
% plot quality control figures, first argument is headmodel, second
% argument is mri_realigned to fiducials, third argument is segmented mri
%
% cfg must contain
%
%   cfg.headshape_file = 'oddball_absence-tsss-mc_meg.fif';


% close earlier windows
close all hidden

% get variables
info_path = fullfile(cfg.save_path, cfg.headshape_file);
sensors = ft_read_sens(info_path);
headshape = ft_read_headshape(info_path);
headmodel = input_variables{1};
mri_realigned_digitzation = input_variables{2};
mri_segmented = input_variables{3};

% figure 1
h1 = figure('units', 'normalized', 'outerposition', [0 0 1 1]);
ft_plot_sens(sensors, 'unit', 'mm')
ft_plot_headshape(headshape, 'unit', 'mm')
ft_plot_vol(headmodel, 'unit', 'mm')
ft_plot_axes([], 'unit', 'mm', 'coordsys', 'neuromag', 'fontsize', 30);
view(95, 20)

% figure 2, MRI anatomy and brain segmentation

cfg = [];
cfg.anaparameter = 'anatomy';
cfg.funparameter = 'brain';
cfg.location = [0 0 60];
ft_sourceplot(cfg, mri_segmented)
h2 = gcf;
set(h2, 'units', 'normalized', 'outerposition', [0 0 1 1]);

% figure 3 and 4, MRI anatomy and headmodel

location = [0 0 60];
h3 = figure('units', 'normalized', 'outerposition', [0 0 1 1]);
ft_plot_ortho(mri_realigned_digitzation.anatomy, ...
              'transform', mri_realigned_digitzation.transform, ...
              'location', location, 'intersectmesh', headmodel.bnd);

h4 = figure('units', 'normalized', 'outerposition', [0 0 1 1]);
ft_plot_montage(mri_realigned_digitzation.anatomy, ...
                'transform', mri_realigned_digitzation.transform, ...
                'intersectmesh', headmodel.bnd)

% figure 5, MRI scalp surface and polhemus headshape

cfg = [];
cfg.tissue = 'scalp';
cfg.method = 'isosurface';
cfg.numvertices = 10000;
scalp = ft_prepare_mesh(cfg, mri_segmented);

h5 = figure('units', 'normalized', 'outerposition', [0 0 1 1]);
ft_plot_mesh(scalp, 'facecolor', 'skin')
lighting phong
camlight left
camlight right
material dull
alpha 0.5
headshape_converted = ft_convert_units(headshape, 'mm');
ft_plot_headshape(headshape_converted, 'vertexcolor', 'k');

% figure 6, MRI and anatomical landmarks

h6 = figure('units', 'normalized', 'outerposition', [0 0 1 1]);
for index = 1:3
  subplot(2,2,index)
  title(headshape.fid.label{index});
  location = headshape.fid.pos(index,:);
  ft_plot_ortho(mri_realigned_digitzation.anatomy, ...
               'transform', mri_realigned_digitzation.transform, ...
               'style', 'intersect', 'location', location, ...
               'plotmarker', location, 'markersize', 5, 'markercolor', 'y')
end


% figure 7, MRI scalp surface and anatomical landmarks 

h7 = figure('units', 'normalized', 'outerposition', [0 0 1 1]);
ft_plot_mesh(scalp, 'facecolor', 'skin')
lighting phong
camlight left
camlight right
material dull
alpha 0.3
headshape_converted = ft_convert_units(headshape, 'mm');
ft_plot_mesh(headshape_converted.fid, ...
             'vertexcolor', 'k', 'vertexsize', 10);

    
handles = {h1 h2 h3 h4 h5 h6 h7};
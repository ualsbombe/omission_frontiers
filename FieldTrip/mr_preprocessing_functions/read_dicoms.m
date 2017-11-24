function [mri] = read_dicoms(cfg, ~)
% This function creates an mri.mat from the dicoms
%
% cfg must contain
%
%	cfg.dicom_path = path of the first dicom file for each of the subjects
%	cfg.dicom_file = name of the first dicom file for each of the subjects
%	cfg.coordsys   = name of the coordinate system that you want to 
%   co-register with
%

% get subject
full_dicom_path = fullfile(cfg.dicom_path, cfg.subject, cfg.dicom_file);
% read mri
mri = ft_read_mri(full_dicom_path);
mri.coordsys = cfg.coordsys;
mri = {mri};

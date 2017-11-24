function [ica] = run_ica(cfg, input_variables)
% This function identifies independent components
%
% cfg can contain anything that ft_componentanalysis recognizes

ica = ft_componentanalysis(cfg, input_variables{1});
ica = {ica}; %% return as cell
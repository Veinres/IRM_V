%CREATE_PRECAL calculate and gather all the precalculated matrices
%==========================================================================
% If necessary, precomputes effective ionization costs, sputter yields and
% secondary electron emission yields. Existing data is loaded and stored
% in a new format suitable for use with the IRM code.
%==========================================================================

%% NOTES ------------------------------------------------------------------
% TODO: add check if file exists and call create_xy if that's not the case
% TODO: create function for general case (including creation of missing
% files)

%% ArTi
clear variables
load(fullfile('Ec/Ec_ArTi.mat'));
load(fullfile('Sputter_yield/Yield_ArTi.mat'));
load(fullfile('Secondary_e_yield/gamma_ArTi.mat'));
Precal.Ec = Ec;
Precal.Yield = Yield;
Precal.gamma = gamma;
save('Precal_ArTi', 'Precal')

%% ArW
clear variables
load(fullfile('Ec/Ec_ArW.mat'));
load(fullfile('Sputter_yield/Yield_ArW.mat'));
load(fullfile('Secondary_e_yield/gamma_ArW.mat'));
Precal.Ec = Ec;
Precal.Yield = Yield;
Precal.gamma = gamma;
save('Precal_ArW', 'Precal')

%% ArCu
clear variables
load(fullfile('Ec/Ec_ArCu'));
load(fullfile('Sputter_yield/Yield_ArCu'));
load(fullfile('Secondary_e_yield/gamma_ArCu'));
Precal.Ec = Ec;
Precal.Yield = Yield;
Precal.gamma = gamma;
save('Precal_ArCu', 'Precal')

%% ArCr
clear variables
load(fullfile('Ec/Ec_ArCr'));
load(fullfile('Sputter_yield/Yield_ArCr'));
load(fullfile('Secondary_e_yield/gamma_ArCr'));
Precal.Ec = Ec;
Precal.Yield = Yield;
Precal.gamma = gamma;
save('Precal_ArCr', 'Precal')

%% ArN2Ti
clear variables
load(fullfile('Ec/Ec_ArN2Ti'));
load(fullfile('Sputter_yield/Yield_ArN2Ti.mat'));
load(fullfile('Secondary_e_yield/gamma_ArN2Ti.mat'));
Precal.Ec=Ec;
Precal.Yield=Yield;
Precal.gamma=gamma;
save('Precal_ArN2Ti', 'Precal')

%% N2Ti
clear variables
load(fullfile('Ec/Ec_N2Ti'));
load(fullfile('Sputter_yield/Yield_N2Ti.mat'));
load(fullfile('Secondary_e_yield/gamma_N2Ti.mat'));
Precal.Ec=Ec;
Precal.Yield=Yield;
Precal.gamma=gamma;
save('Precal_N2Ti', 'Precal')

%% ArC
clear variables
load(fullfile('Ec/Ec_ArC'));
load(fullfile('Sputter_yield/Yield_ArC'));
load(fullfile('Secondary_e_yield/gamma_ArC'));
Precal.Ec = Ec;
Precal.Yield = Yield;
Precal.gamma = gamma;
save('Precal_ArC', 'Precal')


%% ArMo
clear variables
load(fullfile('Ec/Ec_ArMo'));
load(fullfile('Sputter_yield/Yield_ArMo'));
load(fullfile('Secondary_e_yield/gamma_ArMo'));
Precal.Ec = Ec;
Precal.Yield = Yield;
Precal.gamma = gamma;
save('Precal_ArMo', 'Precal')

%% HeMo
clear variables
load(fullfile('Ec/Ec_HeMo'));
load(fullfile('Sputter_yield/Yield_HeMo'));
load(fullfile('Secondary_e_yield/gamma_HeMo'));
Precal.Ec = Ec;
Precal.Yield = Yield;
Precal.gamma = gamma;
save('Precal_HeMo', 'Precal')

%% ArAl
clear variables
load(fullfile('Ec/Ec_ArAl'));
load(fullfile('Sputter_yield/Yield_ArAl'));
load(fullfile('Secondary_e_yield/gamma_ArAl'));
Precal.Ec = Ec;
Precal.Yield = Yield;
Precal.gamma = gamma;
save('Precal_ArAl', 'Precal')

%% ArW
clear variables
load(fullfile('Ec/Ec_ArW'));
load(fullfile('Sputter_yield/Yield_ArW'));
load(fullfile('Secondary_e_yield/gamma_ArW'));
Precal.Ec = Ec;
Precal.Yield = Yield;
Precal.gamma = gamma;
save('Precal_ArW', 'Precal')

%% ArZr
clear variables
load(fullfile('Ec/Ec_ArZr'));
load(fullfile('Sputter_yield/Yield_ArZr'));
load(fullfile('Secondary_e_yield/gamma_ArZr'));
Precal.Ec = Ec;
Precal.Yield = Yield;
Precal.gamma = gamma;
save('Precal_ArZr', 'Precal')

%% ArNeC
clear variables
load(fullfile('Ec/Ec_ArNeC'));
load(fullfile('Sputter_yield/Yield_ArNeC'));
load(fullfile('Secondary_e_yield/gamma_ArNeC'));
Precal.Ec = Ec;
Precal.Yield = Yield;
Precal.gamma = gamma;
save('Precal_ArNeC', 'Precal')

%% ArZr
clear variables
load(fullfile('Ec/Ec_ArZr'));
load(fullfile('Sputter_yield/Yield_ArZr'));
load(fullfile('Secondary_e_yield/gamma_ArZr'));
Precal.Ec = Ec;
Precal.Yield = Yield;
Precal.gamma = gamma;
save('Precal_ArZr', 'Precal')

%% ArSi
clear variables
load(fullfile('Ec/Ec_ArSi'));
load(fullfile('Sputter_yield/Yield_ArSi'));
load(fullfile('Secondary_e_yield/gamma_ArSi'));
Precal.Ec = Ec;
Precal.Yield = Yield;
Precal.gamma = gamma;
save('Precal_ArSi', 'Precal')
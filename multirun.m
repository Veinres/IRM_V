% DEPRECATED
% 
% disp("===== MULRIRUN.m =====");
% disp("The code can be used in different ways:");
% disp("1. In the new way shown here, inputs are defined before running the parameter scan.");
% disp("This can be a bit verbose and tidious, however it avoids having to modify any source files.");
% disp("2. The old way would be to modify some parameters directly in the respective source files.");
% disp("This can be handy, when some parameters are the same for all discharges of interest.");
% disp("The parameters that need to be set in the source files are:");
% disp("- the fitting parameter grid (set in panel_Pfit_fct.m)");
% disp("- the pulse length, the solver time, the discharge type and process pressure (set in create_input_fct.m)");
% disp("======================");
% 
% warning("Don't forget to change Para.mat if necessary!"); % NOTE : this is usually done by running the setup step below
% disp("Please read the above messages and press any key to continue when you're ready.")
% 
% % NOTE : The reason for this lies in the history of this project.
% % Previously the code was adapted for each case separately. I.e. there were
% % separate versions of the code for each discharge.
% % We're trying to bring them back together now,
% % but that process isn't quite finished yet.
% pause()

% Input parameters

% JF: Modify the parameters in this section.



%% ArZr Discharge .mat file
path_discharge  = 'ArSi_JF_smoothed'; % subfolder of discharge where the discharge .mat file is located
disch_mat       = 'ArSi_25_20A.mat'; % the name of the discharge .mat file (containing cv-waveforms)
% Results folder
path_results    = fullfile('results6_15.8eV_Uhtc_20mm_Hagstrum_Baragiola','ArSi_25_20A'); % path where the simulation output will be written to
% Parameter grid
Pfit.names      = {'f','beta','r'}; % don't change this
Pfit.p{1}       = 0.03:0.004:0.1; % parameter range for f (IR potential drop fraction)
Pfit.p{2}       = 0.7:0.01:.99; % parameter range for beta (back-attraction probability)
Pfit.p{3}       = 0.7:0.1:0.7; % parameter range for r (electron recapture probability)
% Discharge properties0.74
F_flux_meas     = 0.25; % measured ionized flux fraction, can also be specified directly in the disch structure 
IP.disch_type   = 'ArSi'; % the type of discharge {ArTi, ArW, ArC, ArCu}
IP.pressure     = 0.26; % process pressure, can also be specified directly in the disch structure
IP.pulseLength  = 27.1e-6; % cutoff for back-attraction(should correspond to the end of the voltage pulse)
IP.solverTime   = (0:1:100)*1e-6; % points in time for which the simulation produces results
 % IR dimensions
r1              = 6e-3; % inner radius of IR
r2              = 19e-3; % outer radius of IR
z1              = 2e-3; % distance of target facing border of IR from target
z2              = 20e-3; % distance of substrate facing border of IR from target
l1              = 0; % lenght in case of industrial rectangular target
% Tolerances for the Ionized Flux Fraction
F_flux_L_tol = 0.01; % lower tolerance (allowed deviation towards 0)
F_flux_U_tol = 0.01; % upper tolerance (allowed deviation towards 1)


%% Setup
util.fig.setDefaultStyle();
if exist(fullfile(path_results,path_discharge),'dir')
    warning("The specified results folder already exists. New results will be appended, but this might break the fitting procedure.");
    pause(5);
end
Pfit.dimension = cellfun(@(x) length(x), Pfit.p);
cd parameters
create_Para_new(r1,r2,z1,z2,l1);
cd ..

eval_only = false;

%% Simulation

if exist('Pfit','var') && exist('IP','var')
    % ===== The new way =====
    % This allows more control without having to edit other source files,
    % however it requires some extra inputs
    panel_Pfit_fct(path_discharge, disch_mat,...
                   fullfile(path_results, path_discharge), F_flux_meas, Pfit,...
                   eval_only, IP, F_flux_L_tol, F_flux_U_tol);
    % =======================
else
    % ===== The old way =====
    % This is the more minimal form, however it relies on default values.
    % It is only kept to allow older scripts to run. However it will
    % produce a lot of warnings.

    % MRu: this is an example command to run a fitting procedure. The last
    % parameter is the measured Fflux. Change the resolution of the fitting
    % procedure in panel_Pfit_fct.m.
    % JF: the pressure, pulse length and solver time have to be changed
    % in create_Input_fct.m if this form is used (not recommended!)
    warning("When using panel_pfit_fct without any optional arguments, a lot of parameters will fallback to hardcoded values which are all over the place. The code will produce a warning each time a default value is used.");
    disp("Please read the above warnings. Press any key if you want to proceed anyway. Press Ctrl+C to abort.")
    pause();
    panel_Pfit_fct(path_discharge, disch_mat,...
                   fullfile(path_results, path_discharge), F_flux_meas);
    % =======================
end

%% Other examples:

% JF: Clear all variables and then run the desired section by clicking into
% it and then pressing Ctrl+Enter.
% Do the same thing with the Setup section and then with the Simulation
% section

if false % NOTE : this bottom part is only for the manually running sections

    
%% ArCr 4 discharges

% Discharge .mat file
path_discharge  = 'ArCr'; % subfolder of discharge where the discharge .mat file is located disch_0.5Pa
disch_mat       = 'disch_Cr_0.4Acm2_25us.mat'; % the name of the discharge .mat file (containing cv-waveforms)
% Results folder
path_results    = fullfile('Current10','ArCr_04Acm2_25us_notCut'); % path where the simulation output will be written to
% Parameter grid
Pfit.names      = {'f','beta','r'}; % don't change this
Pfit.p{1}       = 0.04:0.01:0.12; % parameter range for f (IR potential drop fraction)
Pfit.p{2}       = 0.7:0.02:0.9; % parameter range for beta (back-attraction probability)
Pfit.p{3}       = 0.7:0.1:0.7; % parameter range for r (electron recapture probability)
% Discharge properties
F_flux_meas     = 0.1512696; % 1: 200 - 0.2757411, 150 - 0.3344278, 100 - 0.4176566, 75 - 0.4442518, 50 - 0.4626769, 25 - 0.492039
% 0.7: 200 0.1885358 , 150 0.194072, 100 0.2511132, 75 0.2567897, 50 0.2600242, 25 0.2843126
% 0.4 200 0.1223357, 150 0.1020571, 100 0.1342851, 75 0.1371172, 50 0.0992721, 25 0.1512696

IP.disch_type   = 'ArCr'; % the type of discharge {ArTi, ArW, ArC, ArCu}
IP.pressure     = 0.3; % process pressure, can also be specified directly in the disch structure
IP.pulseLength  = 80.1e-6; % 37.1-"25", 
IP.solverTime   = (0:1:350)*1e-6; % points in time for which the simulation produces results
% IR dimensions
r1              = 12e-3; % inner radius of IR
r2              = 52e-3; % outer radius of IR
z1              = 2e-3; % distance of target facing border of IR from target
z2              = 33e-3; % distance of substrate facing border of IR from target
l1              = 0;
% Tolerances for the Ionized Flux Fraction
F_flux_L_tol = 0.01; % lower tolerance (allowed deviation towards 0)
F_flux_U_tol = 0.01; % upper tolerance (allowed deviation towards 1)


%% ArAl

% Discharge .mat file
path_discharge  = 'disch_ArAl'; % subfolder of discharge where the discharge .mat file is located
disch_mat       = 'disch_Al_19A_100um_05Pa.mat'; % the name of the discharge .mat file (containing cv-waveforms)
% Results folder
path_results    = fullfile('letter3','Al_19A_100us_05Pa'); % path where the simulation output will be written to
% Parameter grid
Pfit.names      = {'f','beta','r'}; % don't change this
Pfit.p{1}       = 0.1:0.002:0.15; % parameter range for f (IR potential drop fraction)
Pfit.p{2}       = 0.7:0.005:0.8; % parameter range f  or beta (back-attraction probability)
Pfit.p{3}       = 0.7:0.1:0.7; % parameter range for r (electron recapture probability)
% Discharge properties 
F_flux_meas     = 0.5; % measured ionized flux fraction, can also be specified directly in the disch structure 0.5 for 0.5Pa, 0.38 for 2 Pa
IP.disch_type   = 'ArAl'; % the type of discharge {ArTi, ArW, ArC, ArCu}
IP.pressure     = 0.50; % process pressure, can also be specified directly in the disch structure
IP.pulseLength  = 105.1e-6; % cutoff for back-attraction (should correspond to the end of the voltage pulse)
IP.solverTime   = (0:1:300)*1e-6; % points in time for which the simulation produces results
% IR dimensions
r1              = 6e-3; % inner radius of IR
r2              = 20e-3; % outer radius of IR
z1              = 2e-3; % distance of target facing border of IR from target
z2              = 20e-3; % distance of substrate facing border of IR from target
l1              = 0;
% Tolerances for the Ionized Flux Fraction
F_flux_L_tol = 0.01; % lower tolerance (allowed deviation towards 0)
F_flux_U_tol = 0.01; % upper tolerance (allowed deviation towards 1)

%% ArZr Discharge .mat file
path_discharge  = 'Zr_HiPSTER'; % subfolder of discharge where the discharge .mat file is located
disch_mat       = 'disch_TVI_03a.mat'; % the name of the discharge .mat file (containing cv-waveforms)
% Results folder
path_results    = fullfile('letter3','ArZr_03_1Pa_10A_100us'); % path where the simulation output will be written to
% Parameter grid
Pfit.names      = {'f','beta','r'}; % don't change this
Pfit.p{1}       = 0.12:0.002:0.17; % parameter range for f (IR potential drop fraction)
Pfit.p{2}       = 0.7:0.005:.8; % parameter range for beta (back-attraction probability)
Pfit.p{3}       = 0.7:0.1:0.7; % parameter range for r (electron recapture probability)
% Discharge properties0.74
F_flux_meas     = 0.2548; % measured ionized flux fraction, can also be specified directly in the disch structure 03 0.2548
IP.disch_type   = 'ArZr'; % the type of discharge {ArTi, ArW, ArC, ArCu}
IP.pressure     = 1.0; % process pressure, can also be specified directly in the disch structure
IP.pulseLength  = 102.1e-6; % cutoff for back-attraction(should correspond to the end of the voltage pulse)
IP.solverTime   = (0:1:300)*1e-6; % points in time for which the simulation produces results
% IR dimensions
r1              = 6e-3; % inner radius of IR
r2              = 19e-3; % outer radius of IR
z1              = 2e-3; % distance of target facing border of IR from target
z2              = 13e-3; % distance of substrate facing border of IR from target
l1              = 0;
% Tolerances for the Ionized Flux Fraction
F_flux_L_tol = 0.01; % lower tolerance (allowed deviation towards 0)
F_flux_U_tol = 0.01; % upper tolerance (allowed deviation towards 1)

%% ArCr 4 discharges

% Discharge .mat file
path_discharge  = 'ArCr'; % subfolder of discharge where the discharge .mat file is located disch_0.5Pa
disch_mat       = 'disch_Cr_07Acm2_200us.mat'; % the name of the discharge .mat file (containing cv-waveforms)
% Results folder
path_results    = fullfile('TestCr','ArCr_07Acm2_200us_noCut'); % path where the simulation output will be written to
% Parameter grid
Pfit.names      = {'f','beta','r'}; % don't change this
Pfit.p{1}       = 0.04:0.005:0.09; % parameter range for f (IR potential drop fraction)
Pfit.p{2}       = 0.5:0.02:0.97; % parameter range for beta (1back-attraction probability)
Pfit.p{3}       = 0.7:0.1:0.7; % parameter range for r (electron recapture probability)
% Discharge properties
F_flux_meas     = 0.1885358; % 1: 200 - 0.2757411, 150 - 0.3344278, 100 - 0.4176566, 75 - 0.4442518, 50 - 0.4626769, 25 - 0.492039
% 0.7: 200 0.1885358 , 150 0.194072, 100 0.2511132, 75 0.2567897, 50 0.2600242, 25 0.2843126
% 0.4 200 0.1223357, 150 0.1020571, 100 0.1342851, 75 0.1371172, 50 0.0992721, 25 0.1512696

IP.disch_type   = 'ArCr'; % the type of discharge {ArTi, ArW, ArC, ArCu}
IP.pressure     = 0.3; % process pressure, can also be specified directly in the disch structure
IP.pulseLength  = 215.1e-6; % 37.1-"25", 
IP.solverTime   = (0:1:350)*1e-6; % points in time for which the simulation produces results
% IR dimensions
r1              = 12e-3; % inner radius of IR
r2              = 52e-3; % outer radius of IR
z1              = 2e-3; % distance of target facing border of IR from target
z2              = 25e-3; % distance of substrate facing border of IR from target
l1              = 0;
% Tolerances for the Ionized Flux Fraction
F_flux_L_tol = 0.03; % lower tolerance (allowed deviation towards 0)
F_flux_U_tol = 0.03; % upper tolerance (allowed deviation towards 1)

%% ArCu 2 discharges

% Discharge .mat file
path_discharge  = 'ArCu/follow-up'; % subfolder of discharge where the discharge .mat file is located disch_0.5Pa
disch_mat       = 'disch_28_180A_75us_0.5Pa.mat'; % the name of the discharge .mat file (containing cv-waveforms)
% Results folder
path_results    = fullfile('CuTest','ArCu_28_180A_75us_0.5Pa-finegrid-IRr38'); % path where the simulation output will be written to
% Parameter grid
Pfit.names      = {'f','beta','r'}; % don't change this
Pfit.p{1}       = 0.05:0.01:0.20; % parameter range for f (IR potential drop fraction)
Pfit.p{2}       = 0.35:0.01:0.70; % parameter range for beta (back-attraction probability)
Pfit.p{3}       = 0.7:0.1:0.7; % parameter range for r (electron recapture probability)
% Discharge properties
F_flux_meas     = 0.588; %0.588 - 180, 0.73 - 225, 0.578 - 248, 0.6545б 0.54 - 270 A
IP.disch_type   = 'ArCu'; % the type of discharge {ArTi, ArW, ArC, ArCu}
IP.pressure     = 0.5; % process pressure, can also be specified directly in the disch structure
IP.pulseLength  = 81.1e-6; % cutoff for back-attraction (should correspond to the end of the voltage pulse)
IP.solverTime   = (0:1:180)*1e-6; % points in time for which the simulation produces results
% IR dimensions
r1              = 12e-3; % inner radius of IR
r2              = 38e-3; % outer radius of IR
z1              = 2e-3; % distance of target facing border of IR from target
z2              = 33e-3; % distance of substrate facing border of IR from target
l1              = 0;
% Tolerances for the Ionized Flux Fraction
F_flux_L_tol = 0.025; % lower tolerance (allowed deviation towards 0)
F_flux_U_tol = 0.025; % upper tolerance (allowed deviation towards 1)




end

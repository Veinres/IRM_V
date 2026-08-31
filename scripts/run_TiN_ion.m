% Run test cases for (Ar)/N2/Ti IRM

plot_summaries = true;  % plot summaries of each parameter scan
close_plots = true;    % automatically close plots after parameter scan
pause_before = false;   % pause before closing plots
clear_folders = true;  % delete run_Pfit folders after collecting results
by_revision = false;    % output to a revision folder
force_sequential = false;% whether to force sequential execution (useful for debugging)
grid = 'custom';        % select parameter grid that should be used
                        % 'custom'      : use a custom parameter grid for each discharge
                        % 'superfast'   : an extremely sparse grid for very low execution time
                        % 'fast'        : a very sparse grid for low execution time
                        % 'normal'      : normal grid if you have more time

discharges = {};

discharges{end+1} = 'TiN_i08_0.0sccm_2'; % ArTi : ArTi
discharges{end+1} = 'TiN_i08_0.0sccm_2_ArN2Ti'; % ArTi : ArN2Ti

discharges{end+1} = 'TiN_i08_2.5sccm_3_ArTi'; % ArN2Ti : ArTi
discharges{end+1} = 'TiN_i08_2.5sccm_3_ArN2Ti_noN2'; % ArN2Ti : ArN2Ti w/o N2
discharges{end+1} = 'TiN_i08_2.5sccm_3_ArN2Ti'; % ArN2Ti : ArN2Ti

discharges{end+1} = 'TiN_i08_20.0sccm_7'; % ArN2Ti : ArN2Ti

discharges{end+1} = 'TiN_ip02_20.0sccm_5_ArN2Ti'; % N2Ti : ArN2Ti
discharges{end+1} = 'TiN_ip02_20.0sccm_5'; % N2Ti : N2Ti

discharges{end+1} = 'TiN_i08_10.0sccm_11'; % ArN2Ti : ArN2Ti

discharges{end+1} = 'TiN_i08-2_10.0sccm_12'; % ArN2Ti : ArN2Ti

% Setup
subfolder = 'TiN-impl';
if by_revision
    [rev, branch] = util.git.head();
    subfolder = fullfile(subfolder, branch, rev, grid);
else
    subfolder = fullfile(subfolder, grid);
end

F_flux_meas = NaN;

%% TiN_i08_0.0sccm_2

scan_name = 'TiN_i08_0.0sccm_2';
if ismember('TiN_i08_0.0sccm_2', discharges)

% Discharge .mat file
path_discharge  = 'TiN-ion-sfcb'; % subfolder of discharge where the discharge .mat file is located
disch_mat       = 'TiN_i08_0.0sccm_2.mat'; % the name of the discharge .mat file (containing cv-waveforms)
% Results folder
path_results    = fullfile('results', 'TiN_i08_0.0sccm_2', subfolder); % path where the simulation output will be written to
% Parameter grid
Pfit = setupParameterGrid(grid, ...
    0.075:0.01:0.30, ... % custom parameter range for f (IR potential drop fraction)
    0.5:0.01:1, ...     % custom parameter range for beta (back-attraction probability)
    0.7:0.1:0.7);       % custom parameter range for r (electron recapture probability)
% Discharge properties
% F_flux_meas     = 0.15; % measured ionized flux fraction, can also be specified directly in the disch structure
IP.disch_type   = 'ArTi'; % the type of discharge {ArTi, ArW, ArC, ArCu}
IP.pressure     = 0.5; % process pressure, can also be specified directly in the disch structure
IP.pp_Ar        = IP.pressure;
IP.pp_N2        = 0.;
IP.compound_fraction = 0.;
IP.pulseLength  = 100.3e-6; % cutoff for back-attraction (should correspond to the end of the voltage pulse)
IP.solverTime   = (1:1:300)*1e-6; % points in time for which the simulation produces results
% IR dimensions
r1              = 6e-3; % inner radius of IR
r2              = 19e-3; % outer radius of IR
z1              = 2e-3; % distance of target facing border of IR from target
z2              = 20e-3; % distance of substrate facing border of IR from target
% Tolerances for the Ionized Flux Fraction
F_flux_L_tol = 0.025; % lower tolerance (allowed deviation towards 0)
F_flux_U_tol = 0.025; % upper tolerance (allowed deviation towards 1)

[summary, metadata, results, inputs, outputs, best] = setupAndRun( ...
    path_results, path_discharge, Pfit, r1, r2, z1, z2, ...
    disch_mat, F_flux_meas, IP, F_flux_L_tol, F_flux_U_tol, force_sequential, scan_name);
plotSummary(summary, metadata, results, inputs, outputs, ...
    plot_summaries, close_plots, pause_before, path_results, path_discharge);
cleanUp(path_results, path_discharge, clear_folders);

end

%% TiN_i08_0.0sccm_2_ArN2Ti

scan_name = 'TiN_i08_0.0sccm_2_ArN2Ti';
if ismember('TiN_i08_0.0sccm_2_ArN2Ti', discharges)

% Discharge .mat file
path_discharge  = 'TiN-ion-sfcb'; % subfolder of discharge where the discharge .mat file is located
disch_mat       = 'TiN_i08_0.0sccm_2.mat'; % the name of the discharge .mat file (containing cv-waveforms)
% Results folder
path_results    = fullfile('results', 'TiN_i08_0.0sccm_2_ArN2Ti', subfolder); % path where the simulation output will be written to
% Parameter grid
Pfit = setupParameterGrid(grid, ...
    0.075:0.01:0.30, ... % custom parameter range for f (IR potential drop fraction)
    0.5:0.01:1, ...     % custom parameter range for beta (back-attraction probability)
    0.7:0.1:0.7);       % custom parameter range for r (electron recapture probability)
% Discharge properties
% F_flux_meas     = 0.15; % measured ionized flux fraction, can also be specified directly in the disch structure
IP.disch_type   = 'ArN2Ti'; % the type of discharge {ArTi, ArW, ArC, ArCu}
IP.pressure     = 0.5; % process pressure, can also be specified directly in the disch structure
IP.pp_Ar        = IP.pressure;
IP.pp_N2        = 0.;
IP.compound_fraction = 0.;
IP.pulseLength  = 100.3e-6; % cutoff for back-attraction (should correspond to the end of the voltage pulse)
IP.solverTime   = (1:1:300)*1e-6; % points in time for which the simulation produces results
% IR dimensions
r1              = 6e-3; % inner radius of IR
r2              = 19e-3; % outer radius of IR
z1              = 2e-3; % distance of target facing border of IR from target
z2              = 20e-3; % distance of substrate facing border of IR from target
% Tolerances for the Ionized Flux Fraction
F_flux_L_tol = 0.025; % lower tolerance (allowed deviation towards 0)
F_flux_U_tol = 0.025; % upper tolerance (allowed deviation towards 1)

[summary, metadata, results, inputs, outputs, best] = setupAndRun( ...
    path_results, path_discharge, Pfit, r1, r2, z1, z2, ...
    disch_mat, F_flux_meas, IP, F_flux_L_tol, F_flux_U_tol, force_sequential, scan_name);
plotSummary(summary, metadata, results, inputs, outputs, ...
    plot_summaries, close_plots, pause_before, path_results, path_discharge);
cleanUp(path_results, path_discharge, clear_folders);

end

%% TiN_i08_2.5sccm_3_ArTi
scan_name = 'TiN_i08_2.5sccm_3_ArTi';
if ismember('TiN_i08_2.5sccm_3_ArTi', discharges)

% Discharge .mat file
path_discharge  = 'TiN-ion-sfcb'; % subfolder of discharge where the discharge .mat file is located
disch_mat       = 'TiN_i08_2.5sccm_3.mat'; % the name of the discharge .mat file (containing cv-waveforms)
% Results folder
path_results    = fullfile('results', 'TiN_i08_2.5sccm_3_ArTi', subfolder); % path where the simulation output will be written to
% Parameter grid
Pfit = setupParameterGrid(grid, ...
    0.05:0.01:0.275, ... % custom parameter range for f (IR potential drop fraction)
    0.5:0.01:1, ...     % custom parameter range for beta (back-attraction probability)
    0.7:0.1:0.7);       % custom parameter range for r (electron recapture probability)
% Discharge properties
% F_flux_meas     = 0.15; % measured ionized flux fraction, can also be specified directly in the disch structure
IP.disch_type   = 'ArTi'; % the type of discharge {ArTi, ArW, ArC, ArCu}
IP.pressure     = 0.51; % process pressure, can also be specified directly in the disch structure
IP.pp_Ar        = IP.pressure;
IP.pp_N2        = 0.;
IP.compound_fraction = 0.;
IP.pulseLength  = 100.3e-6; % cutoff for back-attraction (should correspond to the end of the voltage pulse)
IP.solverTime   = (0:1:300)*1e-6; % points in time for which the simulation produces results
% IR dimensions
r1              = 6e-3; % inner radius of IR
r2              = 19e-3; % outer radius of IR
z1              = 2e-3; % distance of target facing border of IR from target
z2              = 20e-3; % distance of substrate facing border of IR from target
% Tolerances for the Ionized Flux Fraction
F_flux_L_tol = 0.025; % lower tolerance (allowed deviation towards 0)
F_flux_U_tol = 0.025; % upper tolerance (allowed deviation towards 1)

[summary, metadata, results, inputs, outputs, best] = setupAndRun( ...
    path_results, path_discharge, Pfit, r1, r2, z1, z2, ...
    disch_mat, F_flux_meas, IP, F_flux_L_tol, F_flux_U_tol, force_sequential, scan_name);
plotSummary(summary, metadata, results, inputs, outputs, ...
    plot_summaries, close_plots, pause_before, path_results, path_discharge);
cleanUp(path_results, path_discharge, clear_folders);

end

%% TiN_i08_2.5sccm_3_ArN2Ti_noN2
scan_name = 'TiN_i08_2.5sccm_3_ArN2Ti_noN2';
if ismember('TiN_i08_2.5sccm_3_ArN2Ti_noN2', discharges)

% Discharge .mat file
path_discharge  = 'TiN-ion-sfcb'; % subfolder of discharge where the discharge .mat file is located
disch_mat       = 'TiN_i08_2.5sccm_3.mat'; % the name of the discharge .mat file (containing cv-waveforms)
% Results folder
path_results    = fullfile('results', 'TiN_i08_2.5sccm_3_ArN2Ti_noN2', subfolder); % path where the simulation output will be written to
% Parameter grid
Pfit = setupParameterGrid(grid, ...
    0.025:0.01:0.25, ... % custom parameter range for f (IR potential drop fraction)
    0.5:0.01:1, ...     % custom parameter range for beta (back-attraction probability)
    0.7:0.1:0.7);       % custom parameter range for r (electron recapture probability)
% Discharge properties
% F_flux_meas     = 0.15; % measured ionized flux fraction, can also be specified directly in the disch structure
IP.disch_type   = 'ArN2Ti'; % the type of discharge {ArTi, ArW, ArC, ArCu}
IP.pressure     = 0.51; % process pressure, can also be specified directly in the disch structure
IP.pp_Ar        = IP.pressure;
IP.pp_N2        = 0.;
IP.compound_fraction = 0.36;
IP.pulseLength  = 100.3e-6; % cutoff for back-attraction (should correspond to the end of the voltage pulse)
IP.solverTime   = (0:1:300)*1e-6; % points in time for which the simulation produces results
% IR dimensions
r1              = 6e-3; % inner radius of IR
r2              = 19e-3; % outer radius of IR
z1              = 2e-3; % distance of target facing border of IR from target
z2              = 20e-3; % distance of substrate facing border of IR from target
% Tolerances for the Ionized Flux Fraction
F_flux_L_tol = 0.025; % lower tolerance (allowed deviation towards 0)
F_flux_U_tol = 0.025; % upper tolerance (allowed deviation towards 1)

[summary, metadata, results, inputs, outputs, best] = setupAndRun( ...
    path_results, path_discharge, Pfit, r1, r2, z1, z2, ...
    disch_mat, F_flux_meas, IP, F_flux_L_tol, F_flux_U_tol, force_sequential, scan_name);
plotSummary(summary, metadata, results, inputs, outputs, ...
    plot_summaries, close_plots, pause_before, path_results, path_discharge);
cleanUp(path_results, path_discharge, clear_folders);

end

%% TiN_i08_2.5sccm_3_ArN2Ti
scan_name = 'TiN_i08_2.5sccm_3_ArN2Ti';
if ismember('TiN_i08_2.5sccm_3_ArN2Ti', discharges)

% Discharge .mat file
path_discharge  = 'TiN-ion-sfcb'; % subfolder of discharge where the discharge .mat file is located
disch_mat       = 'TiN_i08_2.5sccm_3.mat'; % the name of the discharge .mat file (containing cv-waveforms)
% Results folder
path_results    = fullfile('results', 'TiN_i08_2.5sccm_3_ArN2Ti', subfolder); % path where the simulation output will be written to
% Parameter grid
Pfit = setupParameterGrid(grid, ...
    0.025:0.01:0.25, ... % custom parameter range for f (IR potential drop fraction)
    0.5:0.01:1, ...     % custom parameter range for beta (back-attraction probability)
    0.7:0.1:0.7);       % custom parameter range for r (electron recapture probability)
% Discharge properties
% F_flux_meas     = 0.15; % measured ionized flux fraction, can also be specified directly in the disch structure
IP.disch_type   = 'ArN2Ti'; % the type of discharge {ArTi, ArW, ArC, ArCu}
IP.pressure     = 0.51; % process pressure, can also be specified directly in the disch structure
IP.pp_Ar        = 0.5;
IP.pp_N2        = 0.01;
IP.compound_fraction = 0.36;
IP.pulseLength  = 100.3e-6; % cutoff for back-attraction (should correspond to the end of the voltage pulse)
IP.solverTime   = (0:1:300)*1e-6; % points in time for which the simulation produces results
% IR dimensions
r1              = 6e-3; % inner radius of IR
r2              = 19e-3; % outer radius of IR
z1              = 2e-3; % distance of target facing border of IR from target
z2              = 20e-3; % distance of substrate facing border of IR from target
% Tolerances for the Ionized Flux Fraction
F_flux_L_tol = 0.025; % lower tolerance (allowed deviation towards 0)
F_flux_U_tol = 0.025; % upper tolerance (allowed deviation towards 1)

[summary, metadata, results, inputs, outputs, best] = setupAndRun( ...
    path_results, path_discharge, Pfit, r1, r2, z1, z2, ...
    disch_mat, F_flux_meas, IP, F_flux_L_tol, F_flux_U_tol, force_sequential, scan_name);
plotSummary(summary, metadata, results, inputs, outputs, ...
    plot_summaries, close_plots, pause_before, path_results, path_discharge);
cleanUp(path_results, path_discharge, clear_folders);

end

%% TiN_i08_20sccm_7
scan_name = 'TiN_i08_20.0sccm_7';
if ismember('TiN_i08_20.0sccm_7', discharges)

% Discharge .mat file
path_discharge  = 'TiN-ion-sfcb'; % subfolder of discharge where the discharge .mat file is located
disch_mat       = 'TiN_i08_20.0sccm_7.mat'; % the name of the discharge .mat file (containing cv-waveforms)
% Results folder
path_results    = fullfile('results', 'TiN_i08_20.0sccm_7', subfolder); % path where the simulation output will be written to
% Parameter grid
Pfit = setupParameterGrid(grid, ...
    0.025:0.01:0.25, ... % custom parameter range for f (IR potential drop fraction)
    0.5:0.01:1, ...     % custom parameter range for beta (back-attraction probability)
    0.7:0.1:0.7);       % custom parameter range for r (electron recapture probability)
% Discharge properties
F_flux_meas     = 0.15; % measured ionized flux fraction, can also be specified directly in the disch structure
IP.disch_type   = 'ArN2Ti'; % the type of discharge {ArTi, ArW, ArC, ArCu}
IP.pressure     = 0.6; % process pressure, can also be specified directly in the disch structure
IP.pp_Ar        = 0.5;
IP.pp_N2        = 0.1;
IP.compound_fraction = 1.0;
IP.pulseLength  = 100.3e-6; % cutoff for back-attraction (should correspond to the end of the voltage pulse)
IP.solverTime   = (0:1:300)*1e-6; % points in time for which the simulation produces results
% IR dimensions
r1              = 6e-3; % inner radius of IR
r2              = 19e-3; % outer radius of IR
z1              = 2e-3; % distance of target facing border of IR from target
z2              = 20e-3; % distance of substrate facing border of IR from target
% Tolerances for the Ionized Flux Fraction
F_flux_L_tol = 0.025; % lower tolerance (allowed deviation towards 0)
F_flux_U_tol = 0.025; % upper tolerance (allowed deviation towards 1)

[summary, metadata, results, inputs, outputs, best] = setupAndRun( ...
    path_results, path_discharge, Pfit, r1, r2, z1, z2, ...
    disch_mat, F_flux_meas, IP, F_flux_L_tol, F_flux_U_tol, force_sequential, scan_name);
plotSummary(summary, metadata, results, inputs, outputs, ...
    plot_summaries, close_plots, pause_before, path_results, path_discharge);
cleanUp(path_results, path_discharge, clear_folders);

end

%% TiN_i08_10sccm_11
scan_name = 'TiN_i08_10.0sccm_11';
if ismember('TiN_i08_10.0sccm_11', discharges)

% Discharge .mat file
path_discharge  = 'TiN-ion-sfcb'; % subfolder of discharge where the discharge .mat file is located
disch_mat       = 'TiN_i08_10.0sccm_11.mat'; % the name of the discharge .mat file (containing cv-waveforms)
% Results folder
path_results    = fullfile('results', 'TiN_i08_10.0sccm_11', subfolder); % path where the simulation output will be written to
% Parameter grid
Pfit = setupParameterGrid(grid, ...
    0.025:0.01:0.25, ... % custom parameter range for f (IR potential drop fraction)
    0.5:0.01:1, ...     % custom parameter range for beta (back-attraction probability)
    0.7:0.1:0.7);       % custom parameter range for r (electron recapture probability)
% Discharge properties
F_flux_meas     = 0.15; % measured ionized flux fraction, can also be specified directly in the disch structure
IP.disch_type   = 'ArN2Ti'; % the type of discharge {ArTi, ArW, ArC, ArCu}
IP.pressure     = 0.55; % process pressure, can also be specified directly in the disch structure
IP.pp_Ar        = 0.5;
IP.pp_N2        = 0.05;
IP.compound_fraction = 1.0;
IP.pulseLength  = 100.3e-6; % cutoff for back-attraction (should correspond to the end of the voltage pulse)
IP.solverTime   = (0:1:300)*1e-6; % points in time for which the simulation produces results
% IR dimensions
r1              = 6e-3; % inner radius of IR
r2              = 19e-3; % outer radius of IR
z1              = 2e-3; % distance of target facing border of IR from target
z2              = 20e-3; % distance of substrate facing border of IR from target
% Tolerances for the Ionized Flux Fraction
F_flux_L_tol = 0.025; % lower tolerance (allowed deviation towards 0)
F_flux_U_tol = 0.025; % upper tolerance (allowed deviation towards 1)

[summary, metadata, results, inputs, outputs, best] = setupAndRun( ...
    path_results, path_discharge, Pfit, r1, r2, z1, z2, ...
    disch_mat, F_flux_meas, IP, F_flux_L_tol, F_flux_U_tol, force_sequential, scan_name);
plotSummary(summary, metadata, results, inputs, outputs, ...
    plot_summaries, close_plots, pause_before, path_results, path_discharge);
cleanUp(path_results, path_discharge, clear_folders);

end

%% TiN_i08-2_10sccm_12
scan_name = 'TiN_i08-2_10.0sccm_12';
if ismember('TiN_i08-2_10.0sccm_12', discharges)

% Discharge .mat file
path_discharge  = 'TiN-ion-sfcb'; % subfolder of discharge where the discharge .mat file is located
disch_mat       = 'TiN_i08-2_10.0sccm_12.mat'; % the name of the discharge .mat file (containing cv-waveforms)
% Results folder
path_results    = fullfile('results', 'TiN_i08-2_10.0sccm_12', subfolder); % path where the simulation output will be written to
% Parameter grid
Pfit = setupParameterGrid(grid, ...
    0.025:0.01:0.25, ... % custom parameter range for f (IR potential drop fraction)
    0.5:0.01:1, ...     % custom parameter range for beta (back-attraction probability)
    0.7:0.1:0.7);       % custom parameter range for r (electron recapture probability)
% Discharge properties
F_flux_meas     = 0.15; % measured ionized flux fraction, can also be specified directly in the disch structure
IP.disch_type   = 'ArN2Ti'; % the type of discharge {ArTi, ArW, ArC, ArCu}
IP.pressure     = 0.55; % process pressure, can also be specified directly in the disch structure
IP.pp_Ar        = 0.5;
IP.pp_N2        = 0.05;
IP.compound_fraction = 1.0;
IP.pulseLength  = 100.3e-6; % cutoff for back-attraction (should correspond to the end of the voltage pulse)
IP.solverTime   = (0:1:300)*1e-6; % points in time for which the simulation produces results
% IR dimensions
r1              = 6e-3; % inner radius of IR
r2              = 19e-3; % outer radius of IR
z1              = 2e-3; % distance of target facing border of IR from target
z2              = 20e-3; % distance of substrate facing border of IR from target
% Tolerances for the Ionized Flux Fraction
F_flux_L_tol = 0.025; % lower tolerance (allowed deviation towards 0)
F_flux_U_tol = 0.025; % upper tolerance (allowed deviation towards 1)

[summary, metadata, results, inputs, outputs, best] = setupAndRun( ...
    path_results, path_discharge, Pfit, r1, r2, z1, z2, ...
    disch_mat, F_flux_meas, IP, F_flux_L_tol, F_flux_U_tol, force_sequential, scan_name);
plotSummary(summary, metadata, results, inputs, outputs, ...
    plot_summaries, close_plots, pause_before, path_results, path_discharge);
cleanUp(path_results, path_discharge, clear_folders);

end

%% TiN_ip02_20.0sccm_5
scan_name = 'TiN_ip02_20.0sccm_5';
if ismember('TiN_ip02_20.0sccm_5', discharges)

% Discharge .mat file
path_discharge  = 'TiN-ion-sfcb'; % subfolder of discharge where the discharge .mat file is located
disch_mat       = 'TiN_ip02_20.0sccm_5.mat'; % the name of the discharge .mat file (containing cv-waveforms)
% Results folder
path_results    = fullfile('results', 'TiN_ip02_20.0sccm_5', subfolder); % path where the simulation output will be written to
% Parameter grid
Pfit = setupParameterGrid(grid, ...
    0.025:0.01:0.25, ... % custom parameter range for f (IR potential drop fraction)
    0.3:0.01:1, ...     % custom parameter range for beta (back-attraction probability)
    0.7:0.1:0.7);       % custom parameter range for r (electron recapture probability)
% Discharge properties
% F_flux_meas     = 0.05; % measured ionized flux fraction, can also be specified directly in the disch structure
IP.disch_type   = 'N2Ti'; % the type of discharge {ArTi, ArW, ArC, ArCu}
IP.pressure     = 1.0; % process pressure, can also be specified directly in the disch structure
IP.pp_Ar        = 0;
IP.pp_N2        = IP.pressure;
IP.compound_fraction = 0.1;
IP.pulseLength  = 100.3e-6; % cutoff for back-attraction (should correspond to the end of the voltage pulse)
IP.solverTime   = (0:1:300)*1e-6; % points in time for which the simulation produces results
% IR dimensions
r1              = 6e-3; % inner radius of IR
r2              = 19e-3; % outer radius of IR
z1              = 2e-3; % distance of target facing border of IR from target
z2              = 20e-3; % distance of substrate facing border of IR from target
% Tolerances for the Ionized Flux Fraction
F_flux_L_tol = 0.025; % lower tolerance (allowed deviation towards 0)
F_flux_U_tol = 0.025; % upper tolerance (allowed deviation towards 1)

[summary, metadata, results, inputs, outputs, best] = setupAndRun( ...
    path_results, path_discharge, Pfit, r1, r2, z1, z2, ...
    disch_mat, F_flux_meas, IP, F_flux_L_tol, F_flux_U_tol, force_sequential, scan_name);
plotSummary(summary, metadata, results, inputs, outputs, ...
    plot_summaries, close_plots, pause_before, path_results, path_discharge);
cleanUp(path_results, path_discharge, clear_folders);

end

%% TiN_ip02_20.0sccm_5_ArN2Ti
scan_name = 'TiN_ip02_20.0sccm_5_ArN2Ti';
if ismember('TiN_ip02_20.0sccm_5_ArN2Ti', discharges)

% Discharge .mat file
path_discharge  = 'TiN-ion-sfcb'; % subfolder of discharge where the discharge .mat file is located
disch_mat       = 'TiN_ip02_20.0sccm_5.mat'; % the name of the discharge .mat file (containing cv-waveforms)
% Results folder
path_results    = fullfile('results', 'TiN_ip02_20.0sccm_5_ArN2Ti', subfolder); % path where the simulation output will be written to
% Parameter grid
Pfit = setupParameterGrid(grid, ...
    0.025:0.01:0.25, ... % custom parameter range for f (IR potential drop fraction)
    0.5:0.01:1, ...     % custom parameter range for beta (back-attraction probability)
    0.7:0.1:0.7);       % custom parameter range for r (electron recapture probability)
% Discharge properties
% F_flux_meas     = 0.05; % measured ionized flux fraction, can also be specified directly in the disch structure
IP.disch_type   = 'ArN2Ti'; % the type of discharge {ArTi, ArW, ArC, ArCu}
IP.pressure     = 1.0; % process pressure, can also be specified directly in the disch structure
IP.pp_Ar        = 0;
IP.pp_N2        = IP.pressure;
IP.compound_fraction = 0.1;
IP.pulseLength  = 100.3e-6; % cutoff for back-attraction (should correspond to the end of the voltage pulse)
IP.solverTime   = (0:1:300)*1e-6; % points in time for which the simulation produces results
% IR dimensions
r1              = 6e-3; % inner radius of IR
r2              = 19e-3; % outer radius of IR
z1              = 2e-3; % distance of target facing border of IR from target
z2              = 20e-3; % distance of substrate facing border of IR from target
% Tolerances for the Ionized Flux Fraction
F_flux_L_tol = 0.025; % lower tolerance (allowed deviation towards 0)
F_flux_U_tol = 0.025; % upper tolerance (allowed deviation towards 1)

[summary, metadata, results, inputs, outputs, best] = setupAndRun( ...
    path_results, path_discharge, Pfit, r1, r2, z1, z2, ...
    disch_mat, F_flux_meas, IP, F_flux_L_tol, F_flux_U_tol, force_sequential, scan_name);
plotSummary(summary, metadata, results, inputs, outputs, ...
    plot_summaries, close_plots, pause_before, path_results, path_discharge);
cleanUp(path_results, path_discharge, clear_folders);

end

%% Function definitions

function [summary, metadata, results, inputs, outputs, best] = setupAndRun( ...
    path_results_folder, path_discharge, Pfit, r1, r2, z1, z2, ...
    disch_mat, F_flux_meas, IP, F_flux_L_tol, F_flux_U_tol, ...
    force_sequential, scan_name)
    % This is just here to make the code a bit more readable
    util.fig.setDefaultStyle();
    path_to_results = fullfile(path_results_folder, path_discharge);
    if exist(path_to_results, 'dir')
        warning("The specified results folder already exists. New results will be appended, but this might break the fitting procedure.");
        pause(5);
    end
    Pfit.dimension = cellfun(@(x) length(x), Pfit.p);
    cd parameters
    if isfield('compound_fraction',IP)
        create_Para_new(r1, r2, z1, z2, 'CompoundFraction', IP.compound_fraction);
    else
        create_Para_new(r1, r2, z1, z2);
    end
    cd ..
    eval_only = false;
    panel_Pfit_fct(path_discharge, disch_mat,...
                   path_to_results, F_flux_meas, Pfit,...
                   eval_only, IP, F_flux_L_tol, F_flux_U_tol, false, ...
                   force_sequential, scan_name);
    % collect the results from the entire scan in a convenient structure
    [~, name, ext] = fileparts(path_to_results);
    [summary, metadata, results, inputs, outputs, best] = ...
        rslt.scan.collect( ...
        path_to_results, ...
        "Id", strcat(name, ext), ...
        "FFluxLim", F_flux_meas + [-F_flux_L_tol, F_flux_U_tol], ...
        "SaveLocation", strcat(path_to_results, '.mat'));
end

function plotSummary(summary, metadata, results, inputs, outputs, ...
    plot_summaries, close_plots, pause_before, path_results, path_discharge)
    if plot_summaries
        [fig1, fig2] = plt.scan.summary(summary, metadata, results, inputs, outputs);
        saveas(fig1, fullfile(path_results, path_discharge, 's1'), 'fig');
        saveas(fig2, fullfile(path_results, path_discharge, 's2'), 'fig');
        if close_plots
            if pause_before
                pause();
            end
            close all;
        end
    end
end

function cleanUp(path_results, path_discharge, clear_folders)
    if clear_folders
        suffixes = {'','_flux','_fom'};
        for i = 1:length(suffixes)
            folder = fullfile(path_results, strcat(path_discharge, suffixes{i}));
            try
                rmdir(fullfile(folder, 'run_Pfit*'), 's');
                rmdir(fullfile(folder));
            catch
            end
        end
        % warning("Remember to check and clear the wastebin.");
    end
end

function Pfit = setupParameterGrid(grid, custom_f, custom_beta, custom_r)
    Pfit.names = {'f','beta','r'}; % don't change this
    switch grid
        case 'superfast'
            Pfit.p{1}  = 0.0:0.05:0.25; % parameter range for f (IR potential drop fraction)
            Pfit.p{2}  = 0.0:0.2:1; % parameter range for beta (back-attraction probability)
            Pfit.p{3}  = 0.7:0.1:0.7; % parameter range for r (electron recapture probability)
        case 'fast'
            Pfit.p{1}  = 0.05:0.05:0.25; % parameter range for f (IR potential drop fraction)
            Pfit.p{2}  = 0.0:0.1:1; % parameter range for beta (back-attraction probability)
            Pfit.p{3}  = 0.7:0.1:0.7; % parameter range for r (electron recapture probability)
        case 'normal'
            Pfit.p{1}= 0.0:0.025:0.25; % parameter range for f (IR potential drop fraction)
            Pfit.p{2}= 0.0:0.05:1; % parameter range for beta (back-attraction probability)
            Pfit.p{3}= 0.7:0.1:0.7; % parameter range for r (electron recapture probability)
        otherwise
            Pfit.p{1}= custom_f; % parameter range for f (IR potential drop fraction)
            Pfit.p{2}= custom_beta; % parameter range for beta (back-attraction probability)
            Pfit.p{3}= custom_r; % parameter range for r (electron recapture probability)
    end
end
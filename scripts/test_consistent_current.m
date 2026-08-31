% Run a reference/test case for each of the currently implemented materials

plot_summaries = true;  % plot summaries of each parameter scan
close_plots = true;     % automatically close plots after parameter scan
pause_before = false;   % pause before closing plots
clear_folders = true;   % delete run_Pfit folders after collecting results
by_revision = true;     % output to a revision folder
consistent_current = 0:0.1:1; % use IRM current for power equation

% select parameter grid that should be used
grid = 'fast'; % use a custom parameter grid for each discharge
% grid = 'fast'; % a very sparse grid for low execution time
% grid = 'normal'; % normal grid if you have more time

disch_types = {};
% Comment out discharge types to skip
% disch_types{end+1} = 'ArTi';
% disch_types{end+1} = 'ArC';
disch_types{end+1} = 'ArCu';
% disch_types{end+1} = 'ArW';
% disch_types{end+1} = 'ArMo';
% disch_types{end+1} = 'HeMo';

% Setup
folder = 'results/scc/';
subfolder = 'results';
if by_revision
    [rev, branch] = util.git.head();
    subfolder = fullfile('results',branch,rev,grid);
end

% grids
fast_grid.names = {'f','beta','r'}; % don't change this
fast_grid.p{1}  = 0.0:0.05:0.25; % parameter range for f (IR potential drop fraction)
fast_grid.p{2}  = 0.0:0.1:1; % parameter range for beta (back-attraction probability)
fast_grid.p{3}  = 0.7:0.1:0.7; % parameter range for r (electron recapture probability)
normal_grid.names = {'f','beta','r'}; % don't change this
normal_grid.p{1}= 0.0:0.025:0.25; % parameter range for f (IR potential drop fraction)
normal_grid.p{2}= 0.0:0.05:1; % parameter range for beta (back-attraction probability)
normal_grid.p{3}= 0.7:0.1:0.7; % parameter range for r (electron recapture probability)

%% ArCu
if contains('ArCu', disch_types)
for cc_fraction = consistent_current
% The given example is a 40us Copper discharge on a 2" magnetron at 0.5Pa
% which was published in Gudmundsson 2022, Surf. Coat. Technol. 442, 128189
% https://doi.org/10.1016/j.surfcoat.2022.128189

% Discharge .mat file
path_discharge  = 'ArCu/original/ArCu_HiPSTER_20A'; % subfolder of discharge where the discharge .mat file is located
disch_mat       = 'disch.mat'; % the name of the discharge .mat file (containing cv-waveforms)
% Results folder
path_results    = fullfile(folder, strcat(subfolder,sprintf('_cc%4.2f', cc_fraction)), 'ArCu'); % path where the simulation output will be written to
% Parameter grid
switch grid
    case 'fast'
        Pfit = fast_grid;
    case 'normal'
        Pfit = normal_grid;
    otherwise
        Pfit.names      = {'f','beta','r'}; % don't change this
        Pfit.p{1}       = 0.05:0.01:0.25; % parameter range for f (IR potential drop fraction)
        Pfit.p{2}       = 0.25:0.01:1; % parameter range for beta (back-attraction probability)
        Pfit.p{3}       = 0.7:0.1:0.7; % parameter range for r (electron recapture probability)
end
% Discharge properties
F_flux_meas     = 0.32; % measured ionized flux fraction, can also be specified directly in the disch structure
IP.disch_type   = 'ArCu'; % the type of discharge {ArTi, ArW, ArC, ArCu}
IP.pressure     = 0.5; % process pressure, can also be specified directly in the disch structure
IP.pulseLength  = 40.1e-6; % cutoff for back-attraction (should correspond to the end of the voltage pulse)
IP.solverTime   = (0:1:160)*1e-6; % points in time for which the simulation produces results
IP.consistent_current = cc_fraction;
% IR dimensions
r1              = 6e-3; % inner radius of IR
r2              = 20e-3; % outer radius of IR
z1              = 2e-3; % distance of target facing border of IR from target
z2              = 28e-3; % distance of substrate facing border of IR from target
% Tolerances for the Ionized Flux Fraction
F_flux_L_tol    = 0.05; % lower tolerance (allowed deviation towards 0)
F_flux_U_tol    = 0.05; % upper tolerance (allowed deviation towards 1)

[summary, metadata, results, inputs, outputs, best] = setupAndRun( ...
    path_results, path_discharge, Pfit, r1, r2, z1, z2, ...
    disch_mat, F_flux_meas, IP, F_flux_L_tol, F_flux_U_tol);
plotSummary(summary, metadata, results, inputs, outputs, ...
    plot_summaries, close_plots, pause_before, path_results, path_discharge);
cleanUp(path_results, path_discharge, clear_folders);

end
end

%% ArMo
if contains('ArMo', disch_types)
% MRu: Note, Fflux was not measured. The 30% used below is a placeholder.
% TODO : adapt once IFF is available and/or new results are available
% NOTE : almost half of the computation time is spent on saving the run
% input due to the current waveform containing 350'000 data points!
% -> FIXME : subsample waveforms

% Discharge .mat file
path_discharge  = 'ArHeMo_Erwan'; % subfolder of discharge where the discharge .mat file is located
disch_mat       = 'disch_tension600V.mat'; % the name of the discharge .mat file (containing cv-waveforms)
% NOTE: this waveform has way too many points and should be subsampled
% Results folder
path_results    = fullfile(folder, subfolder, 'ArMo'); % path where the simulation output will be written to
% Parameter grid
switch grid
    case 'fast'
        Pfit = fast_grid;
    case 'normal'
        Pfit = normal_grid;
    otherwise
        Pfit.names      = {'f','beta','r'}; % don't change this
        Pfit.p{1}       = 0.0:0.025:0.25; % parameter range for f (IR potential drop fraction)
        Pfit.p{2}       = 0.0:0.05:1; % parameter range for beta (back-attraction probability)
        Pfit.p{3}       = 0.7:0.1:0.7; % parameter range for r (electron recapture probability)
end
% Discharge properties
F_flux_meas     = 0.30; % measured ionized flux fraction, can also be specified directly in the disch structure
IP.disch_type   = 'ArMo'; % the type of discharge {ArTi, ArW, ArC, ArCu}
IP.pressure     = 1; % process pressure, can also be specified directly in the disch structure
IP.pulseLength  = 100.1e-6; % cutoff for back-attraction (should correspond to the end of the voltage pulse)
IP.solverTime   = (0:1:160)*1e-6; % points in time for which the simulation produces results
IP.consistent_current = consistent_current;
% IR dimensions
r1              = 6e-3; % inner radius of IR
r2              = 19e-3; % outer radius of IR
z1              = 2e-3; % distance of target facing border of IR from target
z2              = 20e-3; % distance of substrate facing border of IR from target
% Tolerances for the Ionized Flux Fraction
F_flux_L_tol    = 0.05; % lower tolerance (allowed deviation towards 0)
F_flux_U_tol    = 0.05; % upper tolerance (allowed deviation towards 1)

[summary, metadata, results, inputs, outputs, best] = setupAndRun( ...
    path_results, path_discharge, Pfit, r1, r2, z1, z2, ...
    disch_mat, F_flux_meas, IP, F_flux_L_tol, F_flux_U_tol);
plotSummary(summary, metadata, results, inputs, outputs, ...
    plot_summaries, close_plots, pause_before, path_results, path_discharge);
cleanUp(path_results, path_discharge, clear_folders);

end

%% HeMo
if contains('HeMo', disch_types)

% Discharge .mat file
path_discharge  = 'ArHeMo_Erwan/HeMo_700'; % subfolder of discharge where the discharge .mat file is located
disch_mat       = 'disch.mat'; % the name of the discharge .mat file (containing cv-waveforms)
% Results folder
path_results    = fullfile(folder, subfolder, 'HeMo'); % path where the simulation output will be written to
% Parameter grid
switch grid
    case 'fast'
        Pfit = fast_grid;
    case 'normal'
        Pfit = normal_grid;
    otherwise
        Pfit.names      = {'f','beta','r'}; % don't change this
        Pfit.p{1}       = 0.0:0.025:0.25; % parameter range for f (IR potential drop fraction)
        Pfit.p{2}       = 0.0:0.05:1; % parameter range for beta (back-attraction probability)
        Pfit.p{3}       = 0.7:0.1:0.7; % parameter range for r (electron recapture probability)
end
% Discharge properties
F_flux_meas     = 0.9; % measured ionized flux fraction, can also be specified directly in the disch structure
IP.disch_type   = 'HeMo'; % the type of discharge {ArTi, ArW, ArC, ArCu}
IP.pressure     = 5.0; % process pressure, can also be specified directly in the disch structure
IP.pulseLength  = 90.1e-6; % cutoff for back-attraction (should correspond to the end of the voltage pulse)
IP.solverTime   = (20:1:140)*1e-6; % points in time for which the simulation produces results
IP.consistent_current = consistent_current;
% IR dimensions
r1              = 6e-3; % inner radius of IR
r2              = 25e-3; % outer radius of IR
z1              = 2e-3; % distance of target facing border of IR from target
z2              = 20e-3; % distance of substrate facing border of IR from target
% Tolerances for the Ionized Flux Fraction
F_flux_L_tol = 0.01; % lower tolerance (allowed deviation towards 0)
F_flux_U_tol = 0.01; % upper tolerance (allowed deviation towards 1)

[summary, metadata, results, inputs, outputs, best] = setupAndRun( ...
    path_results, path_discharge, Pfit, r1, r2, z1, z2, ...
    disch_mat, F_flux_meas, IP, F_flux_L_tol, F_flux_U_tol);
plotSummary(summary, metadata, results, inputs, outputs, ...
    plot_summaries, close_plots, pause_before, path_results, path_discharge);
cleanUp(path_results, path_discharge, clear_folders);

end

%% ArC
if contains('ArC', disch_types)
% TODO : verify and compare input with publication (Eliasson)

% Discharge .mat file
path_discharge  = 'LiU_ArC'; % subfolder of discharge where the discharge .mat file is located
disch_mat       = 'eliasson_ArC_60A.mat'; % the name of the discharge .mat file (containing cv-waveforms)
% Results folder
path_results    = fullfile(folder, subfolder, 'ArC'); % path where the simulation output will be written to
% Parameter grid
switch grid
    case 'fast'
        Pfit = fast_grid;
    case 'normal'
        Pfit = normal_grid;
    otherwise
        Pfit.names      = {'f','beta','r'}; % don't change this
        Pfit.p{1}       = 0.0:0.025:0.25; % parameter range for f (IR potential drop fraction)
        Pfit.p{2}       = 0.0:0.05:1; % parameter range for beta (back-attraction probability)
        Pfit.p{3}       = 0.7:0.1:0.7; % parameter range for r (electron recapture probability)
end
% Discharge properties
F_flux_meas     = 0.05; % measured ionized flux fraction, can also be specified directly in the disch structure % NOTE : unknown
IP.disch_type   = 'ArC'; % the type of discharge {ArTi, ArW, ArC, ArCu}
IP.pressure     = 1.0; % process pressure, can also be specified directly in the disch structure % NOTE : taken from Henrik's publication
IP.pulseLength  = 53e-6; % cutoff for back-attraction (should correspond to the end of the voltage pulse)
IP.solverTime   = (0:1:400)*1e-6; % points in time for which the simulation produces results
IP.consistent_current = consistent_current;
% IR dimensions
r1              = 6e-3; % inner radius of IR % NOTE : taken from Henrik's publication
r2              = 19e-3; % outer radius of IR % NOTE : taken from Henrik's publication
z1              = 2e-3; % distance of target facing border of IR from target % NOTE : taken from Henrik's publication
z2              = 13e-3; % distance of substrate facing border of IR from target % NOTE : taken from Henrik's publication
% Tolerances for the Ionized Flux Fraction
F_flux_L_tol    = Inf; % lower tolerance (allowed deviation towards 0) % NOTE : Inf beacuse IFF unknown
F_flux_U_tol    = Inf; % upper tolerance (allowed deviation towards 1) % NOTE : Inf beacuse IFF unknown

[summary, metadata, results, inputs, outputs, best] = setupAndRun( ...
    path_results, path_discharge, Pfit, r1, r2, z1, z2, ...
    disch_mat, F_flux_meas, IP, F_flux_L_tol, F_flux_U_tol);
plotSummary(summary, metadata, results, inputs, outputs, ...
    plot_summaries, close_plots, pause_before, path_results, path_discharge);
cleanUp(path_results, path_discharge, clear_folders);

end

%% ArTi
if contains('ArTi', disch_types)
% TODO : verify and compare input with publication

warning("IR dimensions not known. These are just guesses. But it's published so it would be possible to look it up.");
% Discharge .mat file
path_discharge  = 'disch_Prague_ArTi'; % subfolder of discharge where the discharge .mat file is located
disch_mat       = 'disch_Ti_400us_05Pa_38A.mat'; % the name of the discharge .mat file (containing cv-waveforms)
% Results folder
path_results    = fullfile(folder, subfolder, 'ArTi'); % path where the simulation output will be written to
% Parameter grid
switch grid
    case 'fast'
        Pfit = fast_grid;
    case 'normal'
        Pfit = normal_grid;
    otherwise
        Pfit.names      = {'f','beta','r'}; % don't change this
        Pfit.p{1}       = 0.0:0.025:0.25; % parameter range for f (IR potential drop fraction)
        Pfit.p{2}       = 0.0:0.05:1; % parameter range for beta (back-attraction probability)
        Pfit.p{3}       = 0.7:0.1:0.7; % parameter range for r (electron recapture probability)
end
% Discharge properties
F_flux_meas     = 0.15; % measured ionized flux fraction, can also be specified directly in the disch structure
IP.disch_type   = 'ArTi'; % the type of discharge {ArTi, ArW, ArC, ArCu}
IP.pressure     = 0.5; % process pressure, can also be specified directly in the disch structure
IP.pulseLength  = 400.1e-6; % cutoff for back-attraction (should correspond to the end of the voltage pulse)
IP.solverTime   = (0:1:520)*1e-6; % points in time for which the simulation produces results
IP.consistent_current = consistent_current;
% IR dimensions
r1              = 6e-3; % inner radius of IR
r2              = 19e-3; % outer radius of IR
z1              = 2e-3; % distance of target facing border of IR from target
z2              = 20e-3; % distance of substrate facing border of IR from target
% Tolerances for the Ionized Flux Fraction
F_flux_L_tol = Inf; % lower tolerance (allowed deviation towards 0)
F_flux_U_tol = Inf; % upper tolerance (allowed deviation towards 1)

[summary, metadata, results, inputs, outputs, best] = setupAndRun( ...
    path_results, path_discharge, Pfit, r1, r2, z1, z2, ...
    disch_mat, F_flux_meas, IP, F_flux_L_tol, F_flux_U_tol);
plotSummary(summary, metadata, results, inputs, outputs, ...
    plot_summaries, close_plots, pause_before, path_results, path_discharge);
cleanUp(path_results, path_discharge, clear_folders);

end

%% ArW
if contains('ArW', disch_types)
% TODO : add
end

%% Function definitions

function [summary, metadata, results, inputs, outputs, best] = setupAndRun( ...
    path_results_folder, path_discharge, Pfit, r1, r2, z1, z2, ...
    disch_mat, F_flux_meas, IP, F_flux_L_tol, F_flux_U_tol)
    % This is just here to make the code a bit more readable
    util.fig.setDefaultStyle();
    path_to_results = fullfile(path_results_folder, path_discharge);
    if exist(path_to_results, 'dir')
        warning("The specified results folder already exists. New results will be appended, but this might break the fitting procedure.");
        pause(5);
    end
    Pfit.dimension = cellfun(@(x) length(x), Pfit.p);
    cd parameters
    create_Para_new(r1, r2, z1, z2);
    cd ..
    eval_only = false;
    panel_Pfit_fct(path_discharge, disch_mat,...
                   path_to_results, F_flux_meas, Pfit,...
                   eval_only, IP, F_flux_L_tol, F_flux_U_tol);
    % collect the results from the entire scan in a convenient structure
    [~, name, ext] = fileparts(path_to_results);
    [summary, metadata, results, inputs, outputs, best] = ...
        rslt.scan.collect( ...
        path_to_results, ...
        "Id", strcat(name, ext), ...
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

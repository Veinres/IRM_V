function [stats, output_str] = panel_mode_single_run_Pfit_modified_fct(path_to_disch_mat,disch_mat,path_to_results_folder, f, beta, r, plotOn, IP, sd, z2, Spe, Rea, Precal, disch, Para, nrun)

% how to deal with errors occuring during integration
rethrow_error = true; % false -> log and continue % TODO : this should go into an options structure

if ~exist('IP','var') || ~isstruct(IP)
    IP = struct();
end

% how do you wish to run the code?
% MRu: this is currently not in use
mode.reactive = 0;

if ~exist(path_to_results_folder,'dir')
    mkdir(path_to_results_folder);
end

%% Creating folder for saving
% dr is the structure for directory names.
% create_output_folder('name you want','directory to save results')
if exist('nrun', 'var')
    path_to_results_folder = create_output_folder('run_Pfit',path_to_results_folder, nrun);
else
    path_to_results_folder = create_output_folder('run_Pfit',path_to_results_folder);
end

dr.save_plots   = fullfile(path_to_results_folder,'plot');
dr.save_txt     = fullfile(path_to_results_folder,'txt');

%% Load variables
% It's done in a function form by create_Input
if exist('Spe','var') && exist('Rea','var') && exist('Precal','var') && exist('disch','var') && exist('Para','var')
    [input] = create_Input_fct(path_to_results_folder, mode, path_to_disch_mat, disch_mat, f, beta, r, IP, false, ...
        Spe, Rea, Precal, disch, Para);
else
    [input] = create_Input_fct(path_to_results_folder, mode, path_to_disch_mat, disch_mat, f, beta, r, IP, false);
end

%% Parameter modification
addargs = {}; % Hacky fix % FIXME
if exist('sd','var') && ~isempty(sd)
    addargs{1} = sd;
end
if exist('z2','var') && ~isempty(z2)
    addargs{2} = z2;
end
[input] = adjustInput(input, f, beta, r, addargs{:});
save(fullfile(path_to_results_folder,'Input'), '-struct', 'input');

%% Solver

% limit execution time (abort after 10000 calls to ODEfile or 10s)
max_n_calls = 100000;
max_exec_time = 10; % seconds
input.solver.opts = odeset(input.solver.opts, ...
    'Events', @(y,t) util.ode.abortEvent(y, t, max_n_calls, max_exec_time));
% select ode solver
% NOTE : starting with Matlab R2023b there's an ODE object that already has
% this functionality -> switch at some point
if isfield(input.solver, 'name')
    [ode_solver, selected] = util.ode.selectSolver(input.solver.name);
    input.solver.choice = input.solver.name;
    input.solver.name = selected;
else
    ode_solver = @ode15s;
    input.solver.name = 'ode15s';
    input.solver.choice = 'default';
end
% reset function evaluation counter and exit status
util.ode.callCount('Action','clear');
util.ode.exitStatus('Reset', true, 'Warnings', 'off');
% solve the ode

% for debug:
[t, n] = ode_solver(@(t,n) ODEfile(t, n, input),...
                    input.solver.time, input.solver.IC,...
                    input.solver.opts);

% for actual run
% try
%     [t, n] = ode_solver(@(t,n) ODEfile(t, n, input),...
%                     input.solver.time, input.solver.IC,...
%                     input.solver.opts);
% catch ME
%     warning('irm:integrationError', ...
%         "An error occured during integration.");
%     if rethrow_error
%         rethrow(ME);
%     else
%         disp(ME);
%         pause(5);
%     end
% end


% fetch function evaluation counter value and print stats
[n_calls, exec_time] = util.ode.callCount('Action','get');
% fetch last warning to get exit status
exit_status = util.ode.exitStatus(t(end), input.solver.time(end), 'Warnings', 'on');
% recompute fluxes etc needed for further analysis at predifend points in time
output = rslt.run.output(t, n, input, "SaveLocation", path_to_results_folder);
% compute some properties we would like to know for each run (e.g. fom and F_flux)
results = rslt.run.analyse(input, output, "SaveLocation", path_to_results_folder, "Compatibility", true);
% pack run information
stats = struct(...
    'n_calls', n_calls, 'exec_time', exec_time, ...
    'end_time', 1e+6*t(end), 'target_time', 1e+6*input.solver.time(end), ...
    'exit_status', exit_status, 'fom', results.fom);

% TODO : @joel integrate HeMo analysis into rslt.run.analyse
% if isfield(input.Spe.s,'Mo') && isfield(input.Spe.s, 'He')
%     [Out] = extract_output(path_to_results_folder, t, n, input);
%     warning("Using default analyses (ArTi/ArW). Not guaranteed to work.");
%     analysis_fct(path_to_results_folder,f, beta, r, hall, input.Para.pulseLength);
% end

%% Plotting
addpath(genpath('plotting'))
do.plots = plotOn;
do.save_plots = false;

if (do.plots || do.save_plots)
    fig = plt.run.densities(output, input, "Mask", input.Range.ion); fig.Name = 'ions';
    fig = plt.run.densities(output, input, "Mask", input.Spe.Q == 0); fig.Name = 'neutrals';
    fig = plt.run.electrons(output, input); fig.Name = 'electrons';
    fig = plt.disch('Struct', input.disch, 'I_fit', [1e+6*output.t, sum(output.I,2) + sum(output.I_se,2)]); fig.Name = 'disch';
    fig = plt.run.currents(output, input, 'Total', true, 'Exp', true, 'Ion', false, 'SE', false); fig.Name = 'fit';
    fig = plt.run.currents(output, input, 'Total', true, 'Exp', true, 'Ion', true, 'SE', true); fig.Name = 'currents';
    fig = plt.run.rate.diffusion(output, input); fig.Name = 'diffusion';
    fig = plt.run.powerBalance(output, input, "MarkTotalZeros", true); fig.Name = 'power';
    util.fof(path_to_results_folder);
    util.save_open_figs(path_to_results_folder,'',{'png','eps'},true);
    util.cofb({''});
end

end

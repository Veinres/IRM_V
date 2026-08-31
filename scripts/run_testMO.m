% NOTE: @joel check newly added
discharges = cell(0);

% for results subfolder
user_name = 'zakaria_test';

%% Case Selection
% select cases here:

discharges{end+1} = 'ArHeMo Erwan';
%discharges{end+1} = 'ArCu/original/ArCu_HiPSTER_20A';
% discharges{end+1} = 'ArCu/original/ArCu_Sinex2_04Pa';
% discharges{end+1} = 'ArCu/original/ArCu_Sinex2_27Pa';
% discharges{end+1} = 'ArCu/original/ArCu_Sinex1';

% discharges{end+1} = 'ArCu/irm/ArCu_HiPSTER_40us_0.5Pa_130A';
% discharges{end+1} = 'ArCu/irm/ArCu_HiPSTER_40us_0.5Pa_165A';
%%discharges{end+1} = 'ArCu/irm/ArCu_HiPSTER_40us_0.5Pa_180A';
% discharges{end+1} = 'ArCu/irm/ArCu_HiPSTER_40us_0.5Pa_200A';
% discharges{end+1} = 'ArCu/irm/ArCu_HiPSTER_40us_0.5Pa_235A';
% discharges{end+1} = 'ArCu/irm/ArCu_HiPSTER_40us_0.5Pa_360A';
% 
% discharges{end+1} = 'ArCu/irm/ArCu_HiPSTER_80us_0.4Pa_130A';
%%discharges{end+1} = 'ArCu/irm/ArCu_HiPSTER_80us_0.4Pa_165A';
% discharges{end+1} = 'ArCu/irm/ArCu_HiPSTER_80us_0.4Pa_200A';
% discharges{end+1} = 'ArCu/irm/ArCu_HiPSTER_80us_0.4Pa_235A'; % FIXME
% discharges{end+1} = 'ArCu/irm/ArCu_HiPSTER_80us_0.4Pa_360A';
% 
% discharges{end+1} = 'ArCu/irm/ArCu_HiPSTER_80us_2.7Pa_130A';
% discharges{end+1} = 'ArCu/irm/ArCu_HiPSTER_80us_2.7Pa_165A';
% discharges{end+1} = 'ArCu/irm/ArCu_HiPSTER_80us_2.7Pa_200A';
%%discharges{end+1} = 'ArCu/irm/ArCu_HiPSTER_80us_2.7Pa_235A';
% discharges{end+1} = 'ArCu/irm/ArCu_HiPSTER_80us_2.7Pa_360A';

% set true to only rerun plot generation (no simulations)
eval_only = false;
close_figs = false;

%% Case Paramaters

sim_times = zeros(length(discharges),1); % FIXME
sim_numbers = zeros(length(discharges),1); % FIXME

for i_d=1:length(discharges)
    
    case_name = discharges{i_d};

    switch case_name

        case 'ArHeMo Erwan'
            path_discharge  = 'ArHeMo_Erwan';
            disch_mat       = 'disch_tension800V.mat';
            path_results    = fullfile('results',user_name);
            F_flux_meas     = 0.1;
            F_flux_L_tol    = 0.1; % FIXME
            F_flux_U_tol    = 0.1; % FIXME
%             F_flux_L_tol    = Inf; % FIXME
%             F_flux_U_tol    = Inf; % FIXME
            Pfit.names      = {'f','beta','r'};
            Pfit.p{1}       = 0.05:0.005:0.2;
            Pfit.p{2}       = 0.7:0.005:1;
            Pfit.p{3}       = 0.7:0.1:0.7;
            IP.disch_type   = 'ArMo';
            IP.pressure     = 0.5;
            IP.pulseLength  = 100e-6; % Cutoff for beta
            IP.solverTime   = (0:1:160)*1e-6;

    end
    Pfit.dimension = cellfun(@(x) length(x), Pfit.p);
    
    cd parameters
    create_Para(case_name); % FIXME : moving around ain't good
    cd ..

    %% Set-up
    util.fig.setDefaultStyle();

    full_results_path = fullfile(path_results, path_discharge);
    if ~exist(full_results_path,'dir')

        mkdir(full_results_path);
        if eval_only
            error("No previous simulations available");
        end
    else
        if ~eval_only
            full_results_path = strcat(full_results_path,...
                datestr(now,'yyyy-MM-dd_hhmm'));
            mkdir(full_results_path);
        end
    end

%     diary_name = strcat('diary', '.txt');
%     diary (fullfile(full_results_path, diary_name))

    %% Simulaiton
    start_time = tic(); % FIXME
    panel_Pfit_fct(path_discharge,...
                   disch_mat,...
                   full_results_path,...
                   F_flux_meas,...
                   Pfit,...
                   eval_only,...
                   IP,...
                   F_flux_L_tol,...
                   F_flux_U_tol);
               
    sim_times(end+1) = toc(start_time); % FIXME
    sim_numbers(end+1) = prod(Pfit.dimension); % FIXME

    %% Clean-up    
%     diary off % FIXME
    
    %fof;

    if close_figs
        close all;
    end

end

%% Summary
disp(table(discharges.',sim_numbers.',sim_times.',...
    'VariableNames',{'Name','# of sim.','sim. time [s]'}));

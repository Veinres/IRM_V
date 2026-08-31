
discharges = cell(0);

% for results subfolder
user_name = 'test_He';

%% Case Selection
% select cases here:

discharges{end+1} = 'ArHeMo_Erwan';
% discharges{end+1} = 'ArCu/original/ArCu_HiPSTER';
% discharges{end+1} = 'ArCu/original/ArCu_HiPSTER_20A';
% discharges{end+1} = 'ArCu/original/ArCu_Sinex2_04Pa';
% discharges{end+1} = 'ArCu/original/ArCu_Sinex2_27Pa';
% discharges{end+1} = 'ArCu/original/ArCu_Sinex1';

% discharges{end+1} = 'ArCu/irm/ArCu_HiPSTER_40us_0.5Pa_130A';
% discharges{end+1} = 'ArCu/irm/ArCu_HiPSTER_40us_0.5Pa_165A';
% discharges{end+1} = 'ArCu/irm/ArCu_HiPSTER_40us_0.5Pa_180A';
% discharges{end+1} = 'ArCu/irm/ArCu_HiPSTER_40us_0.5Pa_200A';
% discharges{end+1} = 'ArCu/irm/ArCu_HiPSTER_40us_0.5Pa_235A';
% discharges{end+1} = 'ArCu/irm/ArCu_HiPSTER_40us_0.5Pa_360A';
% 
% discharges{end+1} = 'ArCu/irm/ArCu_HiPSTER_80us_0.4Pa_130A';
% discharges{end+1} = 'ArCu/irm/ArCu_HiPSTER_80us_0.4Pa_165A';
% discharges{end+1} = 'ArCu/irm/ArCu_HiPSTER_80us_0.4Pa_200A';
% discharges{end+1} = 'ArCu/irm/ArCu_HiPSTER_80us_0.4Pa_235A'; % FIXME
% discharges{end+1} = 'ArCu/irm/ArCu_HiPSTER_80us_0.4Pa_360A';
% 
% discharges{end+1} = 'ArCu/irm/ArCu_HiPSTER_80us_2.7Pa_130A';
% discharges{end+1} = 'ArCu/irm/ArCu_HiPSTER_80us_2.7Pa_165A';
% discharges{end+1} = 'ArCu/irm/ArCu_HiPSTER_80us_2.7Pa_200A';
% discharges{end+1} = 'ArCu/irm/ArCu_HiPSTER_80us_2.7Pa_235A';
% discharges{end+1} = 'ArCu/irm/ArCu_HiPSTER_80us_2.7Pa_360A';

% set true to only rerun plot generation (no simulations)
eval_only = false;
% set true to close figures after plotting
close_figs = false;

%% Case Paramaters

sim_times = zeros(length(discharges),1);
sim_numbers = zeros(length(discharges),1);

for i_d=1:length(discharges)
    
    case_name = discharges{i_d};

    switch case_name

        case 'ArHeMo_Erwan'
            path_discharge  = 'ArHeMo_Erwan';
            disch_mat       = 'disch_HeMo_650.mat';
            path_results    = fullfile('results',user_name);
            F_flux_meas     = 0.6;
            F_flux_L_tol    = 0.1; % FIXME
            F_flux_U_tol    = 0.1; % FIXME
%             F_flux_L_tol    = Inf; % FIXME
%             F_flux_U_tol    = Inf; % FIXME
            Pfit.names      = {'f','beta','r'};
            Pfit.p{1}       = 0.1:0.05:0.4; % parameter range for f (IR potential drop fraction)
            Pfit.p{2}       = 0.6:0.05:1.0; % parameter range for beta (back-attraction probability)
            Pfit.p{3}       = 0.2:0.1:0.5; % parameter range for r (electron recapture probability)
            IP.pressure     = 5.0;
            IP.pulseLength  = 100e-6; % Cutoff for beta
            IP.solverTime   = (0:1:120)*1e-6;

        case 'ArCu HiPSTER'
            path_discharge  = 'ArCu/original/ArCu_HiPSTER';
            disch_mat       = 'disch_0.5Pa.mat';
            path_results    = fullfile('results',user_name);
            F_flux_meas     = 0.6;
            F_flux_L_tol    = 0.1; % FIXME
            F_flux_U_tol    = 0.1; % FIXME
%             F_flux_L_tol    = Inf; % FIXME
%             F_flux_U_tol    = Inf; % FIXME
            Pfit.names      = {'f','beta','r'};
            Pfit.p{1}       = 0.05:0.01:0.2;
            Pfit.p{2}       = 0.1:0.05:1;
            Pfit.p{3}       = 0.7:0.05:0.7;
            IP.pressure     = 0.5;
            IP.pulseLength  = 35e-6; % Cutoff for beta
            IP.solverTime   = (0:1:60)*1e-6;

        case 'ArCu HiPSTER 20A'
            path_discharge  = 'ArCu/original/ArCu_HiPSTER_20A';
            disch_mat       = 'disch.mat';
            path_results    = fullfile('results',user_name);
            F_flux_meas     = 0.27;
            F_flux_L_tol    = 0.05; % FIXME
            F_flux_U_tol    = 0.05; % FIXME
            % F_flux_L_tol    = Inf; % FIXME
            % F_flux_U_tol    = Inf; % FIXME
            Pfit.names      = {'f','beta','r'};
% OLD
%             Pfit.p{1}       = 0.05:0.01:0.2;
%             Pfit.p{2}       = 0.1:0.05:1;
%             Pfit.p{3}       = 0.7:0.05:0.7;
% QUICK
%             Pfit.p{1}       = 0.05:0.025:0.2;
%             Pfit.p{2}       = 0.5:0.1:1;
%             Pfit.p{3}       = 0.5:0.1:0.9;
% DETAILED
            Pfit.p{1}       = 0.05:0.005:0.2;
            Pfit.p{2}       = 0.5:0.025:1;
            Pfit.p{3}       = 0.5:0.05:0.8;
            IP.pressure     = 0.5;
            IP.pulseLength  = 40.1e-6; % Cutoff for beta
            IP.solverTime   = (0:1:120)*1e-6;

        case 'ArCu Sinex2 27Pa'
            path_discharge  = 'ArCu/original/ArCu_Sinex2_27Pa';
            disch_mat       = 'disch_2.7Pa.mat';
            path_results    = fullfile('results',user_name);
            F_flux_meas     = 0.375;
            F_flux_L_tol    = 0.1; % FIXME
            F_flux_U_tol    = 0.1; % FIXME
%             F_flux_L_tol    = Inf; % FIXME
%             F_flux_U_tol    = Inf; % FIXME
            Pfit.names      = {'f','beta','r'};
            Pfit.p{1}       = 0.05:0.01:0.25;
            Pfit.p{2}       = 0.1:0.05:1;
            Pfit.p{3}       = 0.7:0.05:0.7;
            IP.pressure     = 2.7;
            IP.pulseLength  = 100e-6;
            IP.solverTime   = (0:1:120)*1e-6;

        case 'ArCu Sinex2 04Pa'
            path_discharge  = 'ArCu/original/ArCu_Sinex2_04Pa';
            disch_mat       = 'disch_0.4Pa.mat';
            path_results    = fullfile('results',user_name);
            F_flux_meas     = 0.39;
            F_flux_L_tol    = 0.1; % FIXME
            F_flux_U_tol    = 0.1; % FIXME
%             F_flux_L_tol    = Inf; % FIXME
%             F_flux_U_tol    = Inf; % FIXME
            Pfit.names      = {'f','beta','r'};
            Pfit.p{1}       = 0.05:0.01:0.15;
            Pfit.p{2}       = 0.25:0.05:1;
            Pfit.p{3}       = 0.7:0.05:0.7;
            IP.pressure     = 0.4;
            IP.pulseLength  = 85e-6;
            IP.solverTime   = (0:1:85)*1e-6;

        case 'ArCu Sinex1'
            path_discharge  = 'ArCu/original/ArCu_Sinex1';
            disch_mat       = 'disch_0.065Pa.mat';
            path_results    = fullfile('results',user_name);
            F_flux_meas     = 0.3;
            F_flux_L_tol    = Inf; % FIXME
            F_flux_U_tol    = Inf; % FIXME
%             F_flux_L_tol    = Inf; % FIXME
%             F_flux_U_tol    = Inf; % FIXME
            Pfit.names      = {'f','beta','r'};
            Pfit.p{1}       = 0.05:0.01:0.2;   % FIXME
            Pfit.p{2}       = 0.5:0.1:1;       % FIXME 
            Pfit.p{1}       = 0.05:0.01:0.2;   % FIXME
            Pfit.p{2}       = 0.5:0.05:1;       % FIXME
            Pfit.p{3}       = 0.7:0.05:0.7;    % FIXME
            IP.pressure     = 0.065;
            IP.pulseLength  = 150e-6;
            IP.solverTime   = (0:1:200)*1e-6;

        otherwise
            avail_disch = { 'ArCu/irm/ArCu_HiPSTER_40us_0.5Pa_130A',...
                            'ArCu/irm/ArCu_HiPSTER_40us_0.5Pa_165A',...
                            'ArCu/irm/ArCu_HiPSTER_40us_0.5Pa_180A',...
                            'ArCu/irm/ArCu_HiPSTER_40us_0.5Pa_200A',...
                            'ArCu/irm/ArCu_HiPSTER_40us_0.5Pa_235A',...
                            'ArCu/irm/ArCu_HiPSTER_40us_0.5Pa_360A',...
                            'ArCu/irm/ArCu_HiPSTER_80us_2.7Pa_130A',...
                            'ArCu/irm/ArCu_HiPSTER_80us_2.7Pa_165A',...
                            'ArCu/irm/ArCu_HiPSTER_80us_2.7Pa_200A',...
                            'ArCu/irm/ArCu_HiPSTER_80us_2.7Pa_235A',...
                            'ArCu/irm/ArCu_HiPSTER_80us_2.7Pa_360A',...
                            'ArCu/irm/ArCu_HiPSTER_80us_0.4Pa_130A',...
                            'ArCu/irm/ArCu_HiPSTER_80us_0.4Pa_165A',...
                            'ArCu/irm/ArCu_HiPSTER_80us_0.4Pa_200A',...
                            'ArCu/irm/ArCu_HiPSTER_80us_0.4Pa_235A',...
                            'ArCu/irm/ArCu_HiPSTER_80us_0.4Pa_360A'...
                            }; % FIXME
            if any(strcmp(case_name, avail_disch))
                path_discharge  = case_name;
                disch_mat       = 'disch.mat';
                path_results    = fullfile('results',user_name);
                F_flux_meas     = 0.3;
                F_flux_L_tol    = 0.1; % FIXME
                F_flux_U_tol    = 0.1; % FIXME
%                 F_flux_L_tol    = Inf; % FIXME
%                 F_flux_U_tol    = Inf; % FIXME
                Pfit.names      = {'f','beta','r'};
                Pfit.p{1}       = 0.05:0.01:0.2;   % FIXME
                Pfit.p{2}       = 0.1:0.1:1;       % FIXME
                Pfit.p{3}       = 0.7:0.05:0.7;    % FIXME
                disch           = load(fullfile('discharge',case_name,'disch.mat'),'disch'); % FIXME
                if isfield(disch.disch,'F_flux')
                    F_flux_meas = disch.disch.F_flux;
                else
                end
                if contains(case_name,'0.4Pa')
                    IP.pressure = 0.4;
                elseif contains(case_name,'0.5Pa')
                    IP.pressure = 0.5;
                elseif contains(case_name,'2.7Pa')
                    IP.pressure = 2.7;
                else
                    warning("Specified case does not exist.");
                    return
                end
                if contains(case_name,'40us')
                    IP.pulseLength  = 43e-6;
                    IP.solverTime   = (0:1:200)*1e-6;
                elseif contains(case_name,'80us')
                    IP.pulseLength  = 83e-6;
                    IP.solverTime   = (0:1:160)*1e-6;
                else
                    warning("Specified case does not exist.");
                    return
                end
            else
                warning("Specified case does not exist.");
                return
            end
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

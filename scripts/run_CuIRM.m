
eval_only = false;
close_figs = true;
col_Cu_results = false;
level = 'restricted2'; % 'coarse'; 'coarse2'; 'specific'; 'specific2'; 'detailed2';
subfolder_base = 'joel-new_dims';

%%
util.fig.setDefaultStyle();

switch level
    case 'coarse'
        sd = [1e+16,1e+17,1e+18];
    case 'coarse2'
        sd = [5e+16,1e+17,5e+17];
    case 'specific'
        sd = [1e+18];
    case 'restricted'
        sd = [1e+18];
    case 'restricted2'
        sd = [1e+18];
    case 'specific2'
        sd = [1e+17];
    case 'detailed2'
        sd = [1e+17];
    case 'coarse3'
        sd = [1e+15,1e+16,1e+17,1e+18];
    case 'specific_sinex1'
        sd = [1e+17];
    otherwise
        sd = [1e+17];
end
F_flux_L_tol    = 0.025;
F_flux_U_tol    = 0.025;

for i_sd=1:length(sd)

subfolder = fullfile(strcat(subfolder_base,'-',level),sprintf('sd_%e',sd(i_sd)));

change_ArCu_seed_density(sd(i_sd));

discharges = cell(0);
%% Paper Cases:

% Historic discharges

% discharges{end+1} = 'ArCu/original/ArCu_HiPSTER_20A';
% discharges{end+1} = 'ArCu/original/ArCu_Sinex2_04Pa';
% discharges{end+1} = 'ArCu/original/ArCu_Sinex2_27Pa';

% IFF measurements discharge

% discharges{end+1} = 'ArCu/original/ArCu_HiPSTER_40us_0.5Pa_180A';
% discharges{end+1} = 'ArCu/original/ArCu_HiPSTER_80us_0.4Pa_165A';
% discharges{end+1} = 'ArCu/original/ArCu_HiPSTER_80us_2.7Pa_235A';

%% All Original Cases:

% discharges{end+1} = 'ArCu/original/ArCu_HiPSTER';
% discharges{end+1} = 'ArCu/original/ArCu_HiPSTER 20A';
% discharges{end+1} = 'ArCu/original/ArCu_Sinex2 04Pa';
% discharges{end+1} = 'ArCu/original/ArCu_Sinex2 27Pa';
% discharges{end+1} = 'ArCu/original/ArCu_Sinex1';

% discharges{end+1} = 'ArCu/irm/ArCu_HiPSTER_40us_0.5Pa_130A';
% discharges{end+1} = 'ArCu/irm/ArCu_HiPSTER_40us_0.5Pa_165A';
% discharges{end+1} = 'ArCu/irm/ArCu_HiPSTER_40us_0.5Pa_180A';
% discharges{end+1} = 'ArCu/irm/ArCu_HiPSTER_40us_0.5Pa_200A';
% discharges{end+1} = 'ArCu/irm/ArCu_HiPSTER_40us_0.5Pa_235A';
% discharges{end+1} = 'ArCu/irm/ArCu_HiPSTER_40us_0.5Pa_360A';

% discharges{end+1} = 'ArCu/irm/ArCu_HiPSTER_80us_0.4Pa_130A';
% discharges{end+1} = 'ArCu/irm/ArCu_HiPSTER_80us_0.4Pa_165A';
% discharges{end+1} = 'ArCu/irm/ArCu_HiPSTER_80us_0.4Pa_200A';
% discharges{end+1} = 'ArCu/irm/ArCu_HiPSTER_80us_0.4Pa_235A';
% discharges{end+1} = 'ArCu/irm/ArCu_HiPSTER_80us_0.4Pa_360A';

% discharges{end+1} = 'ArCu/irm/ArCu_HiPSTER_80us_2.7Pa_130A';
% discharges{end+1} = 'ArCu/irm/ArCu_HiPSTER_80us_2.7Pa_165A';
% discharges{end+1} = 'ArCu/irm/ArCu_HiPSTER_80us_2.7Pa_200A';
% discharges{end+1} = 'ArCu/irm/ArCu_HiPSTER_80us_2.7Pa_235A';
% discharges{end+1} = 'ArCu/irm/ArCu_HiPSTER_80us_2.7Pa_360A';

%% Follow-Up

% discharges{end+1} = 'ArCu/followup/ArCu_075us_0.25Pa_135A_027'; % sd=1e+18 (abs), r=0.5 -> complete
% discharges{end+1} = 'ArCu/followup/ArCu_050us_0.25Pa_090A_006'; % sd=1e+18 (abs), r=0.5 -> complete
% discharges{end+1} = 'ArCu/followup/ArCu_025us_0.50Pa_090A_010'; % sd=1e+18 (abs), r=0.5 -> complete
% discharges{end+1} = 'ArCu/followup/ArCu_075us_1.00Pa_180A_020'; % sd=1e+18 (abs), r=0.5 -> complete
% discharges{end+1} = 'ArCu/followup/ArCu_050us_2.00Pa_180A_030'; % sd=1e+18 (abs), r=0.5 -> complete
% discharges{end+1} = 'ArCu/followup/ArCu_075us_2.00Pa_180A_029'; % sd=1e+18 (abs), r=0.5 -> complete
% 
% discharges{end+1} = 'ArCu_025us_0.25Pa_045A_015'; % sd=1e+18 (abs), r=0.5 -> almost complete
% discharges{end+1} = 'ArCu_050us_0.50Pa_135A_014'; % sd=1e+18 (abs), r=0.5 -> almost complete
% discharges{end+1} = 'ArCu_025us_1.00Pa_135A_024'; % sd=1e+18 (abs), r=0.5 -> almost complete
% discharges{end+1} = 'ArCu_050us_1.00Pa_180A_012'; % sd=1e+18 (abs), r=0.5 -> almost complete
% discharges{end+1} = 'ArCu_025us_2.00Pa_180A_033'; % sd=1e+18 (abs), r=0.5 -> almost complete
discharges{end+1} = 'ArCu_050us_2.00Pa_225A_035'; % sd=1e+18 (abs), r=0.5 -> almost complete

discharges{end+1} = 'ArCu_025us_0.25Pa_090A_007'; % sd=1e+18 (abs), r=0.5 -> slightly incomplete
discharges{end+1} = 'ArCu_050us_0.25Pa_135A_019'; % sd=1e+18 (abs), r=0.5 -> slightly incomplete
discharges{end+1} = 'ArCu_025us_0.50Pa_135A_025'; % sd=1e+18 (abs), r=0.5 -> slightly incomplete
discharges{end+1} = 'ArCu_050us_2.00Pa_248A_048'; % sd=1e+18 (abs), r=0.5 -> slightly incomplete

discharges{end+1} = 'ArCu_025us_0.25Pa_135A_017'; % sd=1e+18 (abs), r=0.5 -> rather incomplete
discharges{end+1} = 'ArCu_025us_1.00Pa_180A_013'; % sd=1e+18 (abs), r=0.5 -> rather incomplete
discharges{end+1} = 'ArCu_025us_1.00Pa_225A_016'; % sd=1e+18 (abs), r=0.5 -> rather incomplete
discharges{end+1} = 'ArCu_025us_1.00Pa_248A_051'; % sd=1e+18 (abs), r=0.5 -> rather incomplete
discharges{end+1} = 'ArCu_025us_2.00Pa_225A_032'; % sd=1e+18 (abs), r=0.5 -> rather incomplete
discharges{end+1} = 'ArCu_025us_2.00Pa_248A_050'; % sd=1e+18 (abs), r=0.5 -> rather incomplete
discharges{end+1} = 'ArCu_025us_2.00Pa_270A_034'; % sd=1e+18 (abs), r=0.5 -> rather incomplete

discharges{end+1} = 'ArCu_100us_0.25Pa_270A_042'; % sd=1e+18 (abs), r=0.5 -> very incomplete
discharges{end+1} = 'ArCu_150us_0.25Pa_270A_043'; % sd=1e+18 (abs), r=0.5 -> very incomplete

discharges{end+1} = 'ArCu_075us_0.50Pa_180A_011'; % sd=1e+18 (abs), r=0.5 -> almost complete / flux fail

discharges{end+1} = 'ArCu_075us_2.00Pa_225A_031'; % sd=1e+18 (abs), r=0.5 -> slightly incomplete / flux fail
discharges{end+1} = 'ArCu_075us_2.00Pa_248A_049'; % sd=1e+18 (abs), r=0.5 -> slightly incomplete / flux fail
discharges{end+1} = 'ArCu_075us_2.00Pa_270A_-28'; % sd=1e+18 (abs), r=0.5 -> slightly incomplete / flux fail

discharges{end+1} = 'ArCu_075us_0.25Pa_180A_004'; % sd=1e+18 (abs), r=0.5 -> rather incomplete / flux fail
discharges{end+1} = 'ArCu_025us_0.50Pa_180A_003'; % sd=1e+18 (abs), r=0.5 -> rather incomplete / flux fail
discharges{end+1} = 'ArCu_050us_1.00Pa_225A_023'; % sd=1e+18 (abs), r=0.5 -> rather incomplete / flux fail
discharges{end+1} = 'ArCu_050us_1.00Pa_248A_046'; % sd=1e+18 (abs), r=0.5 -> rather incomplete / flux fail
discharges{end+1} = 'ArCu_075us_1.00Pa_225A_005'; % sd=1e+18 (abs), r=0.5 -> rather incomplete / flux fail
discharges{end+1} = 'ArCu_075us_1.00Pa_248A_047'; % sd=1e+18 (abs), r=0.5 -> rather incomplete / flux fail

discharges{end+1} = 'ArCu_050us_0.25Pa_180A_001'; % sd=1e+18 (abs), r=0.5 -> very incomplete / flux fail
discharges{end+1} = 'ArCu_075us_0.25Pa_225A_-26'; % sd=1e+18 (abs), r=0.5 -> very incomplete / flux fail
discharges{end+1} = 'ArCu_075us_0.25Pa_225A_026'; % sd=1e+18 (abs), r=0.5 -> very incomplete / flux fail
discharges{end+1} = 'ArCu_075us_0.25Pa_248A_044'; % sd=1e+18 (abs), r=0.5 -> very incomplete / flux fail
discharges{end+1} = 'ArCu_075us_0.25Pa_270A_041'; % sd=1e+18 (abs), r=0.5 -> very incomplete / flux fail
discharges{end+1} = 'ArCu_050us_0.50Pa_180A_008'; % sd=1e+18 (abs), r=0.5 -> very incomplete / flux fail
discharges{end+1} = 'ArCu_050us_0.50Pa_225A_018'; % sd=1e+18 (abs), r=0.5 -> very incomplete / flux fail
discharges{end+1} = 'ArCu_050us_0.50Pa_248A_052'; % sd=1e+18 (abs), r=0.5 -> very incomplete / flux fail
discharges{end+1} = 'ArCu_075us_0.50Pa_225A_022'; % sd=1e+18 (abs), r=0.5 -> very incomplete / flux fail
discharges{end+1} = 'ArCu_075us_0.50Pa_248A_045'; % sd=1e+18 (abs), r=0.5 -> very incomplete / flux fail
discharges{end+1} = 'ArCu_075us_0.50Pa_270A_-09'; % sd=1e+18 (abs), r=0.5 -> very incomplete / flux fail
discharges{end+1} = 'ArCu_075us_0.50Pa_270A_009'; % sd=1e+18 (abs), r=0.5 -> very incomplete / flux fail
discharges{end+1} = 'ArCu_050us_1.00Pa_270A_-02'; % sd=1e+18 (abs), r=0.5 -> very incomplete / flux fail
discharges{end+1} = 'ArCu_050us_1.00Pa_270A_002'; % sd=1e+18 (abs), r=0.5 -> very incomplete / flux fail
discharges{end+1} = 'ArCu_075us_1.00Pa_270A_-21'; % sd=1e+18 (abs), r=0.5 -> very incomplete / flux fail
discharges{end+1} = 'ArCu_075us_1.00Pa_270A_021'; % sd=1e+18 (abs), r=0.5 -> very incomplete / flux fail
discharges{end+1} = 'ArCu_050us_2.00Pa_270A_036'; % sd=1e+18 (abs), r=0.5 -> very incomplete / flux fail
discharges{end+1} = 'ArCu_075us_2.00Pa_270A_028'; % sd=1e+18 (abs), r=0.5 -> very incomplete / flux fail

%% Some other stuff
sim_times = zeros(length(discharges),1);
sim_numbers = zeros(length(discharges),1);

cu_paper_disch = {'ArCu/irm/ArCu_HiPSTER_40us_0.5Pa_130A',...
                'ArCu/irm/ArCu_HiPSTER_40us_0.5Pa_165A',...
                'ArCu/irm/ArCu_HiPSTER_40us_0.5Pa_180A',...
                'ArCu/irm/ArCu_HiPSTER_40us_0.5Pa_200A',...
                'ArCu/irm/ArCu_HiPSTER_40us_0.5Pa_235A',...
                'ArCu/irm/ArCu_HiPSTER_40us_0.5Pa_360A',...
                ...
                'ArCu/irm/ArCu_HiPSTER_80us_2.7Pa_130A',...
                'ArCu/irm/ArCu_HiPSTER_80us_2.7Pa_165A',...
                'ArCu/irm/ArCu_HiPSTER_80us_2.7Pa_200A',...
                'ArCu/irm/ArCu_HiPSTER_80us_2.7Pa_235A',...
                'ArCu/irm/ArCu_HiPSTER_80us_2.7Pa_360A',...
                ...
                'ArCu/irm/ArCu_HiPSTER_80us_0.4Pa_130A',...
                'ArCu/irm/ArCu_HiPSTER_80us_0.4Pa_165A',...
                'ArCu/irm/ArCu_HiPSTER_80us_0.4Pa_200A',...
                'ArCu/irm/ArCu_HiPSTER_80us_0.4Pa_235A',...
                'ArCu/irm/ArCu_HiPSTER_80us_0.4Pa_360A'...
                };

cu_follow_up_disch = {dir(fullfile("discharge","ArCu","follow-up", ...
    "ArCu_*")).name};

other_disch = horzcat(cu_paper_disch, cu_follow_up_disch);

%% Case Paramaters
path_results    = fullfile('results', subfolder);

for i_d=1:length(discharges)
    
    case_name = discharges{i_d};
    
    % default pfit parameters
    IP.disch_type = 'ArCu';
    Pfit.names      = {'f','beta','r'};
    switch level
        case 'coarse'
            % QUICK
            Pfit.p{1}       = 0.05:0.025:0.2;
            Pfit.p{2}       = 0.5:0.1:1;
            Pfit.p{3}       = 0.5:0.1:0.9;
        case 'coarse2'
            % QUICK
            Pfit.p{1}       = 0.05:0.025:0.25;
            Pfit.p{2}       = 0.1:0.1:1;
            Pfit.p{3}       = 0.5:0.1:0.8;
        case 'coarse3'
            % QUICK
            Pfit.p{1}       = 0.00:0.025:0.5;
            Pfit.p{2}       = 0.1:0.1:1;
            Pfit.p{3}       = 0.1:0.1:0.8;
        case 'specific'
            % QUICK
            Pfit.p{1}       = 0.05:0.025:0.25;
            Pfit.p{2}       = 0.1:0.05:1;
            Pfit.p{3}       = 0.5:0.1:0.5;
        case 'restricted'
            % QUICK
            Pfit.p{1}       = 0.05:0.025:0.2;
            Pfit.p{2}       = 0.5:0.05:1;
            Pfit.p{3}       = 0.5:0.1:0.5;
        case 'restricted2'
            % QUICK
            Pfit.p{1}       = 0.05:0.025:0.2;
            Pfit.p{2}       = 0.25:0.025:1;
            Pfit.p{3}       = 0.5:0.1:0.5;
        case 'specific2'
            % DETAILED
            Pfit.p{1}       = 0.05:0.01:0.25;
            Pfit.p{2}       = 0.2:0.025:1;
            Pfit.p{3}       = 0.5:0.1:0.5;
        case 'detailed'
        % DETAILED
            Pfit.p{1}       = 0.05:0.005:0.2;
            Pfit.p{2}       = 0.5:0.025:1;
            Pfit.p{3}       = 0.5:0.05:0.8;
        case 'detailed2'
        % DETAILED
            Pfit.p{1}       = 0.05:0.005:0.2;
            Pfit.p{2}       = 0.2:0.005:1;
            Pfit.p{3}       = 0.5:0.05:0.5;
        case 'specific_sinex1'
        % SPECIFIC SINEX1
            Pfit.p{1}       = 0.125:0.005:0.175;
            Pfit.p{2}       = 0.6:0.005:0.8;
            Pfit.p{3}       = 0.5:0.05:0.5;
        otherwise
        % DEFAULT
            Pfit.p{1}       = 0.05:0.01:0.2;
            Pfit.p{2}       = 0.1:0.05:1;
            Pfit.p{3}       = 0.7:0.05:0.7;
    end

    switch case_name
        case 'ArCu HiPSTER'
            path_discharge  = 'ArCu/original/ArCu_HiPSTER';
            disch_mat       = 'disch_0.5Pa.mat';

            F_flux_meas     = 0.6;
            IP.pressure     = 0.5;

            IP.pulseLength  = 35e-6;
            IP.solverTime   = (0:1:60)*1e-6;

        case 'ArCu HiPSTER 20A'
            path_discharge  = 'ArCu/original/ArCu_HiPSTER_20A';
            disch_mat       = 'disch.mat';

            F_flux_meas     = 0.32;
            IP.pressure     = 0.5;

            IP.pulseLength  = 40.1e-6;
            IP.solverTime   = (0:1:160)*1e-6;

        case 'ArCu Sinex2 27Pa'
            path_discharge  = 'ArCu/original/ArCu_Sinex2_27Pa';
            disch_mat       = 'disch.mat';

            F_flux_meas     = 0.375;
            IP.pressure     = 2.7;

            IP.pulseLength  = 95e-6;
            IP.solverTime   = (0:1:160)*1e-6;

        case 'ArCu Sinex2 04Pa'
            path_discharge  = 'ArCu/original/ArCu_Sinex2_04Pa';
            disch_mat       = 'disch.mat';

            F_flux_meas     = 0.39;
            IP.pressure     = 0.4;

            IP.pulseLength  = 85e-6;
            IP.solverTime   = (0:1:160)*1e-6;

        case 'ArCu Sinex1'
            path_discharge  = 'ArCu/original/ArCu_Sinex1';
            disch_mat       = 'disch_0.065Pa.mat';
%             disch_mat       = 'disch_40us.mat';
%             disch_mat       = 'disch_-10us.mat';

            F_flux_meas     = 0.7;
            F_flux_L_tol    = 0.5;
            F_flux_U_tol    = 0.5;
            IP.pressure     = 0.065;

            IP.pulseLength  = 150e-6;
            IP.solverTime   = (0:1:300)*1e-6;
%             IP.solverTime   = (40:1:300)*1e-6;
%             IP.solverTime   = (0:1:300)*1e-6;

        otherwise
            if ismember(case_name, cu_paper_disch)
                path_discharge  = case_name;
                disch_mat       = 'disch.mat';

                disch = load(fullfile('discharge',case_name,'disch.mat'),'disch');
                disch = disch.disch;

                if isfield(disch,'F_flux')
                    F_flux_meas = disch.F_flux;
                else
                    warning("Ionized flux fraction for case <%s> could not be identified.", case_name);
                    pause(5);
                    F_flux_L_tol = Inf;
                    F_flux_U_tol = Inf;
                end

                if contains(case_name,'0.4Pa')
                    IP.pressure = 0.4;
                elseif contains(case_name,'0.5Pa')
                    IP.pressure = 0.5;
                elseif contains(case_name,'2.7Pa')
                    IP.pressure = 2.7;
                else
                    warning("Pressure for case <%s> could not be identified.", case_name);
                    pause(5);
                    continue;
                end

                if contains(case_name,'40us')
                    IP.pulseLength  = 43e-6;
                    IP.solverTime   = (0:1:160)*1e-6;
                elseif contains(case_name,'80us')
                    IP.pulseLength  = 83e-6;
                    IP.solverTime   = (0:1:160)*1e-6;
                else
                    warning("Pulse length for case <%s> could not be identified.", case_name);
                    pause(5);
                    continue;
                end
            elseif ismember(case_name, cu_follow_up_disch)
                path_discharge  = fullfile("ArCu", "follow-up", case_name);
                disch_mat       = 'disch.mat';

                disch = load(fullfile('discharge',"ArCu", "follow-up", ...
                    case_name,'disch.mat'),'disch');
                disch = disch.disch;

                if isfield(disch,'F_flux')
                    F_flux_meas = disch.F_flux;
                else
                    warning("Ionized flux fraction for case <%s> could not be identified.", case_name);
                    pause(5);
                    F_flux_meas = 0;
                    F_flux_L_tol = Inf;
                    F_flux_U_tol = Inf;
                end

                if isfield(disch,'p')
                    IP.pressure = disch.p;
                else
                    warning("Pressure for case <%s> could not be identified.", case_name);
                    pause(5);
                    continue;
                end

                if contains(case_name,'25us')
                    IP.pulseLength  = 28e-6;
                    IP.solverTime   = (0:1:300)*1e-6;
                elseif contains(case_name,'50us')
                    IP.pulseLength  = 53e-6;
                    IP.solverTime   = (0:1:300)*1e-6;
                elseif contains(case_name,'75us')
                    IP.pulseLength  = 78e-6;
                    IP.solverTime   = (0:1:300)*1e-6;
                elseif contains(case_name,'100us')
                    IP.pulseLength  = 103e-6;
                    IP.solverTime   = (0:1:300)*1e-6;
                elseif contains(case_name,'150us')
                    IP.pulseLength  = 153e-6;
                    IP.solverTime   = (0:1:300)*1e-6;
                else
                    warning("Pulse length for case <%s> could not be identified.", case_name);
                    pause(5);
                    continue;
                end
            else
                warning("Case <%s> not found.", case_name);
                pause(5);
                continue;
            end
    end

    %% Set-up
    Pfit.dimension = cellfun(@(x) length(x), Pfit.p);
    
    cd parameters
    create_Para(case_name); % FIXME : moving around ain't good
    cd ..

    util.fig.setDefaultStyle();

    full_results_path = fullfile(path_results, path_discharge);
    if ~exist(full_results_path,'dir')

        mkdir(full_results_path);
        if eval_only
            warning("No previous simulations have been found for case <%s>", case_name);
        end
    else
        if ~eval_only
            full_results_path = strcat(full_results_path,...
                datestr(now,'yyyy-MM-dd_hhmm'));
            mkdir(full_results_path);
        end
    end

    %% Simulaiton
    start_time = tic();
    panel_Pfit_fct(path_discharge,...
                   disch_mat,...
                   full_results_path,...
                   F_flux_meas,...
                   Pfit,...
                   eval_only,...
                   IP,...
                   F_flux_L_tol,...
                   F_flux_U_tol, ...
                   true);
               
    sim_times(i_d) = toc(start_time);
    sim_numbers(i_d) = prod(Pfit.dimension);

    %% Clean-up    
 
    if close_figs
        close all;
    else
        util.fof;
    end

end
%{
% put all metadata in same place % FIXME : this is probably in the wrong
% place of the loop (with respect to seed density)
for i_d = 1:length(discharges)
    best.fom = table();
    best.flux = table();
    metadata = table();
    fom_matrix = zeros(0,0,0,0);
    F_flux_matrix = zeros(0,0,0,0);
    %for i_sd = 1:length(sd) % FIXME : look into this -> refer to comment
    %above
    subfolder = fullfile(strcat(subfolder_base,'-',level),sprintf('sd_%e',sd(i_sd)));
    path_results = fullfile('results',subfolder);
    meta = load(fullfile(path_results,strrep(discharges{i_d},' ','_'),'meta.mat'));
    meta.best.fom.sd(:) = sd(i_sd);
    meta.best.flux.sd(:) = sd(i_sd);
    meta.metadata.sd(:) = sd(i_sd);
    best.fom(end+1:end+height(meta.best.fom),:) = meta.best.fom;
    best.flux(end+1:end+height(meta.best.flux),:) = meta.best.flux;
    metadata(end+1:end+height(meta.metadata),:) = meta.metadata;
    fom_matrix(:,:,:,i_sd) = meta.fom_matrix;
    F_flux_matrix(:,:,:,i_sd) = meta.F_flux_matrix;
    %end
    savefiles = fullfile('results',strcat(subfolder_base,'-',level),...
        strcat(strrep(discharges{i_d},' ','_'),'.mat'));
    save(savefiles,'best','metadata','fom_matrix','F_flux_matrix');
end

%% Summary
disp(table(discharges.', sim_numbers, sim_times, sim_times./sim_numbers,...
    'VariableNames',{'Name','# of sim.','sim. time [s]','av. time per sim. [s]'}));

if col_Cu_results
    collect_results;
end
%}

end
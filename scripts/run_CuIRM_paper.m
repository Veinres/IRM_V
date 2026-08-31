
eval_only = true;
close_figs = true;
col_Cu_results = true;
level = 'specific2'; % 'coarse'; 'coarse2'; 'specific'; 'specific2'; 'detailed2';
subfolder_base = 'joel-cu_paper';

%%
util.fig.setDefaultStyle();

switch level
    case 'coarse'
        sd = [1e+16,1e+17,1e+18];
    case 'coarse2'
        sd = [5e+16,1e+17,5e+17];
    case 'specific'
        sd = [1e+17];
    case 'specific2'
        sd = [1e+17];
    case 'detailed2'
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
discharges{end+1} = 'ArCu/original/ArCu_HiPSTER_20A';
discharges{end+1} = 'ArCu/original/ArCu_Sinex2_04Pa';
discharges{end+1} = 'ArCu/original/ArCu_Sinex2_27Pa';
% IFF measurements discharges
discharges{end+1} = 'ArCu/irm/ArCu_HiPSTER_40us_0.5Pa_180A';
discharges{end+1} = 'ArCu/irm/ArCu_HiPSTER_80us_0.4Pa_165A';
discharges{end+1} = 'ArCu/irm/ArCu_HiPSTER_80us_2.7Pa_235A';

%% All Cases:
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
% discharges{end+1} = 'ArCu/irm/ArCu_HiPSTER_80us_0.4Pa_235A';
% discharges{end+1} = 'ArCu/irm/ArCu_HiPSTER_80us_0.4Pa_360A';
% 
% discharges{end+1} = 'ArCu/irm/ArCu_HiPSTER_80us_2.7Pa_130A';
% discharges{end+1} = 'ArCu/irm/ArCu_HiPSTER_80us_2.7Pa_165A';
% discharges{end+1} = 'ArCu/irm/ArCu_HiPSTER_80us_2.7Pa_200A';
% discharges{end+1} = 'ArCu/irm/ArCu_HiPSTER_80us_2.7Pa_235A';
% discharges{end+1} = 'ArCu/irm/ArCu_HiPSTER_80us_2.7Pa_360A';

%% Some other stuff
sim_times = zeros(length(discharges),1);
sim_numbers = zeros(length(discharges),1);

other_disch = { 'ArCu/irm/ArCu_HiPSTER_40us_0.5Pa_130A',...
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

%% Case Paramaters
path_results    = fullfile('results',subfolder);

for i_d=1:length(discharges)
    
    case_name = discharges{i_d};
    
    % default pfit parameters
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
            
            F_flux_meas     = 0.7;
            IP.pressure     = 0.065;
            
            IP.pulseLength  = 150e-6;
            IP.solverTime   = (0:1:200)*1e-6;

        otherwise
            if any(strcmp(case_name, other_disch))
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
            else
                warning("Case <%s> not found.", case_name);
                pause(5);
                continue;
            end
    end
    IP.disch_type = 'ArCu';

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
                   F_flux_U_tol);
               
    sim_times(i_d) = toc(start_time);
    sim_numbers(i_d) = prod(Pfit.dimension);

    %% Clean-up    
 
    if close_figs
        close all;
    else
        util.fof;
    end

end

% put all metadata in same place % FIXME : this is probably in the wrong
% place of the loop (with respect to seed density)
for i_d = 1:length(discharges)
    best.fom = table();
    best.flux = table();
    metadata = table();
    fom_matrix = zeros(0,0,0,0);
    F_flux_matrix = zeros(0,0,0,0);
    for i_sd = 1:length(sd)
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
    end
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

end
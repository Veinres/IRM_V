function panel_Pfit_fct(path_to_disch_mat,disch_mat,path_to_results, F_flux_meas, Pfit, eval_only, IP, F_flux_L_tol, F_flux_U_tol, collect, force_sequential, scan_name)
% TODO: add argument validation

if ~exist('eval_only','var')
    eval_only = false;
end
if ~exist('IP','var') || ~isstruct(IP)
    IP = struct();
end
if ~exist('F_flux_L_tol','var')
    F_flux_L_tol = 0.005;
end
if ~exist('F_flux_U_tol','var')
    F_flux_U_tol = 0.25;
end

if ~exist('collect', 'var') % collect results from entire parameter scan
    collect = false;
end

if ~exist('force_sequential', 'var') % collect results from entire parameter scan
    force_sequential = false;
end

% pulseLength is the pulse-on time in us.
% Specify the physical time of the simulation in analysis.fct

%% create output folder structure
if ~exist(path_to_results,'dir')
    mkdir(path_to_results);
    if eval_only
        error("No previous simulations available");
    end
end

%% Parameter fitting panel

if ~exist('Pfit','var')
    % TODO: remove this part and make Pfit a required argument
    % define the name of the parameters you want to fit
    
    warning("No parameter grid specified. Using default grid.");
    fprintf("Press any key to continue anyway. Press Ctrl+C to abort.")
    pause();
    
    Pfit.names={'f','beta','r'};
    p{1} = 0.05:0.05:0.25;
    p{2} = 0.1:0.1:1;
    p{3} = 0.5:0.25:0.5;
    Pfit.p=p;
    Pfit.dimension = cellfun(@(x) length(x), Pfit.p);
end

p = Pfit.p;
N = prod(Pfit.dimension);

avail_disch_types = {'ArTi', 'ArW', 'ArCu', 'ArC', 'ArCr', 'ArAl', 'ArZr', 'ArN2Ti', 'N2Ti', 'ArMo', 'HeMo','ArNeC','ArSi'};
if isfield(IP,'disch_type') && any(strcmpi(avail_disch_types,IP.disch_type))
    type = IP.disch_type;
else
    warning('No valid discharge type supplied. Using ArCu as default.');
    type = 'ArCu';
    pause();
end

[Spe, Rea, Precal, disch, Para] = import_data(path_to_disch_mat,disch_mat,type);

%% Simulation on parameter grid
if ~eval_only

    [i, j, k] = ind2sub(Pfit.dimension, 1:N);
    p1 = Pfit.p{1}(i).';
    p2 = Pfit.p{2}(j).';
    p3 = Pfit.p{3}(k).';
    n_workers = 1;
    if ~isempty(gcp('nocreate'))
        n_workers = gcp().NumWorkers;
    end
    if force_sequential
        n_workers = 1;
    end

    scan_label = "";
    if exist('scan_name','var') && ~isempty(scan_name)
        scan_label = sprintf("Scan name : %s\n", scan_name);
    end
    fprintf('>>~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n');
    fprintf('Starting parameter scan:\n');
    fprintf("%s", scan_label);
    fprintf('# parameter combinations: %d\n', N);
    fprintf('# workers: %d\n', n_workers);
    fprintf('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~<<\n');
    fprintf(newline);
    start_time = tic();
    clear reportStatus; % clear persitent variables in reportStatus % NOTE: doesn't work for some reason
    reportStatus(); % reset persitent variables in reportStatus

    if n_workers > 1
        % NOTE : might want to switch to parfeval (might make this bit
        % redundant and could be useful with we ever decide to get a minimalistic gui)
        % only run in parallel if a parallel pool already exists
        q = parallel.pool.DataQueue;
        afterEach(q, @reportStatus)
        parfor nrun = 1:N
            stats = panel_mode_single_run_Pfit_modified_fct(...
                path_to_disch_mat, ...
                disch_mat, ...
                path_to_results, ...
                p1(nrun), p2(nrun), p3(nrun), ...
                0, IP, [], [], ...
                Spe, Rea, Precal, disch, Para, nrun);
            stats.label = scan_label;
            stats.n = nrun;
            stats.N = N;
            stats.p_vals = [p1(nrun), p2(nrun), p3(nrun)];
            send(q, stats);
        end
    else
        % otherwise run in a sequential loop (should be faster than
        % sequential parfor)
        sendSeq = @reportStatus;
        for nrun = 1:N
            stats = panel_mode_single_run_Pfit_modified_fct(...
                path_to_disch_mat, ...
                disch_mat, ...
                path_to_results, ...
                p1(nrun), p2(nrun), p3(nrun), ...
                0, IP, [], [], ...
                Spe, Rea, Precal, disch, Para, nrun);
            stats.label = scan_label;
            stats.n = nrun;
            stats.N = N;
            stats.p_vals = [p1(nrun), p2(nrun), p3(nrun)];
            sendSeq(stats);
        end
    end

    total_exec_time = toc(start_time);
    fprintf('>>~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n');
    fprintf('Finished parameter scan:\n');
    fprintf("%s", scan_label);
    fprintf(append(pad('# parameter combinations:',36),'%d\n'), N);
    % fprintf(append(pad('# succesful runs:',36),'%d/%d\n'), N_success, N);
    % fprintf(append(pad('# average completion:',36),'%d\%\n'), average_completion);
    fprintf(append(pad('# workers:',36),'%d\n'), n_workers);
    fprintf(append(pad('# total time for parameter scan:',36),'%fs\n'), total_exec_time);
    fprintf(append(pad('# average time per run:',36),'%fs\n'), total_exec_time/N);
    fprintf(append(pad('# average cpu time per run:',36),'%fs\n'), total_exec_time/N*n_workers);
    fprintf('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~<<\n');

    nrun = N;
else
    nrun = prod(cellfun(@(x) length(x),p));
end

%% Post-processing

metadata = table();
fom_matrix = NaN(length(p{1}),length(p{2}),length(p{3}));
F_flux_matrix = ones(length(p{1}),length(p{2}),length(p{3}));

% NOTE: Change this to use a different fom (e.g. @(x) [x.foms.max])
% NOTE: The brackets are important!
get_fom = @(x) [x.fom];

% get metadata & results
for i_run = 1:nrun
    % load results file
    folder = strcat('run_Pfit',num2str(i_run));
    results_file = fullfile(path_to_results,folder,'Analysed.mat');
    results = load(results_file);
    % pack results into a table
    % (the carbon case has some extra fields we dont care about)
    flds = intersect(fieldnames(results),...
        {'R_sput_C','R_iz_C','alpha_R_t','alpha_R_t_all'});
    results = rmfield(results,flds);
    results = struct2table(results);
    % add entry to the fom/flux matrices
    ip1 = find(p{1}==results.f);
    ip2 = find(p{2}==results.beta1);
    ip3 = find(p{3}==results.r);
    fom_matrix(ip1,ip2,ip3) = get_fom(results);
    F_flux_matrix(ip1,ip2,ip3) = results.F_flux;
    % concatenate results table
    results = results(:,{'r','beta1','f','fom','F_flux','foms','beta_av','alpha_R','alpha_R_all','alpha_F_flux','F_density'});
    metadata(end+1,:) = results;
end

best.fom = table('Size',[length(p{3}),7],...
    'VariableTypes',{'double' 'double' 'double' 'double' 'double' 'double' 'double'},...
    'VariableNames',{'f','beta','r','fom','F_flux','alpha_R','beta_av'});
best.flux = best.fom;
for ip3 = 1:length(p{3})
    % best fom
    filtered = metadata(metadata.r(:)==p{3}(ip3),:);
    [fom, i] = min(get_fom(filtered));
    fom = fom(1); i = i(1);
    best.fom(ip3,:) = {filtered.f(i),filtered.beta1(i),filtered.r(i),fom,filtered.F_flux(i),filtered.alpha_R(i),filtered.beta_av(i)};
    % best fom F_flux constrained
    correct_F_flux = logical((filtered.F_flux(:)<F_flux_meas+F_flux_U_tol).*...
                             (filtered.F_flux(:)>F_flux_meas-F_flux_L_tol));
    filtered = filtered(correct_F_flux,:);
    if ~isempty(filtered)
        [fom, i] = min(get_fom(filtered));
        fom = fom(1); i = i(1);
        best.flux(ip3,:) = {filtered.f(i),filtered.beta1(i),filtered.r(i),fom,filtered.F_flux(i),filtered.alpha_R(i),filtered.beta_av(i)};
    else
        best.flux(ip3,:) = {NaN,NaN,NaN,NaN,NaN,NaN,NaN};
    end
end

% export results
save(fullfile(path_to_results,'meta.mat'),'metadata','fom_matrix','F_flux_matrix','best');

fom_matrix(isinf(fom_matrix)) = NaN;
F_flux_matrix(isnan(F_flux_matrix)) = 0;

% plot fom
for ip3=1:length(p{3})
    fig = figure('Name',strcat('fom',num2str(ip3)));
    title_fig = strcat('FOM with r=',num2str(p{3}(ip3)));
%     title(title_fig)
    hold all;
    % Plotting nice Fflux contours
    max_flux = max(F_flux_matrix(fom_matrix<1),[],'all'); % Should be this
    %warning("Using wrong fom criterion, search for 'FIXME' in panel_Pfit_fct!");
    %max_flux = max(F_flux_matrix(fom_matrix>0),[],'all'); % FIXME !!!!!!!!!!!!!!!!!!!!!!!!!
    max_flux = round(max_flux/0.05)*0.05;
    contourf(p{2},p{1},fom_matrix(:,:,ip3),0.:0.01:1.,'EdgeColor', 'none');
    colormap(flipud(colormap('parula')));
    clim([0,1]);
%     contour(p{2},p{1},F_flux_matrix(:,:,ip3),...
%             0:0.01:max_flux,...
%             'Color',0.2*[1,1,1],'LineWidth',0.25,'LineStyle','--');
    [C,h] = contour(p{2},p{1},F_flux_matrix(:,:,ip3),...
            0:0.05:max_flux,...
            'Color',0.0*[1,1,1],'LineWidth',1);% ,'TextColor',[0.75,0.75,0.75],'ShowText','on'
    clabel(C,h,'Color',0.0*[1,1,1],'FontWeight','bold');
    %contour(p{2},p{1},F_flux_matrix(:,:,ip3), 0:0.025:1,'k','ShowText','on');
    ylabel('$V_{\rm IR}/V_{\rm D}$','Interpreter','LaTex','FontSize',20);
    xlabel('$\beta_{\rm t,pulse}$','Interpreter','LaTex','FontSize',20);
    colorbar;
    box on;
    grid on;
    view(2)
%   plot3(best.fom.beta(ip3),best.fom.f(ip3),1,'wo', 'MarkerSize',16);
    plot3(best.flux.beta(ip3),best.flux.f(ip3),1,'o','MarkerEdgeColor',[0.5,0,0], 'MarkerSize',14);
    plot3(best.flux.beta(ip3),best.flux.f(ip3),1,'x','MarkerEdgeColor',[0.5,0,0], 'MarkerSize',14);
    hold on;
    savefig(fig, fullfile(path_to_results, strcat('fom', num2str(ip3), '.fig')))
end

% recompute best points
if true
	% best fom
    path_to_results_folder_single = strcat(path_to_results, '_fom');
    [~, i] = min(best.fom.fom(:));
    f = best.fom.f(i);
    beta = best.fom.beta(i);
    r = best.fom.r(i);
    panel_mode_single_run_Pfit_modified_fct(path_to_disch_mat, disch_mat, path_to_results_folder_single,...
        f, beta, r, 1, IP);
    % best fom F_flux constrained
    path_to_results_folder_single = strcat(path_to_results, '_flux');
    [v, i] = min(best.flux.fom(:));
    if ~isnan(v)
        f = best.flux.f(i);
        beta = best.flux.beta(i);
        r = best.flux.r(i);
        panel_mode_single_run_Pfit_modified_fct(path_to_disch_mat, disch_mat, path_to_results_folder_single,...
            f, beta, r, 1, IP);
    else
        warning("No run achieved an ionized flux fraction that was within the specified tolerances.");
    end
end

if collect
    % collect the results from the entire scan in a convenient structure
    [~, name, ext] = fileparts(path_to_results);
    rslt.scan.collect( ...
        path_to_results, ...
        "Id", strcat(name, ext), ...
        "SaveLocation", strcat(path_to_results, '.mat'))
end

end

%% function defintions

function reportStatus(stats)
    persistent n_finished_runs start_time
    if nargin < 1 || isempty(n_finished_runs) || isempty(start_time)
        % NOTE: for some reason clear reportStatus doesn't seem to clear
        % the persistent variables
        n_finished_runs = 0;
        start_time = tic();
        if nargin < 1; return; end
    else
        n_finished_runs = n_finished_runs + 1;
    end
    % stats:
    % - label
    % - n_calls
    % - exec_time
    % - end_time
    % - target_time
    % - exit_status
    % - fom
    % - n
    % - N
    % - p_vals
    average_time = toc(start_time)/n_finished_runs;
    output_str = append( ...
    sprintf('>>===================================================\n'), ...
    stats.label, ...
    sprintf('Parameter fitting run %i (%i/%i)\n', stats.n, n_finished_runs, stats.N), ...
    sprintf('Parameter values : [%f %f %f]\n', stats.p_vals), ...
    sprintf('-----------------------------------------------------\n'), ...
    sprintf(append(pad('#calls', 16, 'right'), '= %d\n'), stats.n_calls), ...
    sprintf(append(pad('exec. time', 16, 'right'), '= %g\n'), stats.exec_time), ...
    sprintf(append(pad('end time', 16, 'right'), '= %g\x03BCs / %g\x03BCs\n'), ...
    stats.end_time, stats.target_time), ...
    sprintf(append(pad('exit status', 16, 'right'), '= ''%s''\n'), stats.exit_status), ...
    sprintf(append(pad('new fom', 16, 'right'), '= %g\n'), stats.fom), ...
    sprintf('-----------------------------------------------------\n'), ...
    sprintf('Average time per run: %gs\n', average_time), ...
    sprintf('Estimated time until completion: %gs\n', average_time*(stats.N-n_finished_runs)), ...
    sprintf('===================================================<<\n'), ...
    newline);
    fprintf(output_str);
end

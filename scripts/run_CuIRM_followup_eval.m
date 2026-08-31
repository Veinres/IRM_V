%% Collect

% folder in which output structures are
foldername = ...
"/run/media/joel/Data/liu/IRM-Group/10_irm/10_irm/results/joel-new_dims-restricted2/sd_1.000000e+18/ArCu/follow-up";
foldername = fullfile(foldername);
if ~isfolder(fullfile(foldername, "all"))
    mkdir(fullfile(foldername, "all"));
end
rslt.study.collect(foldername, ...
    "SaveLocation", fullfile(foldername, "all"), ...
    "IdUpdate","filename");

%% Load summaries from all parameter scans
foldername = "/run/media/joel/Data/liu/IRM-Group/10_irm/10_irm/results/joel-new_dims-restricted2/sd_1.000000e+18/ArCu/follow-up/all";
foldername = fullfile(foldername);

% collect parameter scan summaries
[summary, metadata, results, input, output, best] = ...
    rslt.study.load(foldername, "ReplaceId", true);

% extract parameters from ids
res = cell2mat(arrayfun(@(str) (sscanf(str,"ArCu_%dus_%fPa_%dA_%d")).', ...
    summary.id, 'UniformOutput', false));
res = table(res(:,4), res(:,1), res(:,2), res(:,3), ...
    'VariableNames', {'expnr', 'pw', 'p', 'Ipk'});

summary = horzcat(res, summary);
summary = sortrows(summary, "expnr");

% get experimental data
cd(fullfile('../../20_exp/src/'));
[d_info, ~, ~] = ...
    import.discharges(fullfile("../data/meas/Cu/follow-up/"), ...
    'Plot', 'none', 'Verbose', false, 'LoadSaved', true, 'Save', false);
d_info = d_info(d_info.U_bias == 0 & abs(d_info.expnr)>0,:);
d_info = sortrows(d_info, "expnr");
cd(fullfile('../../10_irm/10_irm/'));

info = d_info(ismember(d_info.expnr, summary.expnr),:);

%% Plotting

util.fig.setDefaultStyle();

%% Current Fit

plt.study.currentFit(summary, input, output);

%% FOM
cfun = util.fig.interpColor('parula', 'Range', [0.5,0.0]);
sz_fun = @(x) 20 + 80*(1-x);
col_fun = @(x) cfun(x);
var = summary.fom.free;

scatterVal(summary, sz_fun(var), col_fun(var));
title('free');
c = colorbar(); clim([0.0,0.5]); c.TickLabels = c.Ticks(end:-1:1);
c.Label.String = 'FOM'; c.Label.Interpreter = 'latex';
c.TickLabelInterpreter = 'latex';

var = summary.fom.cnst;
scatterVal(summary, sz_fun(var), col_fun(var));
title('constrained');
c = colorbar(); clim([0.0,0.5]); c.TickLabels = c.Ticks(end:-1:1);
c.Label.String = 'FOM'; c.Label.Interpreter = 'latex';
c.TickLabelInterpreter = 'latex';

%% F_flux

cfun = util.fig.interpColor('parula', 'Range', [0.0,1.0]);
sz_fun = @(x) 20 + 80*x;
col_fun = @(x) cfun(x);

var = summary.F_flx.free;
scatterVal(summary, sz_fun(var), col_fun(var));
title('free');
c = colorbar(); clim([0.0,1.0]);
c.Label.String = '$F_\mathrm{flux}$'; c.Label.Interpreter = 'latex';
c.TickLabelInterpreter = 'latex';

var = summary.F_flx.cnst;
scatterVal(summary, sz_fun(var), col_fun(var));
title('constrained');
c = colorbar(); clim([0.0,1.0]);
c.Label.String = '$F_\mathrm{flux}$'; c.Label.Interpreter = 'latex';
c.TickLabelInterpreter = 'latex';

var = info.F_flux/100;
scatterVal(info, sz_fun(var), col_fun(var));
title('measured');
c = colorbar(); clim([0.0,1.0]);
c.Label.String = '$F_\mathrm{flux}$'; c.Label.Interpreter = 'latex';
c.TickLabelInterpreter = 'latex';

%% F_dep

cfun = util.fig.interpColor('parula', 'Range', [0.0,0.8]);
sz_fun = @(x) 20 + 80*x;
col_fun = @(x) cfun(x);

var = summary.F_dep.free;
scatterVal(summary, sz_fun(var), col_fun(var));
title('free');
c = colorbar(); clim([0.0,0.8]);
c.Label.String = '$F_\mathrm{dep}$'; c.Label.Interpreter = 'latex';
c.TickLabelInterpreter = 'latex';

var = summary.F_dep.cnst;
scatterVal(info, sz_fun(var), col_fun(var));
title('constrained');
c = colorbar(); clim([0.0,0.8]);
c.Label.String = '$F_\mathrm{dep}$'; c.Label.Interpreter = 'latex';
c.TickLabelInterpreter = 'latex';

var = info.F_dep/100;
scatterVal(info, sz_fun(var), col_fun(var));
title('measured');
c = colorbar(); clim([0.0,0.8]);
c.Label.String = '$F_\mathrm{dep}$'; c.Label.Interpreter = 'latex';
c.TickLabelInterpreter = 'latex';

%% Alpha
simpleVal(summary, 'alpha_t_av', '$\langle\alpha_t\rangle$', [0,1]);

%% Beta
simpleVal(summary, 'beta_t_av', '$\langle\beta_t\rangle$', [0,1]);

%% F_cmp
simpleVal(summary, 'F_cmp', '$\frac{t_{\rm end}}{t_{\rm target}}$', [0,1]);

%% F_ion
simpleVal(summary, 'F_ion', '$F_{\rm ion}$', [0,1]);

%% F_cur
simpleVal(summary, 'F_cur', '$F_{\rm cur}$', [0,1]);

%% F_rar
simpleVal(summary, 'F_rar', '$F_{\rm rar}$', [0,1]);

%% Function implementations

function [fig1, fig2] = simpleVal(summary, variable, label, range)
    cfun = util.fig.interpColor('parula', 'Range', range);
    sz_fun = @(x) 20 + 80*x;
    col_fun = @(x) cfun(x);
    
    var = summary.(variable).free;
    scatterVal(summary, sz_fun(var), col_fun(var));
    title('free');
    c = colorbar(); clim(range);
    c.Label.String = label; c.Label.Interpreter = 'latex';
    c.TickLabelInterpreter = 'latex';
    
    var = summary.(variable).cnst;
    scatterVal(summary, sz_fun(var), col_fun(var));
    title('constrained');
    c = colorbar(); clim(range);
    c.Label.String = label; c.Label.Interpreter = 'latex';
    c.TickLabelInterpreter = 'latex';
end

function fig = scatterVal(summary, sz_val, col_val)
    fig = figure;
    hold on;
    if all(ismember({'p', 'Ipk', 'pw'}, summary.Properties.VariableNames))
        scatter3(summary.p, summary.Ipk, summary.pw, sz_val, col_val,'filled');
    else
        scatter3(summary.p_process, summary.sp_I_pk, summary.sp_pw, sz_val, col_val,'filled');
    end
    xlabel('$p_\mathrm{g}$ [Pa]'); set(gca, 'xScale', 'log'); xlim([0.2,2.2]);
    ylabel('$I_\mathrm{D,peak}$ [A]'); ylim([0,300]);
    zlabel('p.w. [$\mu$s]'); zlim([0,100]);
    view(30,35);
end
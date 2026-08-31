function [fig1, fig2] = summary(summary, metadata, results, inputs, outputs)
%SUMMARY create various summary plots for diagnostic purposes
% =========================================================================
% Create two figures containing four plots each:
% Figure 1:
% - discharge plot
% - fom plot
% - individual current fits (2x)
% Figure 2:
%   various maps
%
% ARGUMENTS ---------------------------------------------------------------
% The arguements need to have to correct form (as produced e.g. by
% results.collect()).
%
%   summary     (table)
%   metadata    (table)
%   results     (table)
%   inputs      (struct)
%   outputs     (struct)
%
% RETURN ------------------------------------------------------------------
%
%   fig1        (figure), first figure (disch, current waveforms, FOM)
%
%   fig2        (figure), second figure (various)
%
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ NOTE ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This function requires Matlab 2019b or later.
% =========================================================================

%% NOTES: -----------------------------------------------------------------
% -------------------------------------------------------------------------

%% Argument parsing and validation
arguments
    summary table
    metadata table
    results table
    inputs struct
    outputs struct
end

%% Preparation
util.fig.setDefaultStyle();

if isfield(inputs.input.disch, 't_pulse_end')
    tlim = [inputs.input.disch.T(1), inputs.input.disch.t_pulse_end*1.1];
else
    tlim = [NaN,NaN];
end

%% Result overview

fig1 = figure();
tl = tiledlayout(2,2);
% Plot Input
tmp_fig = plt.disch('Struct', inputs.input.disch, 'xLim', tlim);
% TODO : add current fits
% lgnd = tmp_fig.CurrentAxes.Legend;
hold on;
yyaxis left;
if summary.nr.free > 0
    nr = summary.nr.free;
    h_free = plot(outputs.t{nr}*1e+6, outputs.I_IRM{nr}, ':', 'Color', [0,0,0.5], 'DisplayName', 'free');
end
if summary.nr.cnst > 0
    nr = summary.nr.cnst;
    h_const = plot(outputs.t{nr}*1e+6, outputs.I_IRM{nr}, '-.', 'Color', [0,0,0.75], 'DisplayName', 'constrained');
end
hold off;
ax1 = gca;
ax1.Parent = tl;
ax1.Layout.Tile = 1;
close(tmp_fig);

% Plot FOM
V2lim = [NaN,NaN];
if isfield(inputs.input.disch, 'F_flux_tol')
    if length(inputs.input.disch.F_flux_tol) > 1
        V2lim = inputs.input.disch.F_flux_tol;
    elseif isscalar(inputs.input.disch.F_flux_tol) && isfield(inputs.input.disch, 'F_flux')
        V2lim = inputs.input.disch.F_flux + [-1,+1]*inputs.input.disch.F_flux_tol;
    end
end
[tmp_fig, cm] = plt.scan.util.map(results, summary, metadata, 'V2lim', V2lim);
ax1 = gca;
ax1.Parent = tl;
ax1.Layout.Tile = 2;
close(tmp_fig);

% Plot current fits
tmp_fig = plt.scan.current(results, outputs, inputs, "xLim", tlim);
ax1 = gca;
ax1.Parent = tl;
ax1.Layout.Tile = 3;
close(tmp_fig);
% TODO: add best fits in red

% Plot current fits
tmp_fig = plt.scan.current(results, outputs, inputs, "xLim", tlim, "Primary", "beta_t_p", "Secondary", "f");
ax1 = gca;
ax1.Parent = tl;
ax1.Layout.Tile = 4;
close(tmp_fig);
% TODO: add best fits in red

% Maximise figure
set(fig1,'units','normalized','outerposition',[0 0 1 1]);

%% Statistics overview

% TODO: no plot if variable is missing
% TODO: auto range & lvls if none specified
% TODO: mark pulse length in F_cmp plot

fig2 = figure();
tl = tiledlayout(2,2);
% Plot
v1.var = 't_end';
v1.label = '$F_{\rm cmp}$';
t_target = inputs.input.solver.time(end);
v1.trans = @(x) x/t_target;
v1.range = [0,1];
v1.nlvls = 11;
v2.var = 't_exec';
v2.label = '$t_{\rm exec}$ [s]';
v2.range = [0,3];
v2.nlvls = 13;
[tmp_fig, cm] = plt.scan.util.map(results, summary, metadata, "V1", v1, "V2", v2);
ax1 = gca;
ax1.Parent = tl;
ax1.Layout.Tile = 1;
ax1.Colormap = cm;
close(tmp_fig);
clear v1 v2;

% Plot averaged material pathways variables
v1.var = 'beta_t_av';
v1.label = '$\langle\beta_{\rm t}\rangle$';
v1.range = [0,1];
v1.nlvls = 101;
v2.var = 'alpha_t_av';
v2.label = '$\langle\alpha_{\rm t}\rangle$';
v2.range = [0,1];
v2.nlvls = 21;
[tmp_fig, cm] = plt.scan.util.map(results, summary, metadata, "V1", v1, "V2", v2);
ax1 = gca;
ax1.Parent = tl;
ax1.Layout.Tile = 2;
ax1.Colormap = cm;
close(tmp_fig);
clear v1 v2;

% Plot flux and deposition fraction
v1.var = 'F_flx';
v1.label = '$F_{\rm flux}$';
v1.range = [0,1];
v1.nlvls = 101;
v2.var = 'F_dep';
v2.label = '$F_{\rm dep}$';
v2.range = [0,1];
v2.nlvls = 21;
[tmp_fig, cm] = plt.scan.util.map(results, summary, metadata, "V1", v1, "V2", v2);
ax1 = gca;
ax1.Parent = tl;
ax1.Layout.Tile = 3;
ax1.Colormap = cm;
close(tmp_fig);
clear v1 v2;

% Plot rarefaction and current fraction
v1.var = 'F_rar';
v1.label = '$F_{\rm rar}$';
v1.range = [0,1];
v1.nlvls = 101;
v2.var = 'F_cur';
v2.label = '$F_{\rm cur}$';
v2.range = [0,1];
v2.nlvls = 21;
[tmp_fig, cm] = plt.scan.util.map(results, summary, metadata, "V1", v1, "V2", v2);
ax1 = gca;
ax1.Parent = tl;
ax1.Layout.Tile = 4;
ax1.Colormap = cm;
close(tmp_fig);
clear v1 v2;

% Maximise figure
set(fig2,'units','normalized','outerposition',[0 0 1 1]);

end

function [frames, fig] = renderTimeEvolution(output, input, options)
%RENDERTIMEEVOLUTION create a movie of the time evolution of the discharge
% =========================================================================
% Creates a movies showing the evolving discharge graph, the current
% evolution, the evolution of the different densities and of the electron
% properties. The movie has one frame per timestep. Rendering typically
% 0.3-1s per frame. 
%
% See also plt.run.graph.plot, plt.run.graph.create
% See also plt.run.graph.plotIntegrated
%
% ARGUMENTS ---------------------------------------------------------------
%
%   output      (struct), the output produced using rslt.run.output
%
%   input       (struct), the input used for the simulation run%
%
% NAME-VALUE --------------------------------------------------------------
%
%   'SpeciesColors'(double, (n_nodes,3)), colors to use for the species
%
% RETURN ------------------------------------------------------------------
%
%   g           (digraph), the updated directed graph
%
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ NOTE ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This function requires Matlab 2019b or later.
% =========================================================================

%% NOTES: -----------------------------------------------------------------
% -------------------------------------------------------------------------

%% Argument parsing and validation
arguments
    output
    input
    options.SpeciesColors = []
    options.FrameIndices = []
end

if isempty(options.FrameIndices)
    options.FrameIndices = 1:length(output.t);
end

%% Create plots

g = plt.run.graph.create(input);

fig = figure;
util.fig.maximise(fig);
tl = tiledlayout(fig, 3, 2, "TileSpacing","compact");
ax_graph = nexttile(tl, 1, [3,1]);
ax_cv = nexttile(tl, 2, [1,1]);
ax_dens = nexttile(tl, 4, [1,1]);
ax_e = nexttile(tl, 6, [1,1]);

% graph
[~, ~, h_graph] = plt.run.graph.plot(g, "Parent", ax_graph, "NodeColors", options.SpeciesColors);

% species densities
hold(ax_dens, 'on');
plt.run.densities(output, input, "Parent", ax_dens, "YLim", [1e+15,1e+20], "SpeciesColors", options.SpeciesColors);
ylims_dens = ylim(ax_dens);
xlims = xlim(ax_dens);
legend(ax_dens, "AutoUpdate", "off", "Box", "on", "Location", "northeast", "NumColumns", 2);
h_dens_ptr = plot(ax_dens, 0*[1,1],ylims_dens, 'Color', 0.3*[1,1,1], 'LineStyle',':');
hold(ax_dens, 'off');

% current contributions
hold(ax_cv, 'on');
plt.run.currents(output, input, "Parent", ax_cv, "Exp", true, "XLim", xlims, "SpeciesColors", options.SpeciesColors);
ylims_cv = ylim(ax_cv);
ylims_cv = [0, util.num.roundTo(max(ylims_cv), 5, "Multiples", true, "Direction", "up")];
ylim(ax_cv, ylims_cv);
legend(ax_cv, "AutoUpdate", "off", "Box", "on", "Location", "northeast", "NumColumns", 2);
h_cv_ptr = plot(ax_cv, 0*[1,1],ylims_cv, 'Color', 0.3*[1,1,1], 'LineStyle', ':');
hold(ax_cv, 'off');

% electron properties
hold(ax_e, 'on');
plt.run.electrons(output, input, "Parent", ax_e, "XLim", xlims);
ylims_e = ylim(ax_e);
legend(ax_e, "AutoUpdate", "off", "Box", "on", "Location", "northeast", "NumColumns", 2);
h_e_ptr = plot(ax_e, 0*[1,1], ylims_e, 'Color', 0.3*[1,1,1], 'LineStyle', ':');
hold(ax_e, 'off');

%% Render frames

clear frames;
frames(length(options.FrameIndices)) = getframe(fig);
fprintf("Reposition/Resiye window if necessary. Rendering will start shortly.");
pause(5);

t_start = tic();

for f_ind=1:length(options.FrameIndices)
    t_ind = options.FrameIndices(f_ind);
    t = output.t(t_ind)*1e+6;
    rates = output.Rate(t_ind,:);
    n = output.n(t_ind,:);
    kickout = output.kickout(t_ind,:);
    diffusion = output.Diffrate(t_ind,:);
    sputtering = output.sputrate(t_ind,:);
    ionflux_RT = output.GAMMA_ion_RT(t_ind,:);
    ionflux_BP = output.GAMMA_ion_BP(t_ind,:);
    g = plt.run.graph.update(g, n, rates, diffusion, sputtering, ionflux_RT, ionflux_BP, kickout);

    set(h_graph, 'MarkerSize', max(max(log10(abs(g.Nodes.n+1e-300))-15,0)*10,1));
    set(h_graph, 'LineWidth', max(max(log10(abs(g.Edges.Weight)+1e-300)-18,0)*2,1));
    % set(h_graph, 'ArrowSize', max(max(log10(abs(g.Edges.Weight)+1e-300)-18,0),1)*10);

    title(tl, sprintf('\x0024t = %.1f\\mu s\x0024', t), 'Interpreter', 'latex');

    set(h_cv_ptr, 'XData', t*[1,1]);
    set(h_dens_ptr, 'XData', t*[1,1]);
    set(h_e_ptr, 'XData', t*[1,1]);

    frames(f_ind) = getframe(fig);
end

t_exec = toc(t_start);
fprintf('Rendered %d frames in %.2fs (%.2fs per frame)\n', t_ind, t_exec, t_exec/t_ind);

end

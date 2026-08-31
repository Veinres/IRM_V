function [fig, ax, h] = plot(g, options)
%CREATE plot a directed graph representing the modelled system
% =========================================================================
%
% See also plt.run.graph.update, plt.run.graph.create
% See also plt.run.graph.plotIntegrated
%
% ARGUMENTS ---------------------------------------------------------------
%
%   g           (digraph), directed graph associated with a modelled system
%
% NAME-VALUE --------------------------------------------------------------
%
%   'Parent'    (figure or axes object), parent in which to plot
%
%   'NodeColors'(double, (n_nodes,3)), colors to use for the nodes
%
% RETURN ------------------------------------------------------------------
%
%   fig         (figure), figure containing plot
%
%   ax          (axis), axis containing plot
%
%   h           (handle), handle to plot
%
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ NOTE ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This function requires Matlab 2019b or later.
% =========================================================================

%% NOTES: -----------------------------------------------------------------
% -------------------------------------------------------------------------

%% Argument parsing and validation
arguments
    g digraph
    options.Parent = []
    options.NodeColors = []
end

%%

[fig, ax] = util.fig.getAx(options.Parent);

sources = {'GS', 'RT'};
sinks = {'BP'};
if ~isempty(options.NodeColors)
    node_colors = option.NodeColors;
else
    colors = colororder();
    n_colors = size(colors, 1);
    n_nodes = height(g.Nodes);
    node_colors = colors(1+mod((1:n_nodes)-1,n_colors),:);
end
h = plot(ax, g, ...
    'Layout','layered', 'Sources', sources, 'Sinks', sinks, ...
    'AssignLayers', 'auto', ...
    'Direction', 'right', ...
    'EdgeLabel', strrep(g.Edges.Name, '_',' '), ...
    'MarkerSize', max(max(log10(abs(g.Nodes.n+1e-300))-15,0)*10,1), ...
    'LineWidth', max(max(log10(abs(g.Edges.Weight)+1e-300)-18,0)*2,1), ...
    'ArrowSize', 15, ...
    'NodeColor', node_colors, ...
    'EdgeColor', [0.3,0.4,0.5], ...
    'LineStyle', '-');

end

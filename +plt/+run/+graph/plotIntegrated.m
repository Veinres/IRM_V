function [fig, g] = plotIntegrated(output, input, options)
%PLOTINTEGRATED plot a directed graph representing the integrated modelled system
% =========================================================================
% Integrates the deneities and rates over the entire simulated time and
% plot the system graph with the edge and nodes values given by the
% integrated values.
%
% See also plt.run.graph.update, plt.run.graph.create
% See also plt.run.graph.plotIntegrated
%
% ARGUMENTS ---------------------------------------------------------------
%
%   output      (struct), the output produced using rslt.run.output
%
%   input       (struct), the input used for the simulation run
%
% NAME-VALUE --------------------------------------------------------------
%
%   'Parent'    (figure or axes object), parent in which to plot
%
%   'NodeColors'(double, (n_nodes,3)), colors to use for the nodes
%
%   'Multiplier'(double), Factor with which node and edge values are
%                   multiplied before plotting. Can be useful if
%                   Nodes/Edges would be too small or large otherwise.
%
% RETURN ------------------------------------------------------------------
%
%   fig         (figure), figure containing plot
%
%   g           (digraph), the created directed graph
%
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ NOTE ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This function requires Matlab 2019b or later.
% =========================================================================

%% NOTES: -----------------------------------------------------------------
% -------------------------------------------------------------------------

%% Argument parsing and validation
arguments
    output struct
    input struct
    options.Multiplier double = 1000
    options.Parent = []
    options.NodeColors = []
end

%%

t = output.t*options.Multiplier;
g = plt.run.graph.create(input);
g = plt.run.graph.update(g, ...
    trapz(t,output.n,1), ...
    trapz(t,output.Rate,1), ...
    trapz(t,output.Diffrate,1), ...
    trapz(t,output.sputrate,1), ...
    trapz(t,output.GAMMA_ion_RT,1), ...
    trapz(t,output.GAMMA_ion_BP,1), ...
    trapz(t,output.kickout,1));
fig = plt.run.graph.plot(g, ...
    "NodeColors", options.NodeColors, ...
    "Parent", options.Parent);

end

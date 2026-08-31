function [g] = update(g, n, rates, diffusion, sputtering, ionflux_RT, ionflux_BP, kickout)
%UPDATE update the nodes and edges of the graph of a modelled system
% =========================================================================
% Sets the node values to the density of the respecitve species and sets
% the weights of the edges to the rate corresponding to the reaction or
% flux etc.
%
% See also plt.run.graph.plot, plt.run.graph.create
% See also plt.run.graph.plotIntegrated
%
% ARGUMENTS ---------------------------------------------------------------
%
%   g           (digraph), directed graph associated with a modelled system
%
%   n           (double, (1,n_species)), densities
%
%   rates       (double, (1,n_reactions)), reaction rates
%
%   diffusion   (double, (1,n_species)), diffusion rates
%
%   sputtering  (double, (1,n_species)), sputter rate
%
%   ionflux_RT  (double, (1,n_species)), ion "flux" to target
%
%   ionflux_BP  (double, (1,n_species)), ion "flux" to bluk plasma
%
%   kickout     (double, (1,n_species)), kickout rate
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

n_species = sum(g.Nodes.ID > 0);

g.Nodes.n(1:n_species) = n(1:n_species);

msk = g.Edges.ID > 0;
g.Edges.R(msk) = rates(g.Edges.Ind(msk));

msk = g.Edges.Type == 'ionfluxRT';
g.Edges.R(msk) = ionflux_RT(g.Edges.Ind(msk));

msk = g.Edges.Type == 'ionfluxBP';
g.Edges.R(msk) = ionflux_BP(g.Edges.Ind(msk));

msk = g.Edges.Type == 'diff';
g.Edges.R(msk) = diffusion(g.Edges.Ind(msk));

msk = g.Edges.Type == 'sput';
g.Edges.R(msk) = sputtering(g.Edges.Ind(msk));

msk = g.Edges.Type == 'kick';
g.Edges.R(msk) = kickout(g.Edges.Ind(msk));

g.Edges.Weight = g.Edges.R;

end

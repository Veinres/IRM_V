function [fig] = densities(output, input, options)
%DENSITIES plot the species densities
% =========================================================================
% Plots the densities of different species. A wrapper around
% perSpeciesProperty for the lazy (lazy is good, actually).
%
% See also plt.run.util.perSpeciesProperty
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
%   'XLim'      (double (1,2)), x axis limits
%                   By default the limits are not modified.
%
%   'YLim'      (double (1,2)), y axis limits
%                   By default the limits are not modified.
%
%   'Mask'      (logical (:,1) or double (:,1)), valid species index/mask
%
%   'SpeciesColors'(double (:,3)), colors to be used for species
%
%   'GroupLineStyle'(string (:,1)), LineStyle to be used for species grp
%
%   'PltArgs'   (cell), additional arguments for `plot`
%
% RETURN ------------------------------------------------------------------
%
%   fig         (figure handle), plotted figure
%
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ NOTE ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This function requires Matlab 2019b or later.
% =========================================================================

%% NOTES: -----------------------------------------------------------------
% IDEA : create an area (stacked line plot) variant
% -------------------------------------------------------------------------

%% Argument parsing and validation
arguments
    output struct
    input struct
end
arguments
    options.Parent = []
    options.XLim (1,2) double = [NaN,NaN]
    options.YLim (1,2) double = [NaN,NaN]
    options.Mask (:,1) = []
    options.SpeciesColors (:,3) double = []
    options.GroupLineStyle (:,1) string = []
    options.SpeciesLineProp struct = struct()
    options.PltArgs cell = {};
end

%%

options.YLabel = '$n$ [$\rm m^{-3}$]';
options.XLabel = '$t$ [$\rm \mu s$]';

options_ = namedargs2cell(options);
fig = plt.run.util.perSpeciesProperty(output, input, 'n', options_{:});
set(gca, 'yscale', 'log');

if any(isnan(options.YLim))
    ylims = ylim();
    ylims(1) = 1e+10;
    ylim(ylims);
end

end

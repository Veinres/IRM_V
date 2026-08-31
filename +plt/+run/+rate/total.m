function [fig] = total(output, input, options)
%TOTAL plot the rates at which species are generated/lost
% =========================================================================
% Plots the rate of change of the densities of the different species.
% A wrapper around perSpeciesProperty for the lazy
% (lazy is good, actually).
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
% RETURN ------------------------------------------------------------------
%
%   fig         (figure handle), plotted figure
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
end
arguments
    options.Parent = []
    options.XLim (1,2) double = [NaN,NaN]
    options.YLim (1,2) double = [NaN,NaN]
    options.Mask (:,1) = []
    options.SpeciesColors (:,3) double = []
end

%%

options.YLabel = '$\frac{{\rm d}n}{{\rm d} t}$ [$\rm m^{-3}\,s^{-1}$]';
options.XLabel = '$t$ [$\rm \mu s$]';

options_ = namedargs2cell(options);
fig = plt.run.util.perSpeciesProperty(output, input, 'dndt', options_{:});

end

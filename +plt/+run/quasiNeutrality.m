function [fig] = quasiNeutrality(output, input, options)
%QUASINEUTRALITY plot the charge densities due to the different species
% =========================================================================
% Plots the electron temperatures.
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
    output (1,1) struct
    input (1,1) struct
end
arguments
    options.Parent = []
    options.XLim (1,2) double = [NaN,NaN]
    options.YLim (1,2) double = [NaN,NaN]
end

%%

t = output.t*1e+6;

[fig, ax] = util.fig.getAx(options.Parent);
hold on;

output.rho = output.n(:,1:end-1).*input.Spe.Q;
plt.run.util.perSpeciesProperty(output, input, 'rho', 'YTrans', @abs, 'Mask', input.Spe.Q ~= 0, 'Parent', ax);

plot(ax, t, abs(sum(output.rho(:,input.Spe.Q ~= 0),2)), 'LineStyle','-', 'Color', [0,0,0], 'DisplayName', 'total');

ylabel(ax, '$\vert \rho/e\vert$ [$\rm m^{-3}$]');
xlabel(ax, '$t$ [$\rm \mu s$]');

set(ax, 'yscale', 'log');

if ~any(isnan(options.XLim))
    xlim(options.XLim);
end

if ~any(isnan(options.YLim))
    ylim(ax, options.YLim);
else
    % ylims = ylim();
    % ylims(1) = max(0.1, ylims(1));
    % ylim(ylims);
    % ylim(ax, 10.^[10,20]);
    % yticks(ax, 10.^(-1:1:3));
end

end

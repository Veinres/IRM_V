function [fig] = electrons(output, input, options)
%ELECTRONS plot the temperatures and densities of the cold and hot electrons
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
%   'YLimLeft'  (double (1,2)), left y axis limits
%                   By default the limits are not modified.
%
%   'YLimRight' (double (1,2)), right y axis limits
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
    options.YLimLeft (1,2) double = [NaN,NaN]
    options.YLimRight (1,2) double = [NaN,NaN]
end

%%

t = output.t*1e+6;

[fig, ax] = util.fig.getAx(options.Parent);
lgndstr = {};
hold on;
yyaxis left;
plot(ax, t, output.T_ec, 'LineStyle', '-');
lgndstr{end+1} = '$T_{\rm e_{\rm c}^{-}}$';
plot(ax, t, output.T_eh, 'LineStyle', '--');
lgndstr{end+1} = '$T_{\rm e_{\rm h}^{-}}$';
ylabel('$T$ [$\rm eV$]');
yyaxis right;
plot(ax, t, output.n(:,input.Spe.s.e), 'LineStyle', '-');
lgndstr{end+1} = '$n_{\rm e_{\rm c}^{-}}$';
plot(ax, t, output.n(:,input.Spe.s.eh), 'LineStyle', '--');
lgndstr{end+1} = '$n_{\rm e_{\rm h}^{-}}$';
ylabel(ax, '$n$ [$\rm m^{-3}$]');

xlabel(ax, '$t$ [$\rm \mu s$]');

legend(lgndstr);

yyaxis left; set(gca, 'yscale', 'log');
yyaxis right; set(gca, 'yscale', 'log');


if ~any(isnan(options.XLim))
    xlim(options.XLim);
end

if ~any(isnan(options.YLimLeft))
    yyaxis left;
    ylim(ax, options.YLimLeft);
else
    yyaxis left; 
    % ylims = ylim();
    % ylims(1) = max(0.1, ylims(1));
    % ylim(ylims);
    ylim(ax, 10.^[-1,3]);
    yticks(ax, 10.^(-1:1:3));
end
if ~any(isnan(options.YLimRight))
    yyaxis right;
    ylim(ax, options.YLimRight);
else
    yyaxis right; 
    % ylims = ylim();
    % ylims(1) = max(1e+12, ylims(1));
    % ylim(ylims);
    ylim(ax, 10.^[12,20]);
    yticks(ax, 10.^(12:2:20));
end

end

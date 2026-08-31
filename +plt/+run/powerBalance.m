function [fig] = powerBalance(output, input, options)
%POWERBALANCE plot the energy balance for cold and hot electrons
% =========================================================================
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
%   'Population'(char, default='both'), which population to plot
%                   - 'hot'
%                   - 'cold'
%                   - 'both'
%
%   'Colors'    (double (:,3)), colors to be used
%
%   'Units'     (char), which unit to use for the z axis
%                   - 'J' : use Watt/m3
%                   - 'eV': use eV/m3
%
%   'LogAbs'    (logical, default=false), if true, plot log of abs values
%                   instead
%
%   'TotalOnly' (logical, default=false), if true, only plot the net
%                   energy input
%
%   'MarkTotalZeros' (logical, default=false), whether to mark zero
%                   crossings in the net power with a diamond marker
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
    output (1,1) struct
    input (1,1) struct
end
arguments
    options.Parent = []
    options.XLim (1,2) double = [NaN,NaN]
    options.YLim (1,2) double = [NaN,NaN]
    options.Population char {mustBeMember(options.Population, {'hot', 'cold', 'both'})} = 'both'
    options.TotalOnly (1,1) logical = false
    options.LogAbs (1,1) logical = false
    options.Colors (:,3) double = []
    options.Units char {mustBeMember(options.Units, {'J','eV'})} = 'J'
    options.MarkTotalZeros logical = false
end

t = output.t*1e+6;
[fig, ax] = util.fig.getAx(options.Parent);
lgndstr = {};
hold on;

if isempty(options.Colors)
    colors = colororder();
else
    colors = options.Colors;
end
n_colors = size(colors,1);

trans = @(x) x;
if options.LogAbs
    trans = @abs;
end

switch options.Units
    case 'J'
        factor = phys.const.e;
    otherwise % 'eV'
        factor = 1;
end

%% Cold electrons
if ismember(options.Population, {'cold', 'both'})
    i_c = 1;
    if options.MarkTotalZeros && options.LogAbs
        util.fig.plotAbs(t, factor*output.P_ec, 'pltArgs', {'LineStyle', '-', 'Color', colors(i_c,:)}, 'Parent', ax);
    else
        plot(ax, t, factor*trans(output.P_ec), 'LineStyle', '-', 'Color', colors(i_c,:));
    end
    lgndstr{end+1} = 'cold $\rm e^{-}$ : total';
    if ~options.TotalOnly
        i_c = 1 + mod(i_c,n_colors);
        plot(ax, t, factor*trans(output.P_ec_applied), 'LineStyle', '-', 'Color', colors(i_c,:));
        lgndstr{end+1} = 'cold $\rm e^{-}$ : applied';
        i_c = 1 + mod(i_c,n_colors);
        plot(ax, t, factor*trans(output.P_ec_coll_loss), 'LineStyle', '-', 'Color', colors(i_c,:));
        lgndstr{end+1} = 'cold $\rm e^{-}$ : eff. ion. costs';
        i_c = 1 + mod(i_c,n_colors);
        plot(ax, t, factor*trans(output.P_ec_deex_c), 'LineStyle', '-', 'Color', colors(i_c,:));
        lgndstr{end+1} = 'cold $\rm e^{-}$ : deexc.';
        i_c = 1 + mod(i_c,n_colors);
        plot(ax, t, factor*trans(output.P_ec_deex_P), 'LineStyle', '-', 'Color', colors(i_c,:));
        lgndstr{end+1} = 'cold $\rm e^{-}$ : deexc. Pen.';
        i_c = 1 + mod(i_c,n_colors);
        plot(ax, t, factor*trans(output.P_ec_hot2cold), 'LineStyle', '-', 'Color', colors(i_c,:));
        lgndstr{end+1} = 'cold $\rm e^{-}$ : hot $\rightarrow$ cold';
    end
end

%% Hot electrons
if ismember(options.Population, {'hot', 'both'})
    i_c = 1;
    if options.MarkTotalZeros && options.LogAbs
        util.fig.plotAbs(t, factor*output.P_eh, 'pltArgs', {'LineStyle', '--', 'Color', colors(i_c,:)}, 'Parent', ax);
    else
        plot(ax, t, factor*trans(output.P_eh), 'LineStyle', '--', 'Color', colors(i_c,:));
    end
    lgndstr{end+1} = 'hot $\rm e^{-}$ : total';
    if ~options.TotalOnly
        i_c = i_c + 1;
        plot(ax, t, factor*trans(output.P_eh_ohm_heat), 'LineStyle', '--', 'Color', colors(i_c,:));
        lgndstr{end+1} = 'hot $\rm e^{-}$ : ohmic heating';
        i_c = i_c + 1;
        plot(ax, t, factor*trans(output.P_eh_izh_cost), 'LineStyle', '--', 'Color', colors(i_c,:));
        lgndstr{end+1} = 'hot $\rm e^{-}$ : eff. ion. costs';
        i_c = i_c + 1;
        plot(ax, t, factor*trans(output.P_eh_deex_h), 'LineStyle', '--', 'Color', colors(i_c,:));
        lgndstr{end+1} = 'hot $\rm e^{-}$ : deexc.';
    end
end

%%

if options.LogAbs
    set(ax, 'YScale', 'log');
    varn = '$\vert P\vert$';
    ylim(ax, 10.^[0,10]);
else
    varn = '$P$';
end
switch options.Units
    case 'J'
        unit = '[$W\,m^{-3}$]';
    otherwise % 'eV'
        unit = '[$eV\,s^{-1}\,m^{-3}$]';
end

ylabel(ax, strcat(varn, ' ', unit));
xlabel(ax, '$t$ [$\rm \mu s$]');

legend(ax, lgndstr, 'Location', 'best');

if ~any(isnan(options.XLim))
    xlim(ax, options.XLim);
end

if ~any(isnan(options.YLim))
    ylim(ax, option.YLim);
end

end

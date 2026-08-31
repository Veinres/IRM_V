function [fig] = currents(output, input, options)
%CURRENTS plot the IRM current and the input current
% =========================================================================
% Plots the total current, secondary electron current, current due to
% the different ion species, and the experimentally measured current.
% The different currents can be toggled using the respective Name-Value
% pairs.
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
%                   The default behaviour depends on whether the disch
%                   structure has an 't_pulse_end' field. If it has, then
%                   the next higher xtick is selected as upper limit.
%                   Otherwise the limits are not modified.
%
%   'AutoXLim'  (logical, default=true), set to false to turn off automatic
%                   x-axis limits
%
%   'YLim'      (double (1,2)), y axis limits
%                   By default the limits are not modified.
%
%   'Exp'       (logical), if true, plot the experimental current
%   'Total'     (logical), if true, plot the total IRM current
%   'Ion'       (logical), if true, plot the individual ion currents
%   'SE'        (logical), if true, plot the total SE current
%
%   'Normalisation' (char, default='none'), 'exp' or 'IRM', 'none'
%                   Normalise the y values with respect to the experimental
%                   current or the IRM current.
%
%   'SpeciesColors'(double, (:,3)), colors to be used for species
%
%   'GroupLineStyle'(string (:,1)), LineStyle to be used for species grp
%
%   'PSPArgs'   (cell), additional arguments for `plt.run.perSpeciesProperty`
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
    options.Exp logical = false
    options.Total logical = true
    options.Ion logical = true
    options.SE logical = true
    options.SpeciesColors (:,3) double = []
    options.GroupLineStyle (:,1) string = []
    options.SpeciesLineProp struct = struct()
    options.AutoXLim logical = true
    options.PSPArgs cell = {};
    options.Normalisation char {mustBeMember(options.Normalisation, {'exp','IRM','none'})} = 'none'
end
% 
%%

I_se = sum(output.I_se,2);
I_tot = I_se + sum(output.I,2);
t = output.t*1e+6;

switch options.Normalisation
    case 'exp'
        ytrans = @(y) y./output.dis_Id;
    case 'IRM'
        ytrans = @(y) y./I_tot;
    otherwise
        ytrans = @(y) y;
end

[fig, ax] = util.fig.getAx(options.Parent);
hold on;

c = colororder();

if options.Exp
    plot(ax, t, ytrans(output.dis_Id), 'LineStyle', '-', 'Color', 0.6*[1,1,1], ...
        'DisplayName', 'exp.');
end
if options.Total
    plot(ax, t, ytrans(I_tot), 'LineStyle', ':', 'Color', 0.25*[1,1,1], ...
        'DisplayName', 'total');
end
if options.SE
    plot(ax, t, ytrans(I_se), 'LineStyle', '-', 'Color', c(end,:), ...
        'DisplayName', 'sec. e$^{-}$');
end
if options.Ion
    fig = plt.run.util.perSpeciesProperty(output, input, 'I', ...
        'Mask', input.Range.ion, 'Parent', ax, ...
        'SpeciesColors', options.SpeciesColors, ...
        'GroupLineStyle', options.GroupLineStyle, ...
        'SpeciesLineProp', options.SpeciesLineProp, ...
        'YTrans', ytrans, ...
        options.PSPArgs{:});
else
    legend();
end

switch options.Normalisation
    case 'exp'
        ylabel('$I/I_{\rm D}$ [$\rm -$]');
    case 'IRM'
        ylabel('$I/I_{\rm IRM}$ [$\rm -$]');
    otherwise
        ylabel('$I$ [$\rm A$]');
end
xlabel('$t$ [$\rm \mu s$]');

ax = fig.CurrentAxes;
if ~any(isnan(options.XLim))
    xlim(ax, options.XLim);
elseif options.AutoXLim && isfield(input.disch, 't_pulse_end')
    xlims = xlim(ax);
    xlims(2) = util.num.roundTo(input.disch.t_pulse_end, xticks(ax), 'Multiples', true, 'Direction', 'up');
    xlim(ax, xlims);
end

if ~any(isnan(options.YLim))
    ylim(ax, option.YLim);
end

end

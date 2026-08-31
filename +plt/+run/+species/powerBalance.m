function [fig] = powerBalance(output, input, species, options)
%POWERBALANCE plot the energy losses/gains thought reactions for a species
% =========================================================================
% The plot shows the power lost/gained by the hot/cold electron populations
% through reactions involving a given species.
%
% See also plt.run.powerBalance
%
% ARGUMENTS ---------------------------------------------------------------
%
%   output      (struct), the output produced using rslt.run.output
%
%   input       (struct), the input used for the simulation run
%
%   species     (char), name of species to plot
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
%   'Which'     (char, default='net'), which parts to plot
%                   - 'prod'    : plot produced rate
%                   - 'react'   : plot consumed rate
%                   - 'net'     : plot net production rate
%                   - 'any'     : plot reaction rate
%
%   'YScale'    (char, default='auto'), chose a y-axis scale mode
%                   - 'log'     : logarithmic y-axis scale
%                   - 'linear'  : linear y-axis scale
%                   - 'auto'    : logaritmic if not Which='net'
%
%   'ReaNr'     (char, default=true), include reaction nr in label
%
%   'ReaTag'    (char, default=true), include reaction tag in label
%
%   'ReaEq'     (char, default=false), include reaction equation in label
%
%   'ReaType'   (char, default=false), include reaction type in label
%
%   'ReaEqOpts' (cell), options passed to eq string generator
%                   default: {'Style', 'latex', 'Reduce', true}
%
%   'ConsistentCurrent' (double, default=0), parent in which to plot
%
%   'K1'        (double, default=0.5), applied power fraction
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
    species char
end
arguments
    options.Parent = []
    options.Mask (:,1) = 1:length(input.Rea.Pcell)
    options.XLim (1,2) double = [NaN,NaN]
    options.YLim (1,2) double = [NaN,NaN]
    options.Population char {mustBeMember(options.Population, {'hot', 'cold', 'both'})} = 'both'
    options.Units char {mustBeMember(options.Units, {'J','eV'})} = 'J'
    options.Which char {mustBeMember(options.Which, {'ion', 'deexc', 'penning', 'all'})} = 'all'
    options.SplitIonisation logical = false;
    options.PlotApplied logical = false;
end
arguments
    options.LogAbs (1,1) logical = false
    options.Colors (:,3) double = []
end
arguments
    options.ReaNr logical = true
    options.ReaTag logical = true
    options.ReaEq logical = false
    options.ReaType logical = false
    options.ReaEqOpts cell = {'Style', 'latex', 'Reduce', true}
end
arguments
    options.ConsistentCurrent double = 0
    options.K1 double = 0.5
end

if isempty(options.Colors)
    colors = colororder();
else
    colors = options.Colors;
end

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

if isfield(input.IP, 'consistent_current') && input.IP.consistent_current
    options.ConsistentCurrent = input.IP.consistent_current;
end
if isfield(input.IP, 'K1')
    options.K1 = input.IP.K1;
end

%% Filter ractions

i_spe = input.Spe.s.(species);
n_reactions = length(input.Rea.Pcell);
msk = input.Rea.P(:,i_spe) | input.Rea.R(:,i_spe);
nrs = util.mask.op(options.Mask, msk, @intersect);
msk = util.mask.toLogical(nrs, [n_reactions,1]);

%% Get reaction labels and power balance data

if ~options.ReaNr && ~options.ReaEq && ~options.ReaTag
    options.ReaNr = true;
end
reastr = material.util.reactions.stringReps( ...
    input.Rea.reactions, input.Spe, ...
    'ReaEqOpts', options.ReaEqOpts);
reastr(:, [options.ReaNr, options.ReaEq, options.ReaTag, options.ReaType]);
reastr = join(reastr, ' : ', 2);

t = output.t*1e+6;

pb = rslt.run.powerBalance(output, input, ...
    "ConsistentCurrent", options.ConsistentCurrent, "K1", options.K1); % FIXME : consisten current and K1 should go into input

%% Plot prep.

[fig, ax] = util.fig.getAx(options.Parent);

n_colors = size(colors,1);
ax.ColorOrder = colors(); % this is pretty much redundant
ax.LineStyleOrder = {'-','-.','--',':'};
ax.LineStyleCyclingMethod = 'withcolor';

%% Plotting

hold on;
if ismember(options.Population, {'cold', 'both'})
    % applied
    if options.PlotApplied
        plot(t, factor*trans(pb.applied), ...
            "DisplayName", "IR energization");
    end
    % ion
    if ismember(options.Which, {'ion', 'all'})
        combined_mask = util.mask.op(nrs, pb.msk.ion_c, @intersect);
        if ~options.SplitIonisation
            for j = 1:length(combined_mask)
                i = combined_mask(j);
                plot(t, factor*trans(-pb.izc_cost(:,i) - pb.izc_cost_dnedt(:,i)), ...
                    "DisplayName", reastr(i));
            end
        else
            for j = 1:length(combined_mask)
                i = combined_mask(j);
                plot(t, factor*trans(-pb.izc_cost(:,i)), ...
                    "DisplayName", reastr(i));
                plot(t, factor*trans(-pb.izc_cost_dnedt(:,i)), ...
                    "DisplayName", reastr(i) + " $(\Delta n_{\rm e})$");
            end
        end
    end
    % penning
    if ismember(options.Which, {'penning', 'all'})
        combined_mask = util.mask.op(nrs, pb.msk.deex_P, @intersect);
        if ~options.SplitIonisation
            for j = 1:length(combined_mask)
                i = combined_mask(j);
                plot(t, factor*trans(pb.deex_P(:,i) + pb.deex_P_dnedt(:,i)), ...
                    "DisplayName", reastr(i));
            end
        else
            for j = 1:length(combined_mask)
                i = combined_mask(j);
                plot(t, factor*trans(pb.deex_P(:,i)), ...
                    "DisplayName", reastr(i));
                plot(t, factor*trans(pb.deex_P_dnedt(:,i)), ...
                    "DisplayName", reastr(i) + " $(\Delta n_{\rm e})$");
            end
        end
    end
    % exec
    if ismember(options.Which, {'exec', 'all'})
        combined_mask = util.mask.op(nrs, pb.msk.deex_c, @intersect);
        for j = 1:length(combined_mask)
            i = combined_mask(j);
            plot(t, factor*trans(pb.deex_c(:,i)), ...
                "DisplayName", reastr(i));
        end
    end
    % h2c
    combined_mask = util.mask.op(nrs, pb.msk.h2c, @intersect);
    for j = 1:length(combined_mask)
        i = combined_mask(j);
        plot(t, factor*trans(pb.hot2cold(:,i)), ...
            "DisplayName", reastr(i) + " (hot $\rightarrow$ cold)");
    end
end
if ismember(options.Population, {'hot', 'both'})
    % applied
    if options.PlotApplied
        plot(t, factor*trans(pb.Ohm_heat), ...
            "DisplayName", "sheath energization");
    end
    % ion
    if ismember(options.Which, {'ion', 'all'})
        combined_mask = util.mask.op(nrs, pb.msk.ion_h, @intersect);
        if ~options.SplitIonisation
            for j = 1:length(combined_mask)
                i = combined_mask(j);
                plot(t, factor*trans(-pb.izh_cost(:,i) - pb.izh_cost_dnedt(:,i)), ...
                    "DisplayName", reastr(i));
            end
        else
            for j = 1:length(combined_mask)
                i = combined_mask(j);
                plot(t, factor*trans(-pb.izh_cost(:,i)), ...
                    "DisplayName", reastr(i));
                plot(t, factor*trans(-pb.izh_cost_dnedt(:,i)), ...
                    "DisplayName", reastr(i) + " $(\Delta n_{\rm e})$");
            end
        end
    end
    % exec
    if ismember(options.Which, {'exec', 'all'})
        combined_mask = util.mask.op(nrs, pb.msk.deex_h, @intersect);
        for j = 1:length(combined_mask)
            i = combined_mask(j);
            plot(t, factor*trans(pb.deex_h(:,i)), ...
                "DisplayName", reastr(i));
        end
    end
    % h2c (this is the same as izh_cost_dnedt)
    % combined_mask = util.mask.op(nrs, pb.msk.h2c, @intersect);
    % for j = 1:length(combined_mask)
    %     i = combined_mask(j);
    %     plot(t, factor*trans(-pb.hot2cold(:,i)), ...
    %         "DisplayName", reastr(i) + " (hot $\rightarrow$ cold)");
    % end
end

hold off;

% Note: a nice idea would be to have gourp by type of reaction, i.e. change
% the line style / color accordingly

%% Formatting

% Set yaxis label according to options (absolute value, units)
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

if ~any(isnan(options.XLim))
    xlim(ax, options.XLim);
end
if ~any(isnan(options.YLim))
    ylim(ax, option.YLim);
end

legend(ax, 'Location', 'best');

end

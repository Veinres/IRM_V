function [fig] = reactions(output, input, species, options)
%REACTIONS plot the creation rates of a species though reaction
% =========================================================================
% The plot shows the rate at which a given species is consumed or produced
% individually for all reactions involving that species.
%
% See also plt.run.species.rates
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
    options.Mask (:,1) = []
    options.XLim (1,2) double = [NaN,NaN]
    options.YLim (1,2) double = [NaN,NaN]
    options.Which char {mustBeMember(options.Which, {'prod', 'react', 'net', 'any'})} = 'net'
    options.YScale char {mustBeMember(options.YScale, {'log', 'linear', 'auto'})} = 'auto'
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

if isempty(options.Colors)
    colors = colororder();
else
    colors = options.Colors;
end

trans = @(x) x;
if options.LogAbs
    trans = @abs;
end

t = output.t*1e+6;

i_spe = input.Spe.s.(species);

switch options.Which
    case 'prod'
        delta = input.Rea.P(:,i_spe).';
    case 'react'
        delta = input.Rea.R(:,i_spe).';
    case 'any'
        delta = input.Rea.P(:,i_spe).' | input.Rea.R(:,i_spe).';
    otherwise % 'net'
        delta = (input.Rea.P(:,i_spe)-input.Rea.R(:,i_spe)).';
end
msk = (delta).' ~= 0;
if isempty(options.Mask)
    n_reactions = length(input.Rea.Pcell);
    options.Mask = 1:n_reactions;
end
nrs = util.mask.op(options.Mask, msk, @intersect);
msk = util.mask.toLogical(nrs, [n_reactions,1]);
reaProd = delta.*output.Rate;

if ~any(msk)
    error("plt:run:species:reactions:emptySelection", ...
        "There are no reactions matching the selected criteria.\n" + ...
        "Suggestion: Setting 'Which' to 'any' will show all reactions involving a given species.");
end
[fig, ax] = util.fig.getAx(options.Parent);
plot(ax, t, trans(reaProd(:,msk)));
ax.ColorOrder = colors;
ax.LineStyleOrder = {'-','-.','--',':'};
ax.LineStyleCyclingMethod = 'withcolor';

% Note: a nice idea would be to have gourp by type of reaction, i.e. change
% the line style / color accordingly

xlabel('$t$ [$\rm \mu s$]');
switch options.Which
    case 'react'
        ylabel(ax, '$\frac{-{\rm d} n}{{\rm d} t}$ [$\rm m^{-3}\,s^{-1}$]');
    case 'any'
        ylabel(ax, '$R$ [$\rm m^{-3}\,s^{-1}$]');
    otherwise
        ylabel(ax, '$\frac{{\rm d} n}{{\rm d} t}$ [$\rm m^{-3}\,s^{-1}$]');
end

if options.LogAbs
    set(ax, 'YScale', 'log');
    ylabel(ax, '$\vert\frac{{\rm d} n}{{\rm d} t}\vert$ [$\rm m^{-3}\,s^{-1}$]');
else
    if strcmp(options.YScale, 'auto')
        if ~strcmp(options.Which, 'net')
            set(ax, 'YScale', 'log');
            ylim(ax, [1e+15,1e+25])
        end
    else
        set(ax, 'YScale', options.YScale);
    end
end

if ~options.ReaNr && ~options.ReaEq && ~options.ReaTag
    options.ReaNr = true;
end

reastr = material.util.reactions.stringReps( ...
    input.Rea.reactions, input.Spe, nrs, ...
    'ReaEqOpts', options.ReaEqOpts);
reastr(:, [options.ReaNr, options.ReaEq, options.ReaTag, options.ReaType]);
reastr = join(reastr, ' : ', 2);

legend(reastr);

if ~any(isnan(options.XLim))
    xlim(ax, options.XLim);
end
if ~any(isnan(options.YLim))
    ylim(ax, option.YLim);
end

end

function [fig] = rates(output, input, species, options)
%RATES plot the rates at which a given species is created/lost
% =========================================================================
% Splits the total change in number density of a species into the different
% contributions (crossing IR boundary a.k.a. "diffusion", kickout,
% sputtering and through reactions).
%
% See also plt.run.species.reactions
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
%   'SplitDiff' (logical, default=false), whether to split up the
%                   diffusion term. This is only possible for ions.
%                   - false : sum all
%                   - true  : split into BP and RT parts
%
%   'SplitRea'  (logical, default=false), whether to split up the reactions
%                   term.
%                   - false : net production through reactions
%                   - true  : total production and loss through reacitons
%
%   'PlotTotal' (logical, default=false), whether to also plot the total
%                   rate of change for the chosen species
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
    options.XLim (1,2) double = [NaN,NaN]
    options.YLim (1,2) double = [NaN,NaN]
    options.SplitDiff logical = false
    options.SplitRea logical = false
    options.PlotTotal logical = false
end

t = output.t*1e+6;
if ~isfield(output, 'Prod')
    output.Prod = output.Rate*input.Rea.P;
end
if ~isfield(output, 'React')
    output.React = -output.Rate*input.Rea.R;
end
if ~isfield(output, 'Net')
    output.Net = output.Rate*(input.Rea.P-input.Rea.R);
end

colors = colororder();
n_colors = size(colors,2);
line_styles = {'-','-.','--',':'};

[fig, ax] = util.fig.getAx(options.Parent);
hold on;

i_spe = input.Spe.s.(species);
i_c = 1+mod(i_spe-1,n_colors);
color = colors(i_c,:);

if options.SplitDiff && input.Spe.Q(i_spe) ~= 0 && ~strcmp(input.Spe.PSpecies{i_spe}, 'e')
    plot(ax, t, -input.Para.S_RT/input.Para.V_IR*output.GAMMA_ion_RT(:,i_spe), ...
        'Color', color, 'LineStyle', line_styles{1}, ...
        'Marker', '^', 'MarkerIndices', 1:20:length(t), 'MarkerSize', 7, ...
        'DisplayName', 'diff. to RT');
    plot(ax, t, -input.Para.S_BP/input.Para.V_IR*output.GAMMA_ion_BP(:,i_spe), ...
        'Color', color, 'LineStyle', line_styles{1}, ...
        'Marker', 'v', 'MarkerIndices', 1:20:length(t), 'MarkerSize', 7, ...
        'DisplayName', 'diff. to BP');
else
    plot(ax, t, -output.Diffrate(:,i_spe), ...
        'Color', color, 'LineStyle', line_styles{1}, ...
        'DisplayName', 'diffusion');
end
plot(ax, t, output.kickout(:,i_spe), ...
    'Color', color, 'LineStyle', line_styles{2}, ...
        'DisplayName', 'kickout');
plot(ax, t, output.sputrate(:,i_spe), ...
    'Color', color, 'LineStyle', line_styles{3}, ...
        'DisplayName', 'sputtering');
if options.SplitRea
    plot(ax, t, output.Prod(:,i_spe), ...
        'Color', color, 'LineStyle', line_styles{4}, ...
        'Marker', '^', 'MarkerIndices', 1:20:length(t), 'MarkerSize', 7, ...
        'DisplayName', 'prod. by rea.');
    plot(ax, t, output.React(:,i_spe), ...
        'Color', color, 'LineStyle', line_styles{4}, ...
        'Marker', 'v', 'MarkerIndices', 1:20:length(t), 'MarkerSize', 7, ...
        'DisplayName', 'cons. by rea.');
else
    plot(ax, t, output.Net(:,i_spe), ...
        'Color', color, 'LineStyle', line_styles{4}, ...
        'DisplayName', 'reactions');
end
if options.PlotTotal
    plot(ax, t, output.dndt(:,i_spe), ...
        'Color', color, 'LineStyle', line_styles{1}, ...
        'Marker', 's', 'MarkerIndices', 1:20:length(t), 'MarkerSize', 7, ...
        'DisplayName', 'total');
end

xlabel('$t$ [$\rm \mu s$]');
ylabel('$\frac{{\rm d} n}{{\rm d} t}$ [$\rm m^{-3}\,s^{-1}$]');

if ~any(isnan(options.XLim))
    xlim(ax, options.XLim);
end
if ~any(isnan(options.YLim))
    ylim(ax, option.YLim);
end

end

function [fig] = summary(output, input)
%SUMMARY create an overview plot of a run
% =========================================================================
% Creates an overview figure showing a plot of
%   - the current and current contributions
%   - the species densities
%   - the temperatures and densities of both electron populations
%   - the power balance for both electron populations
%
% ARGUMENTS ---------------------------------------------------------------
%
%   output      (struct), the output produced using rslt.run.output
%
%   input       (struct), the input used for the simulation run
%
% NAME-VALUE --------------------------------------------------------------
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

%%

fig = figure();
util.fig.maximise(fig);
tl = tiledlayout(fig, 2, 2, "TileSpacing", "compact");

ax = nexttile(tl);
plt.run.currents(output, input, "Parent", ax, ...
    "AutoXLim", false, "Exp", true);

ax = nexttile(tl);
plt.run.densities(output, input, "Parent", ax); %, ...
    % "Mask", ~ismember(input.Spe.Names, {'e', 'eh'}));
ax.Legend.NumColumns = 2;

ax = nexttile(tl);
plt.run.powerBalance(output, input, "Parent", ax);
ax.Legend.NumColumns = 2;

ax = nexttile(tl);
plt.run.electrons(output, input, "Parent", ax);

end

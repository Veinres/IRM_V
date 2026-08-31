function [fig] = current(results, outputs, inputs, options)
%CURRENT create a 3d stacked plot of the current waveforms
% =========================================================================
%
% ARGUMENTS ---------------------------------------------------------------
% The arguements need to have to correct form (as produced e.g. by
% results.collect()).
%
%   results     (table)
%   outputs     (table)
%   inputs      (table)
%
% NAME-VALUE --------------------------------------------------------------
%
%   'Title'     (char, default=''), title of the plot
%
%   'Primary'   (struct/string, default="f"), primary variable *
%
%   'Secondary' (struct/string, default="beta_t_p"), secondary variable *
%
%   'Tertiary'  (struct/string, default="r"), tertiary variable *
%
%   'xLim'      (double (1,2), default=[0,0]), x-axis limits
%
%   'Subsampling'(integer, default=10), reduce the number of displayed
%                   points. (Plot can get laggy if there are a lot of runs)
%
%   'maxRuns'   (integer, default=256), reduce the number of displayed runs
%                   (Plot can get laggy if there are a lot of runs)
%
%   (*) must be in {"f", "beta_t_p", "r"}
%
% RETURN ------------------------------------------------------------------
%
%   fig         (figure), plotted figure
%
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ NOTE ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This function requires Matlab 2019b or later.
% =========================================================================

%% NOTES: -----------------------------------------------------------------
% -------------------------------------------------------------------------

%% Argument validation
arguments
    results table
    outputs struct
    inputs struct
    options.Title char = []
    options.Primary = "f"
    options.Secondary = "beta_t_p"
    options.Tertiary = "r"
    options.xLim (1,2) double = [0,0]
    options.Subsampling (1,1) double = 10
    options.maxPVals (1,1) double = 10
end

argvars = {'Primary','Secondary','Tertiary'};
vars = {'pri','sec','ter'};
for i = 1:length(vars)
    if isa(options.(argvars{i}),"char") ||  isa(options.(argvars{i}),"string")
        switch options.(argvars{i})
            case "f"
                p.(vars{i}).var = 'f';
                p.(vars{i}).label = '$U_{\rm IR}/U_{\rm D}$';
            case "beta_t_p"
                p.(vars{i}).var = 'beta_t_p';
                p.(vars{i}).label = '$\beta_{\rm t,pulse}$';
            case "r"
                p.(vars{i}).var = 'r';
                p.(vars{i}).label = '$r$';
        end
    end
end
p.ter.ind = 1;

%% Perparation and filtering of results

for i = 1:length(vars)
    vals = unique(results.(p.(vars{i}).var), 'sorted');
    n_vals = length(vals);
    if length(vals) > 16
        msk = 1:ceil(n_vals/options.maxPVals):n_vals;
        if msk(end) ~= n_vals
            msk(end+1) = n_vals;
        end
        p.(vars{i}).vals = vals(msk);
    else
        p.(vars{i}).vals = vals;
    end
end
for i = 1:length(vars)
    p.(vars{i}).range = [min(p.(vars{i}).vals), max(p.(vars{i}).vals)];
end
reduced = results;
for i = 1:length(vars)
    reduced = reduced(ismember(reduced.(p.(vars{i}).var), p.(vars{i}).vals),:);
end
reduced = reduced(reduced.(p.ter.var) == p.ter.vals(p.ter.ind),:);


%% Plotting

fig = figure();
% Title
if ~isempty(options.Title)
    title(options.Title);
end
hold on;
% Plot the reconstructed current waveform
for i = 1:height(reduced)
    i_run = reduced.nr(i);
    plot3(1e+6*outputs.t{i_run}(1:options.Subsampling:end), ...
        reduced.(p.pri.var)(i)*ones(size(outputs.t{i_run}(1:options.Subsampling:end))), ...
        outputs.I_IRM{i_run}(1:options.Subsampling:end), ...
        'Color', (reduced.(p.sec.var)(i)-p.sec.range(1))/abs(diff(p.sec.range))*0.75*[1,1,1], ...
        'LineWidth', 1.5);
end
% Plot the measured current waveform
for i = 1:length(p.pri.vals)
    plot3(inputs.input.disch.T(1:options.Subsampling:end), ...
        p.pri.vals(i)*ones(size(inputs.input.disch.T(1:options.Subsampling:end))), ...
        inputs.input.disch.I(1:options.Subsampling:end), ...
        'Color', [0,0.4470,0.7410], 'LineWidth', 1.5);
end
fig.CurrentAxes.TickLabelInterpreter = 'LaTex';
fig.CurrentAxes.FontSize = 16;
xlabel('$t$ [$\mathrm{\mu s}$]', 'Interpreter', 'LaTex', 'FontSize', 20);
ylabel(p.pri.label, 'Interpreter', 'LaTex', 'FontSize', 20);
zlabel('$I_\mathrm{IRM}$ [A]', 'Interpreter', 'LaTex', 'FontSize', 20);
if diff(options.xLim) > 0
    xlim(options.xLim)
end
grid on;
box on;
view([-40,30]);
zlims = zlim();
zlims(2) = min(zlims(2), 3*max(inputs.input.disch.I));
zlim(zlims);

end

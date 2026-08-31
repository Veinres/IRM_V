function fig = cv(I, U, T, y_t, yaxis, label, pltArgs, options)
%CV plot a current/voltage waveform
% =========================================================================
% Plot current and voltage in one figure using two y-axis. Optionally plot
% the IRM reconstructed current waveform as well.
%
% ARGUMENTS ---------------------------------------------------------------
%
%   I           (double, (:,1)), the current waveform
%
%   U           (double, (:,1)), the voltage waveform
%
%   T           (double, (:,1)), the corresponding time array
%
% REPEATING ARGUMENTS -----------------------------------------------------
%
%   y_t         (double, (:,2)), additional curve
%                   1st collumn : time
%                   2nd collumn : value
%
%   yaxis       (char), which axis to plot on {'left', 'right'}
%
%   label       (char), legend string
%
%   pltArgs     (cell), Additional arguments for the plot function
%
% NAME-VALUE --------------------------------------------------------------
%
%   'Title'     (char), title for the figure
%
%   'Name'      (char), name of the figure
%
%   'I_fit'     (double, (:,2)), fitted current and time
%                   1st collumn : time
%                   2nd collumn : current
%
%   'xLim'      (double, (1,2)), x-axis limits
%
%   'MaxNTicks' (integer, default=0), maximum number of y ticks
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
    I (:,1) double
    U (:,1) double {util.valid.mustBeSameSize(U,I)}
    T (:,1) double {util.valid.mustBeSameSize(T,I)}
end
arguments (Repeating)
    y_t (:,2) double
    yaxis char {mustBeMember(yaxis, {'left', 'right'})}
    label char
    pltArgs cell
end
arguments
    options.Title char = ''
    options.Name char = ''
    options.I_fit (:,2) double = []
    options.xLim (1,2) double = [0,0]
    options.MaxTicks double {mustBeInteger, mustBeNonnegative} = 0
    options.MinTicks double {mustBeInteger, mustBeNonnegative} = 0
end

y_left = I;
if ~isempty(options.I_fit)
    y_left = [y_left; options.I_fit(:,2)];
end
y_right = U;
for i = 1:length(y_t)
    if strcmp(yaxis, 'right')
        y_right = [y_right; y_t{i}(:,2)];
    else
        y_left = [y_left; y_t{i}(:,2)];
    end
end

args = {};
if options.MaxTicks > 0
    args{end+1} = 'maxTicks';
    args{end+1} = options.MaxTicks;
end
if options.MinTicks > 0
    args{end+1} = 'minTicks';
    args{end+1} = options.MinTicks;
end
[yylims, ticks] = util.fig.yyTicks(y_left, y_right,...
    'forceOrigin', true, 'right', 'rev', ...
    args{:} ...
    );

if ~isempty(options.Name)
    fig = figure('Name',options.Name);
else
    fig = figure();
end
if ~isempty(options.Title)
    title(options.Title)
end
hold all;
grid on;
xlabel('$t$ [$\mu$s]');

yyaxis left;
h_I = plot(T, I);
if ~isempty(options.I_fit)
    h_Ifit = plot(options.I_fit(:,1), options.I_fit(:,2), ...
        '-.', 'Color', [0,0,0.5]);
end
ylabel('$I_{\rm D}$ [$\rm A$]');
ylim(yylims{1});
yticks(ticks{1});
if diff(options.xLim) > 0
    xlim(options.xLim);
end
set(gca,'Clipping','on');

yyaxis right;
h_U = plot(T, U);
ylim(yylims{2});
yticks(ticks{2});
ylabel('$V_{\rm D}$ [$\rm V$]');
set(gca, 'YDir', 'reverse');
if diff(options.xLim) > 0
    xlim(options.xLim);
end
set(gca,'Clipping','on');

if ~isempty(options.I_fit)
    legend([h_I,h_U,h_Ifit],{'$I_{\rm D}$','$U_{\rm D}$','$I_{\rm D,IRM}$'});
else
    legend([h_I,h_U],{'$I_{\rm D}$','$U_{\rm D}$'});
end

for i = 1:length(y_t)
    yyaxis(yaxis{i});
    plot(y_t{i}(:,1), y_t{i}(:,2), pltArgs{i}{:});
    fig.CurrentAxes.Legend.String{end} = label{i};
end

end

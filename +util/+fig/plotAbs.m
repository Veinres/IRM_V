function [h, h_all] = plotAbs(x, y, options)
%PLOTABS plot the absolute value with markers at the zero crossings
% =========================================================================
% Determines the location and direction of zero crossings, plots the
% absolute value using the plot function and adds markers at the crossings
% so that it can still be infered what parts of the graph are positive and
% negative.
%
% ARGUMENTS ---------------------------------------------------------------
%
%   x           ((:,1), double), x values
%
%   y           ((:,:), double), y values
%
% Name-Value Pairs --------------------------------------------------------
%
%   'Parent'    (figure or axes object), parent in which to plot
%
%   'pltArgs'   (cell), additional arguments that will be passed to the
%                   plot function
%
%   'Mark'      (logical, default='cross'), whether to mark the zero
%                       crossing directons
%                       - cross : use 'diamonds' to mark the crossing
%                                 only one graphics object is produced per
%                                 column of y
%                       - dir   : use '^' and 'v' to mark the direction
%                                 three graphics objects are produced per
%                                 column of y
%                       - none  : just plot without markings
%
%   'Colors'    (double (:,3)), colors to be used
%
% RETURN ------------------------------------------------------------------
%
%   h           ((:,1), handle to plotted lines
%
%   h_all       ((:,1), struct) handles to all produced graphics objects
%
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ NOTE ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This function requires Matlab 2019b or later.
% =========================================================================

%% NOTES: -----------------------------------------------------------------
% -------------------------------------------------------------------------

%% Argument parsing and validation
arguments
    x (:,1) double
    y (:,:) double {util.valid.mustBeSameSizeN(y,x,1)}
    options.Parent = []
    options.pltArgs cell = {}
    options.Mark char {mustBeMember(options.Mark, {'cross','dir','none'})} = 'cross'
    options.Colors (:,3) double = []
end

if ~isempty(options.Colors)
    colors = options.Colors;
else
    colors = colororder();
end
n_colors = size(colors, 1);
i_c = 1;

h = [];
h_all = {};

for i = 1:size(y,2)
    hold on;
    tmp = [0; diff(y(:,i) < 0)];
    i_up = find(tmp == +1);
    i_down = find(tmp == -1);
    i_c = 1 + mod(i_c, n_colors);
    color = colors(i_c,:);
    switch options.Mark
        case 'dir'
            h(i) = plot(x, abs(y(:,i)), 'Color', color, options.pltArgs{:});
            su = scatter(x(i_up), abs(y(i_up,i)), 50, 'Marker', '^', 'MarkerEdgeColor', color, 'MarkerFaceColor', color + 0.5*(1-color));
            sd = scatter(x(i_down), abs(y(i_down,i)), 50, 'Marker', 'v', 'MarkerEdgeColor', color, 'MarkerFaceColor', color + 0.5*(0-color));
            h_all{i} = struct('line', h(i), 'scatter_up', su, 'scatter_down', sd);
        case 'cross'
            h(i) = plot(x, abs(y(:,i)), ...
                'Marker', 'd', 'MarkerIndices', sort([i_up; i_down]), 'MarkerSize', 7, ...
                'Color', color, 'MarkerFaceColor', color + 0.5*(1-color), options.pltArgs{:});
            h_all{i} = struct('line', h(i), 'scatter_up', [], 'scatter_down', []);
        otherwise % 'none'
            h(i) = plot(x, abs(y(:,i)), ...
                'Color', color, options.pltArgs{:});
            h_all{i} = struct('line', h(i), 'scatter_up', [], 'scatter_down', []);
    end
end

end

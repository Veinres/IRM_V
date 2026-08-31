function cfun = interpColor(map, options)
%INTERPCOLOR create a colorscale interpolant
% =========================================================================
% Interpolate the rgb values of a colormap.
%
% ARGUMENTS ---------------------------------------------------------------
%
%   map         (char), name of the colormap to be used
%                   Any of the continuous matlab colormaps can be
%                   specified.
%                   When specifiying 'custom' the colormap supplied useing
%                   the 'ColorMap' Name-Value argument will be used.
%
% NAME-VALUE --------------------------------------------------------------
%
%   'Range'     (double (1,2), optional, default=[0,1]), considered range
%
%   'ColorMap'  (double (:,4), optional, default=[0,0,0,0;1,1,1,1]),
%                   custom colormap specified by an set of x and rgb values
%
%   'Method'    (char, optional, default='linear'), interpolation method
%                   accepts same values as griddedInterpolant
%
% RETURN ------------------------------------------------------------------
%
%   cfun        (function_handle), color interpolant
%
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ NOTE ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This function requires Matlab 2019b or later.
% =========================================================================

%% NOTES: -----------------------------------------------------------------
% -------------------------------------------------------------------------

%% Argument parsing and validation
arguments
    map char {mustBeMember(map, ...
        {'parula', 'jet', 'turbo', 'hsv', 'hot', 'cool', ...
        'spring', 'summer', 'autumn', 'winter', ...
        'gray', 'bone', 'copper', 'pink', ...
        'default', 'custom'})} = 'parula'
    options.Range (1,2) double = [0,1]
    options.ColorMap (:,4) double = [0, 0, 0, 0; 1, 1, 1, 1];
    options.Method char {mustBeMember(options.Method, ...
        {'linear', 'nearest', 'next', 'previous', ...
        'pchip', 'cubic', 'makima', 'spline'})} = 'linear'
end

% NOTE: -> caxis
if strcmp(map, 'custom')
    x = options.ColorMap(:,1);
    c = options.ColorMap(:,2:4);
else
    fig = figure();
    c = colormap(fig,map);
    close(fig);
    x = linspace(0,1,size(c, 1));
end
x_range = max(x)-min(x);
if x_range == 0
    error('util:fig:interpcolor:invalidCMapRange', ...
        "The range of the specified colormap is zero.");
end
x = (x - min(x))/x_range*(options.Range(2) - options.Range(1)) ...
    + options.Range(1);

[x, inds] = sort(x);
c = c(inds,:);

rgb = griddedInterpolant(x, c, options.Method, 'none');

cfun = @(x) rgb(reshape(x, [], 1));

end

function [fig, cm] = map(results, summary, metadata, options)
%MAP create a map of the parameter scan showing two quantities
% =========================================================================
% Show two variables from the metadata or results structure using a
% contourf plot (varaible 1) and a contour plot (variable 2).
%
% ARGUMENTS ---------------------------------------------------------------
% The arguements need to have to correct form (as produced e.g. by
% results.collect().
%
%   results     (table)
%   summary     (table)
%   metadata    (table)
%
% NAME-VALUE --------------------------------------------------------------
%
%   'Title'     (char, default=''), title of the plot
%
%   'V1'        (struct, default={var:'fom', label:'FOM'}), var 1 struct
%                   There are various possible fields that will be
%                   consiered:
%                   Mandatory fields:
%                       - var   : (char) variable name in metadata/results
%                       - label : (char) latex compatible variable label
%                   Optional fields:
%                       - trans : (function_handle, default=@(x) x)
%                                 Transformation to be applied to variable
%                                 values.
%                       - get   : (function_handle, default=@(tab,i)
%                                 v1.trans(tab.(v1.var)(i)))
%                                 Function to actually fetch the plotted
%                                 values. i is the index of a
%                                 point/simulation run and tab is the
%                                 joined metadata and results table.
%                                 By default, the value from the
%                                 corrsponding row and selected variable
%                                 from the results/metadata table is
%                                 fetched and the optional value
%                                 transformation is applied.
%                       - range : (double (1,2), default=[0,1]),
%                                 value range to plot
%                       - nlvls : (integer, default=101), number of levels
%                       - opts  : (cell), additional arguments that will be
%                                 passed to countourf
%
%   'V2'        (struct, default={var:'fom', label:'FOM'}), var 2 struct
%                   There are various possible fields that will be
%                   consiered. For the list of fields, see 'V1'.
%                       - nlvls : (integer, default=11)
%                       - opts  : (cell), additional arguments that will be
%                                 passed to countour
%
%   'V2lim'     (double (array), default=[]), the levels argument of
%                   countour
%
%   'Axes'      (axes, default=[]), parent axes to plot in
%
%   'MarkCnst'  (logical, default=true), mark constrained best fit
%
%   'MarkFree'  (logical, default=true), mark unconstrained best fit
%
% RETURN ------------------------------------------------------------------
%
%   fig         (figure), plotted figure
%
%   cm          (colormap), colormap associated with countourf plot
%
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ NOTE ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This function requires Matlab 2019b or later.
% =========================================================================

%% NOTES: -----------------------------------------------------------------
% -------------------------------------------------------------------------

%% Argument validation
arguments
    results table
    summary table
    metadata table
    options.Title char = []
    options.V1 = []
    options.V2 = []
    options.V2lim = [] % NOTE: might be redundant % FIXME
    options.X = [] % NOTE: unused % FIXME
    options.Y = [] % NOTE: unused % FIXME
    options.Z = [] % NOTE: unused % FIXME
    options.AdditionalVars = [] % FIXME
    options.Parent = []
    options.MarkCnst = true
    options.MarkFree = true
end

prop = join(results, metadata);

% colormap variable
if isstruct(options.V1)
    v1 = options.V1;
elseif (isstring(options.V1) || ischar(options.V1)) && ...
    ismember(char(options.V1), prop.Properties.VariableNames)
    v1.var = char(options.V1);
else
    v1.var = 'fom';
    v1.label = 'FOM';
end
if ~isfield(v1, 'trans')
    v1.trans = @(x) x;
end
if ~isfield(v1, 'get')
    v1.get = @(tab,i) v1.trans(tab.(v1.var)(i));
end
if ~isfield(v1, 'range')
    v1.range = [0,1];
end
if ~isfield(v1, 'nlvls')
    v1.nlvls = 101;
end
if ~isfield(v1, 'opts')
    v1.opts = {'EdgeColor', 'none'};
end
if ~isfield(v1, 'label')
    v1.label = options.V1;
end

% countour lines variable
if isstruct(options.V2)
    v2 = options.V2;
elseif (isstring(options.V2) || ischar(options.V2)) && ...
    ismember(char(options.V2), prop.Properties.VariableNames)
    v2.var = char(options.V2);
else
    v2.var = 'F_flx';
    v2.label = '$F_\mathrm{flux}$';
end
if ~isfield(v2, 'trans')
    v2.trans = @(x) x;
end
if ~isfield(v2, 'get')
    v2.get = @(tab, i) v2.trans(tab.(v2.var)(i));
end
if ~isfield(v2, 'range')
    v2.range = [0,1];
end
if ~isfield(v2, 'nlvls')
    v2.nlvls = 11;
end
if ~isfield(v2, 'opts')
    v2.opts = {'Color', 0.0*[1,1,1], 'LineWidth', 1};
end
if ~isfield(v2, 'label')
    v2.label = options.V2;
end

% default
% x-axis variable
p.x.var = 'beta_t_p';
p.x.label = '$\beta_{\rm t,pulse}$';
% y-axis variable
p.y.var = 'f';
p.y.label = '$U_{\rm IR}/U_{\rm D}$';
% constant variable
p.z.var = 'r';
p.z.label = '$r$';
p.z.ind = 1;

argvars = {'X','Y','Z'};
vars = {'x','y','z'};
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
    elseif isstruct(options.(argvars{i}))
        flds = fields(options.(argvars{i}));
        for j = 1:length(flds)
            p.(vars{i}).(flds{j}) = options.(argvars{i}).(flds{j});
        end
    end
end

%% Preparation and filtering of results

s.x(1) = summary.(p.x.var).cnst;
s.y(1) = summary.(p.y.var).cnst;
s.plt(1) = options.MarkCnst;
s.x(2) = summary.(p.x.var).free;
s.y(2) = summary.(p.y.var).free;
s.plt(2) = options.MarkFree;


for i = 1:length(vars)
    p.(vars{i}).vals = unique(prop.(p.(vars{i}).var), 'sorted');
end

prop = prop(prop.(p.z.var) == p.z.vals(p.z.ind),:);

v1.vals = nan([length(p.y.vals), length(p.x.vals)]);
v2.vals = nan([length(p.y.vals), length(p.x.vals)]);

for i = 1:height(prop)
    p.x.ind = find(p.x.vals == prop.(p.x.var)(i), 1, 'first');
    p.y.ind = find(p.y.vals == prop.(p.y.var)(i), 1, 'first');
    v1.vals(p.y.ind,p.x.ind)  = v1.get(prop, i);
    v2.vals(p.y.ind,p.x.ind)  = v2.get(prop, i);
end

%% Plotting

[fig, ax] = util.fig.getAx(options.Parent);
% Title
if ~isempty(options.Title)
    title(ax, options.Title);
end
% First variable for contour plot
contourf(ax, p.x.vals, p.y.vals, v1.vals, ...
    linspace(v1.range(1), v1.range(2), v1.nlvls), ...
    v1.opts{:});
cm = colormap(ax, flipud(colormap('parula')));
clim([v1.range(1),v1.range(2)]);
cb = colorbar(ax, 'Location','eastoutside');
cb.TickLabelInterpreter = 'LaTex';
cb.Label.String = v1.label;
cb.Label.Interpreter = 'LaTex';
cb.Label.FontSize = 20;
ax.TickLabelInterpreter = 'LaTex';
ax.FontSize = 16;
xlabel(ax, p.x.label, 'Interpreter', 'LaTex', 'FontSize', 20);
ylabel(ax, p.y.label, 'Interpreter', 'LaTex', 'FontSize', 20);
box on;
grid on;
% Second variable for contour plot
hold on;
[C,h] = contour(ax, p.x.vals, p.y.vals, v2.vals, ...
        linspace(v2.range(1), v2.range(2), v2.nlvls), ... 
        v2.opts{:});
clabel(C,h,'Color',0.0*[1,1,1],'FontWeight','bold');
subtitle(ax, sprintf("cont. : %s", v2.label), ...
    'Interpreter', 'LaTex', ...
    'FontSize', 20);
hold off;
% Second variable additional lines
if ~isempty(options.V2lim) && all(~isnan(options.V2lim))
    hold on;
    [C,h] = contour(ax, p.x.vals, p.y.vals, v2.vals, ...
            options.V2lim, ... 
            '-.','Color',[0.5,0,0]);
    clabel(C,h,'Color',[0.5,0,0],'FontWeight','bold');
    hold off;
end
% Scatter point
hold on;
marker = {'x','+'};
for i = 1:2
    if ~s.plt(i); continue; end
    plot(ax, s.x(i), s.y(i), ...
        'o', 'MarkerEdgeColor', [0.5,0,0], 'MarkerSize', 14, 'LineWidth', 1.5);
    plot(ax, s.x(i), s.y(i), ...
        marker{i}, 'MarkerEdgeColor', [0.5,0,0], 'MarkerSize', 14, 'LineWidth', 1.5);
end
hold off;

end

function [fig] = perSpeciesProperty(output, input, psp, options)
%PERSPECIESPROPERTY plot a time dependent per species property
% =========================================================================
% For available properties check which output fields have the one column
% per species.
%
% ARGUMENTS ---------------------------------------------------------------
%
%   output      (struct), the output produced using rslt.run.output
%
%   input       (struct), the input used for the simulation run
%
%   psp         (char), per species property name
%
% NAME-VALUE --------------------------------------------------------------
%
%   'Mask'      (logical (:,1) or double (:,1)), valid species index/mask
%
%   'Parent'    (figure or axes object), parent in which to plot
%
%   'YTrans'    (function handle), transformation to apply to y values
%
%   'XLim'      (double (1,2)), x axis limits
%                   By default the limits are not modified.
%
%   'YLim'      (double (1,2)), y axis limits
%                   By default the limits are not modified.
%
%   'XLabel'    (char), x axis label
%
%   'YLabel'    (char), y axis label
%
%   'LgndStrTrans'(function_handle), transformation applied to lgnd entries
%
%   'SpeciesColors'(double (:,3)), colors to be used for species
%
%   'GroupLineStyle'(string (:,1)), LineStyle to be used for species grp
%
%   'SpeciesLineSpec'(string (:,1)), LineSpec to be used for species
%
%   'SpeciesLineProp'(struct), line properties to be used for species,
%                   One field per species
%
%   'PltArgs'   (cell), additional arguments for `plot`
%
% RETURN ------------------------------------------------------------------
%
%   fig         (figure handle), plotted figure
%
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ NOTE ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This function requires Matlab 2019b or later.
% =========================================================================

%% NOTES: -----------------------------------------------------------------
% IDEA : maybe this would be better with a "composition" pattern
% NOTE : could replace the output struct with a the time array and a 2d
% arry for the actual property
% -------------------------------------------------------------------------

%% Argument parsing and validation
arguments
    output struct
    input struct
    psp char {mustBePerSpeciesProperty(psp, output)}
end
arguments
    options.Mask (:,1) = []
    options.Parent = []
    options.YTrans function_handle = @(x) x;
    options.XLim (1,2) double = [NaN,NaN]
    options.YLim (1,2) double = [NaN,NaN]
    options.XLabel char = ''
    options.YLabel char = ''
    options.SpeciesColors (:,3) double = []
    options.GroupLineStyle (:,1) string = []
    options.SpeciesLineSpec (:,1) string = []
    options.SpeciesLineProp struct = struct()
    options.LgndStrTrans function_handle = @(x) x;
    options.PltArgs cell = {}
end

n_species = length(input.Spe.Names);
spe_inds = 1:n_species;

[groups, ~, ic] = unique(input.Spe.PSpecies, 'stable');
grp_inds = zeros([1,n_species]);
if ~isempty(options.Mask)
    grp_inds(options.Mask) = ic(options.Mask);
else
    grp_inds = ic;
end

if ~isempty(options.GroupLineStyle)
    line_styles = cellstr(options.GroupLineStyle);
else
    line_styles = {'-','--',':','-.'};
end
n_line_styles = length(line_styles);

[fig, ax] = util.fig.getAx(options.Parent);
hold on;

if ~isempty(options.SpeciesColors)
    colors = options.SpeciesColors;
else
    colors = colororder();
end
n_colors = size(colors,1);

if ~isempty(options.SpeciesLineSpec)
    line_specs = cellstr(options.SpeciesLineSpec);
else
    line_specs = {'-'};
end
n_line_specs = length(line_specs);

% if ~isempty(fields(options.SpeciesLineProp))
%     line_props = util.struct.nameValue(options.SpeciesLineProp);
% else
%     line_props = {};
% end
% n_line_props = length(line_props);

%%

t = output.t*1e+6;

for i_grp = 1:length(groups)
    inds = spe_inds(grp_inds == i_grp);
    for i_gspe = 1:length(inds)
        ind = inds(i_gspe);
        if ~isempty(fields(options.SpeciesLineProp))
            % i_lp = 1+mod(ind-1, n_line_props);
            line_prop =  util.struct.nameValue(options.SpeciesLineProp.(input.Spe.Names{ind}));%line_props{i_lp};
        else
            i_c = 1+mod(ind-1,n_colors);
            i_ls = 1+mod(ind-1,n_line_specs);
            i_gls = 1+mod(i_grp-1,n_line_styles);
            line_prop = {
                line_specs{i_ls}, ...
                'LineStyle', line_styles{i_gls}, ...
                'Color', colors(i_c,:) ...
                };
        end
        plot(ax, t, options.YTrans(output.(psp)(:,ind)), ...
            line_prop{:}, ...
            'DisplayName', options.LgndStrTrans(input.Spe.List{ind}), ...
            options.PltArgs{:});
    end
end

legend(ax, 'Location', 'best');

if ~any(isnan(options.XLim))
    xlim(ax, options.XLim);
end
if ~any(isnan(options.YLim))
    ylim(ax, options.YLim);
end

if ~isempty(options.XLabel)
    xlabel(ax, options.XLabel);
end
if ~isempty(options.YLabel)
    ylabel(ax, options.YLabel);
end

end

function mustBePerSpeciesProperty(psp, output)
%MUSTBEPERSPECIESPROPERTY checks psp is a per species property in output
    n_species = size(output.n,2);
    if ~isfield(output, psp)
        eidType = 'mustBePerSpeciesProperty:notAOutputProperty';
        msgType = 'Input must correspond to a fieldname in output struct.';
        throwAsCaller(MException(eidType,msgType));
    end
    n_columns = size(output.(psp), 2);
    if n_columns ~= n_species && n_columns ~= n_species - 1
        eidType = 'mustBePerSpeciesProperty:notAPerSpeciesProperty';
        msgType = 'Selected property must have one column per species.';
        throwAsCaller(MException(eidType,msgType));
    end
end

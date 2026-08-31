function [yylims, yyticks] = yyTicks(yl, yr, options)
%YYTICKS suggest ticks for aligned plots using two y-axies
% =========================================================================
% Calculate a set of ticks for the right and left y-axis such that the
% number of ticks is equal and, if necessary, the origin of both axies are
% aligned while keeping vertical plot space useage optimal.
%
% ARGUMENTS ---------------------------------------------------------------
%
%   yl          ((:,1), double), values (or extremal values) of curves to
%                   be plotted on left axis
%
%   yr          ((:,1), double), values (or extremal values) of curves to
%                   be plotted on right axis
% 
% Name-Value Pairs --------------------------------------------------------
%
%   'margin'        double, minimum top/bottom margin to border expressed
%                       as fraction of curve range (e.g. 0.05=5% margin)
%
%   'left'          char, reverse left axis if 'rev'
%   'right'         char, reverse right axis if 'rev'
%
%   'forceOrigin'   logical, true -> force ticks to include y=0
%   'exactOrigin'   logical, true -> place y=0 at top or bottom if possible
%
%   'minTicks'      integer, minimum number of ticks
%   'maxTicks'      integer, maximum number of ticks
%
% RETURN ------------------------------------------------------------------
%
%   yylims      ((2,1), cell of (2,1) double), suggested ylims
%                   (1 is left, 2 is right) 
%
%   yyticks     ((2,1), cell of (:,1) double), suggested yticks
%                   (1 is left, 2 is right)
%
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ NOTE ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This function requires Matlab 2019b or later.
% =========================================================================

%% NOTES: -----------------------------------------------------------------
% TODO: investigate edge case where one or both functions don't cross but
% meet origin
% -------------------------------------------------------------------------

%% Argument parsing and validation
arguments
    % Positional arguments
    yl                  (:,1) double
    yr                  (:,1) double
    % Name-Value pairs
    options.margin      double = 0.00
    options.left        char = 'normal'
    options.right       char = 'normal'
    options.forceOrigin logical = false
    options.exactOrigin logical = false
    options.minTicks    {mustBeInteger, mustBePositive} = 5
    options.maxTicks    {mustBeInteger, mustBePositive} = 10
end

% index definitions for better readability
left_ = 1; % left axis
right_ = 2; % right axis

% unpack options
margin = options.margin;
force_origin = options.forceOrigin;
exact_origin = options.exactOrigin;
min_ticks = options.minTicks;
max_ticks = max(options.maxTicks, min_ticks);
reverse(left_) = any(strcmp(options.left,{'rev','reverse','reversed'}));
reverse(right_) = any(strcmp(options.right,{'rev','reverse','reversed'}));

%% Set-Up

% pack y-data
y = cell(2,1);
y{left_} = reshape(yl,[numel(yl),1]);
y{right_} = reshape(yr,[numel(yr),1]);

%% Tick and plot limit calculation algorithm

% 0a. flip values in case of reversed y-axis
for ax_ = left_:right_
    if reverse(ax_)
        y{ax_} = -y{ax_};
    end
end
% 1. add margin to left and right axis curves and get extremal values
margin = 1. + margin;
y_ext = cell(2,1);
for ax_=left_:right_
    y_ext{ax_} = margin*[min(y{ax_}), max(y{ax_})];
end
% 1a. Check if the values are crossing the origin and add virtual min/max
cross_origin = zeros(2,1);
for ax_ = left_:right_
    cross_origin(ax_) = prod(sign(y_ext{ax_})) < 0;
end
total_ticks_only = false;
if cross_origin(left_)+cross_origin(right_) < 2
    if force_origin
        for ax_ = left_:right_
            if ~cross_origin(ax_)
                [~,i] = min(abs(y_ext{ax_}));
                if exact_origin && cross_origin(left_)+cross_origin(right_) < 1
                    y_ext{ax_}(i) = 0.;
                    total_ticks_only = true;
                else
                    y_ext{ax_}(i) = -1e-3*abs(diff(y_ext{ax_}))*sign(y_ext{ax_}(i));
                end
            end
        end
    else
        total_ticks_only = true;
    end
end
% 2. find suggested divisions for left and right axis
int_bounds = cell(2,1);
divs = cell(2,1);
for ax_ = left_:right_
    [int_bounds{ax_}, divs{ax_}] = suggest_divs(y_ext{ax_}(1), y_ext{ax_}(2));
end
if ~total_ticks_only
% 3. get amount of axis adjustement needed per left-right division
% combination
    lower_int_bound = min(int_bounds{left_}(:,1), int_bounds{right_}(:,1).');
    upper_int_bound = max(int_bounds{left_}(:,2), int_bounds{right_}(:,2).');
    int_bound_range = upper_int_bound - lower_int_bound;
else
% 3a. get total number of ticks/divisions
    n_ticks = cell(2,1);
    for ax_ = left_:right_
        n_ticks{ax_} = abs(int_bounds{ax_}(:,2) - int_bounds{ax_}(:,1));
    end
    int_bound_range = max(n_ticks{left_}, n_ticks{right_}.');
end
% 4. find range coverage with adjusted bounds
range = zeros(2,1);
for ax_ = left_:right_
    range(ax_) = abs(diff(y_ext{ax_}));
end
coverage{left_} = range(left_)./(divs{left_}.*int_bound_range);
coverage{right_} = range(right_)./((divs{right_}.').*int_bound_range);
% 5. find and pick option with best relative coverage
[val, inds] = max(coverage{left_}.*coverage{right_},[],1);
[~, ind(right_)] = max(val);
ind(left_) = inds(ind(right_));
% 6. calculate ticks and bounds
ticks = cell(2,1);
if ~total_ticks_only
    for ax_ = left_:right_
        ticks{ax_} = divs{ax_}(ind(ax_))*...
            (lower_int_bound(ind(left_),ind(right_)):1:upper_int_bound(ind(left_),ind(right_)));
    end
else
    for ax_ = left_:right_
        ticks{ax_} = divs{ax_}(ind(ax_))*...
            (int_bounds{ax_}(ind(ax_),1):1:int_bounds{ax_}(ind(ax_),2));
    end
    ntickdiff = length(ticks{left_}) - length(ticks{right_});
    topadd = floor(abs(ntickdiff)/2);
    bottomadd = abs(ntickdiff) - topadd;
    if ntickdiff > 0
        ax_ = right_;
    elseif ntickdiff < 0
        ax_ = left_;
    end
    if bottomadd > 0
        ticks{ax_} = [ticks{ax_}(1)-(1:bottomadd)*divs{ax_}(ind(ax_)), ticks{ax_}];
    end
    if topadd > 0
        ticks{ax_} = [ticks{ax_}, ticks{ax_}(end)+(1:topadd)*divs{ax_}(ind(ax_))];
    end
end
ylims = cell(2,1);
for ax_ = left_:right_
    ylims{ax_} = [ticks{ax_}(1) ticks{ax_}(end)];
end
% 7. if necessary, remove some tick to make it less crowded or add some
% ticks to make it less sparse
while length(ticks{1}) > max_ticks && length(ticks{1}) > 2*min_ticks+1
    ind = 0;
    if prod(sign(ylims{left_})) < 0
        ind = find(ticks{left_} == 0.);
    elseif prod(sign(ylims{right_})) < 0
        ind = find(ticks{right_} == 0.);
    end
    if ind > 0
        for ax_ = left_:right_
            ticks{ax_} = [flip(ticks{ax_}(ind-2:-2:1)), ticks{ax_}(ind:2:end)];
        end
    else
        for ax_ = left_:right_
            ticks{ax_} = ticks{ax_}(1:2:end);
        end
    end
end
while length(ticks{1}) < min(min_ticks, floor(max_ticks/2))
    for ax_ = left_:right_
        tmp = ticks{ax_};
        ticks{ax_} = zeros(1,length(tmp)*2-1);
        ticks{ax_}(1:2:end) = tmp;
        for i = 0:(length(tmp)-2)
            ind = 2 + i*2;
            ticks{ax_}(ind) = 0.5*ticks{ax_}(ind+1)+0.5*ticks{ax_}(ind-1);
        end
    end    
end
% 8. flip values back in case of reversed y-axis
for ax_ = left_:right_
    if reverse(ax_)
        y{ax_} = -y{ax_};
        ylims{ax_} = flip(-ylims{ax_});
        ticks{ax_} = flip(-ticks{ax_});
    end
end

yyticks = ticks;
yylims = ylims;

end

function [ibounds, divs] = suggest_divs(y1, y2, force_origin)
%SUGGEST_DIVS suggest possible "nice" tick spacings

    if ~exist('force_origin','var')
        force_origin = false;
    end

    y_range = abs(y2-y1);
    y_order = 10^ceil(log10(y_range));

    n_divs = [2,4,5,8,10,20,40,50,80,100];
    y_divs = y_order./n_divs;

    y_min = min(y1,y2);
    y_max = max(y1,y2);

    if sign(y_min)*sign(y_max) > 0 && force_origin
        if sign(y_min) < 0
            y_max = 0.;
        else
            y_min = 0.;
        end
    end

    ibounds = zeros(2,length(n_divs));

    ibounds(1,:) = floor(y_min./y_divs);
    ibounds(2,:) = ceil(y_max./y_divs);

    ibounds = ibounds.';
    divs = y_divs.';
end

function aos = soa2aos(soa, options)
%SOA2AOS Create an array of structures from a structure of arrays
% =========================================================================
% Convert a structure of arrays into a array of structures.
% A prefered size can be specified but is not guaranteed to be taken into
% account.
%
% This procedure would be rather complicated in the general case. Therefore
% instead of treating every case possible, there are fallbacks to a simpler
% conversion if some criterions are not met.
%
% There are several possibilities:
%
% 1) The common dimensions are a) next to each other, are b) either the
%    innermost or outermost dimensions and c) appear in the same order for
%    all fields,
%    e.g.:
%       S.A a 3x4x4x10x2 array
%       S.B a 5x3x4x4 array
%       S.C a 2x5x3x4x4 array
%    then S (1x1 struct) will be converted to a struct whose size
%    corresponds to the common dimensions of the fields. In the above
%    example this would result in a struct of size 3x4x4 with fields
%       S(i).A a 10x2 array
%       S(i).B a 5x1 array
%       S(i).C a 2x5 array
%
% 2) If condition a) and b) are met, but not condition c), common
%    dimensions with equal length will be rejected. If the remaining common
%    dimensions still satisfy condition a) and b), the conversion will
%    procede as in case 1). E.g.:
%       S.A a 3x2x4x4x10 array
%       S.B a 5x4x4x3x2 array
%       S.C a 2x3x4x4x5 array
%    will be converted into a 3x2 struct with fields
%       S(i).A a 4x4x10 array
%       S(i).B a 5x4x4 array
%       S(i).C a 4x4x5 array
%    If conditions a) and b) are not satisfied anymore, the routine will
%    fallback to case 3.
%
% 3) If condition a) and b) are not satisfied, the only the largest unique,
%    common dimension will be taken into account. E.g.:
%       S.A a 3x2x4x4x10 array
%       S.B a 5x4x4x3x2 array
%       S.C a 4x2x3x4x5 array
%    will be converted into a 3x1 struct with fields
%       S(i).A a 2x4x4x10 array
%       S(i).B a 5x4x4x2 array
%       S(i).C a 4x2x4x5 array
%
% 4) If soa isn't a scalar structure, the procedure will produce an error.
%
% 5) If soa is empty, the procedure will give a warning and do nothing.
%
% ARGUMENTS ---------------------------------------------------------------
%
%   soa         (struct), structure of arrays
%
% NAME-VALUE --------------------------------------------------------------
%
%   'Size'      (integer), prefered size of struct array (aos)
%                   Not guaranteed.
%
% Return ------------------------------------------------------------------
%
%   aos         (struct), Array of structures
%
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ NOTE ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This function requires Matlab R2019b or later.
% =========================================================================

%% NOTES: -----------------------------------------------------------------
% TODO: implement user preferred size
% TODO: allow duplicates if order is unique:
%   e.g. : {[2,2,4,2,3], [1,3,4,2,3]} -> [4,2,3] x {[2,2], [1,3]}
% NOTE: works as descibed above, but unsure whether this way is actually
% useful -> TODO: improve procedure on how to select dimensions etc.
% -------------------------------------------------------------------------

%% Argument parsing and validation
arguments
    soa     struct {mustBeScalarOrEmpty}
    options.Size (1,:) double = []
end

if isempty(soa)
    warning('Structure of arrays is empty. Doing nothing.');
    aos = soa;
    return;
end

flds = fields(soa);
n_flds = length(flds);
fld_szs = cellfun(@(x) size(soa.(x)), flds, 'UniformOutput', false);

%% Determine aos size

% 1. find dimensions that are the same for all fields (ignoring order)
common_sz = common_dimensions(soa, flds, n_flds);

% 2. check conditions and decide on procedure to use
[cond_a, cond_b, cond_c] = check_conditions(flds, n_flds, fld_szs, common_sz);

if ~( cond_a && cond_b )
    % only consider largest dimension of unique size
    procedure = 3;
else
    if ~cond_c && length(unique(common_sz)) ~= length(common_sz)
        common_sz = remove_nonunique(common_sz);
        [cond_a, cond_b] = check_conditions(flds, n_flds, fld_szs, common_sz);
        if cond_a && cond_b
            % expand only unique common dimensions
            procedure = 2;
        else
            % fallback
            procedure = 3;
        end
    else
        % expand all common dimensions
        procedure = 1;
    end
end

% 3. prepare dimension arrays for selecting dimensions of each field
switch procedure
    case 1
        dims = zeros([n_flds, length(common_sz)]);
        for i = 1:n_flds
            ind = find(fld_szs{i}==common_sz(1), 1, 'first');
            dims(i,:) = ind:ind+length(common_sz)-1; % for procedure 1, all are consecutive and have same order
        end
    case 2
        dims = zeros([n_flds, length(common_sz)]);
        for i = 1:n_flds
            for j = 1:length(common_sz)
                dims(i,j) = find(fld_szs{i}==common_sz(j), 1, 'first');
            end
        end
    otherwise
        dims = zeros([n_flds, 1]);
        common_sz = max(remove_nonunique(common_sz));
        for i = 1:n_flds
            dims(i,1) = find(fld_szs{i}==common_sz(1), 1, 'first');
        end
end

% % TODO: implement
% % 4. consider user preferred size
% if ~isempty(options.Size)
%     % Use the dimensions specified in options.Size if it only differs in
%     % order (only if allowed if dims are unique) and/or singleton dimensions
%     % from the determined common_sz.
%     % Subsets are also allowed if the dimensions are unique.
%     if all(arrayfun(@(x) sum(common_sz == x) == 1, options.Size)) % all user specified dims are unique
%         tmp_common_sz = sort(common_sz(common_sz ~= 1));
%         tmp_usr_sz = sort(options.Size(options.Size ~= 1));
%     end
% end

%% Construction of Array of Structures

% 5. set up array of structures
size_cell = num2cell(common_sz);
if length(size_cell) == 1
    size_cell = horzcat(size_cell, 1);
end
aos(size_cell{:}) = struct(); % create a structure array of size 'size_cell'

% 6. fill fields
nelem = numel(aos);
inds = cell([1, length(common_sz)]);
for i_f = 1:n_flds    
    msk = repmat({':'}, [1,length(fld_szs{i_f})]);
    for i = 1:nelem
        [inds{:}] = ind2sub(common_sz, i);
        for j = 1:length(inds)
            msk{dims(i_f,j)} = inds{j};
        end
        aos(i).(flds{i_f}) = squeeze(soa.(flds{i_f})(msk{:}));
    end
end

end

%% Function definitions

function [common_sz] = common_dimensions(soa, flds, n_flds)
%COMMON_DIMESNIONS find entries in size(field) which are the same for all fields

    % basically intersection of sets with repetition:
    % 1. get size of first field
    % 2. compare with all other fields one after the other. If a dimension
    %    does not appear in both, reject it.
    % 3. the remaining dimensions are shared by all fields

    common_sz = size(soa.(flds{1})); % final list of common dimensions
    for i_f = 2:n_flds
        sz = size(soa.(flds{i_f})); % list of dimensions to check against
        for i = 1:length(common_sz)
            ind = find(sz == common_sz(i),1);
            if ind
                % ind > 0 -> found element -> keep it but remove it from sz in
                % order for it not to be considered again
                sz = [sz(1:ind-1),sz(ind+1:end)];
            else
                % ind == 0 -> element not present -> reject it
                common_sz(i) = 0;
            end
        end
        common_sz = common_sz(common_sz>0); % remove rejected elements
    end
end

function [cond_a, cond_b, cond_c] = check_conditions(flds, n_flds, fld_szs, common_sz)
%CHECK_CONDITIONS check the conditions listed in the documentation

    % Conditions:
    % The common dimensions are
    % a) next to each other
    % b) either the innermost or outermost dimensions
    % c) appear in the same order for all fields

    cond_a = true; % no gaps
    cond_b = true; % inner or outermost
    cond_c = true; % same order

    % get order of appearance
    order = zeros(length(common_sz), n_flds);
    for i_f = 1:n_flds
        sz = fld_szs{i_f};
        order(:,i_f) = find_order(sz, common_sz);
    end
    sorted = sort(order,1);

    % check a) (gaps)
    for i_f = 1:n_flds
        tmp = sorted(2:end,i_f) - sorted(1:end-1,i_f);
        if cond_a && any(tmp ~= 1)
            cond_a = false;
            break;
        end
    end
    % check b) (start/end)
    for i_f = 1:n_flds
        ln_fld_sz = length(fld_szs{i_f});
        if cond_b && ~( max(sorted(:,i_f))==ln_fld_sz || min(sorted(:,i_f))==1 )
            cond_b = false;
            break;
        end
    end
    % check c) (same order)
    order(:,1) = order(:,1) - min(order(:,1));
    for i_f = 2:n_flds
        order(:,i_f) = order(:,i_f) - min(order(:,i_f));
        if ~all(order(:,i_f) == order(:,1))
            cond_c = false;
            break;
        end
    end
end

% function [inds] = find_order(sz, common_sz)
% %FIND_ORDER find indicies such that sz(indicies) == common_sz
% % e.g. if common_sz = [3,5,4] and sz = [5,3,4] then indecies = [2,1,3]
% % NOTE : IMPORTANT : If possible, return solution without gap
% 
%     inds = zeros(size(common_sz));
%     for i = 1:length(sz)
%         for j = 1:length(common_sz)
%             if sz(i) == common_sz(j)
%                 common_sz(j) = -1; % exclude from further consideration
%                 inds(j) = i;
%                 break;
%             end
%         end
%     end
% end

function [indecies] = find_order(sz, common_sz)
%FIND_ORDER find indicies such that sz(indecies) == common_sz
% e.g. if common_sz = [3,5,4] and sz = [5,3,4] then indecies = [2,1,3]
% NOTE : IMPORTANT : If possible, return solution without gap
% if there is no such solution, it's not important since non-unique
% dimensions willl be rejected anyway

    uni = unique(common_sz);
    inds = cell(size(uni));
    ns = zeros(size(uni));
    for i = 1:length(uni)
        ns(i) = sum(common_sz == uni(i));
        inds{i} = zeros([1, ns(i)]);
    end

    len = 0;

    push = @(x, a) [x(2:end), a];

    for i = 1:length(sz)
        ind = find(sz(i) == uni, 1, 'first');
        if ind
            inds{ind} = push(inds{ind}, i);
            len = len + 1;
        else
            len = 0;
        end
        if len == length(common_sz)
            break;
        end
    end
    
    pop = @(x) deal(x(1:end-1), x(end));

    indecies = zeros(size(common_sz));
    for i = 1:length(common_sz)
        j = find(uni == common_sz(i), 1, 'first');
        [inds{j}, indecies(i)] = pop(inds{j});
    end
end

function [unique_sz] = remove_nonunique(common_sz)
%REMOVE_NONUNIQUE remove elements that appear more tha once

    unique_sz = [];
    for i = 1:length(common_sz)
        if sum(common_sz == common_sz(i)) < 2
            unique_sz(end+1) = common_sz(i);
        end
    end
end

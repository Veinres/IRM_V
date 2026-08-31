function padded = padColumns(tab, cols, lens)
%UTIL.BASE.PADCOLUMNS pad variable to a given length
% =========================================================================
% Pad variables <cols> to length <len>. Numeric variables are padded with
% zeros and cell arrays with ''.
% ARGUMENTS ---------------------------------------------------------------
%
%   tab     (cell array/table), cell array or table to be adapted
%
%   cols    (integer array/ string/char array cell, optional), columns to
%               be padded
%               - integers correspond to column number
%               - for tables, variable names can be specified as well
%               - if none are specified, all will be padded to the maximum
%               number already present.
%
%   lens    (integer array, optional), length (number of entries) to which
%               each column should be padded. If none is specified, columns
%               will be padded to the maximum number already present.
%
% RETURN ------------------------------------------------------------------
%
%   padded  (cell array/table), cell array or table with padded entries
%
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ NOTE ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This function requires Matlab 2019b or later.
% =========================================================================

%% NOTES: -----------------------------------------------------------------
% TODO : CLEANUP : this is pretty messy because of different indexing
% -------------------------------------------------------------------------

%% Argument parsing and validation
arguments
    % positional arguments
    tab      
    cols     = []
    lens     double {mustBeInteger} = []
end

padded = tab;

switch class(tab)
    case 'table'
        % check if cols is specified as variable names and convert if
        % necessary
        if ~isempty(cols) && ~isnumeric(cols)
            cols = varname2ind(tab, cols);
        end
    case 'cell'
        if ~isempty(cols) && ~isnumeric(cols)
            error('For cell arrays columns must be specified using an array of integers.')
        end
    otherwise
        error('Data type not supported. Supported data types are cell arrays and tables.')
end

n_col = size(padded);
n_row = n_col(1);
n_col = n_col(2);

% pad all columns if none were specified
if isempty(cols)
    cols = 1:n_col;
end

% specify lengths to which columns should be padded
% -1 means padding to maximum number already present
lns = zeros([1,length(cols)]) - 1;
if ~isempty(lens)
    % if cols is larger than lens, remaining entries will be padded to the
    % maximum number already present
    lns(1:length(lens)) = lens;
end
lens = lns;

cellofcell = zeros(size(cols));
cellofnum = zeros(size(cols));

%% Pad columns

for i_col = 1:length(cols)
    col = cols(i_col);
    if col > n_col || col < 1
        warning("Column %i outside bounds. Skipped.",col);
        continue;
    end
    % determine type
    cellofcell(i_col) = iscell(padded{1,col}) && iscell(padded{1,col}{1});
    cellofnum(i_col) = iscell(padded{1,col}) && isnumeric(padded{1,col}{1});
    % NOTE: sadly tables put cell arrays into cell arrays, which requires a
    % bit of an ugly workaround when indexing
    if lens(i_col) < 0 % -> determine length from max length
        mx = 0;
        if cellofcell(i_col) || cellofnum(i_col)
            % cell array in table
            for row = 1:n_row
                mx = max(mx, length(padded{row,col}{1}));
            end
        else
            % all else
            for row = 1:n_row
                mx = max(mx, length(padded{row,col}));
            end
        end
        lens(i_col) = mx;
    end
    if cellofcell(i_col)
        % cell array in table
        for row = 1:n_row
            len = length(padded{row,col}{1});
            if len < lens(i_col)
                if isnumeric(padded{row,col}{1})
                    tmp = zeros([1,lens(i_col)]);
                    tmp(1:len) = padded{row,col}{1};
                    padded{row,col}{1} = tmp;
                elseif iscell(padded{row,col}{1})
                    tmp = cell([1,lens(i_col)]);
                    tmp(1:len) = padded{row,col}{1};
                    for j=len+1:lens(i_col)
                        tmp{j} = '';
                    end
                    padded{row,col}{1} = tmp;
                else
                    warning("Column %i type not supported. Skipped.",col);
                    break;                
                end
            end
        end
        if istable(padded)
            padded.(padded.Properties.VariableNames{col}) = vertcat(padded{:,col}{:});
        end
    elseif cellofnum(i_col)
        % array in table
        for row = 1:n_row
            len = length(padded{row,col}{1});
            if len < lens(i_col)
                if isnumeric(padded{row,col}{1})
                    tmp = zeros([1,lens(i_col)]);
                    tmp(1:len) = padded{row,col}{1};
                    padded{row,col}{1} = tmp;
                elseif iscell(padded{row,col}{1})
                    tmp = cell([1,lens(i_col)]);
                    tmp(1:len) = padded{row,col}{1};
                    for j=len+1:lens(i_col)
                        tmp{j} = '';
                    end
                    padded{row,col}{1} = tmp;
                else
                    warning("Column %i type not supported. Skipped.",col);
                    break;                
                end
            end
        end
        if istable(padded)
            padded.(padded.Properties.VariableNames{col}) = vertcat(padded{:,col}{:});
        end
    else
        % all else
        for row = 1:n_row
            len = length(padded{row,col});
            if len < lens(i_col)
                if isnumeric(padded{row,col})
                    tmp = zeros([1,lens(i_col)]);
                    tmp(1:len) = padded{row,col};
                    padded{row,col} = tmp;
                elseif iscell(padded{row,col})
                    tmp = cell([1,lens(i_col)]);
                    tmp{1:len} = padded{row,col};
                    for j=len+1:lens(i_col)
                        tmp{j} = '';
                    end
                    padded{row,col} = tmp;
                else
                    warning("Column %i type not supported. Skipped.",col);
                    break;                
                end
            end
        end
    end
end

end

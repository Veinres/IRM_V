function [s] = enumStruct(fields, options)
%ENUMSTRUCT create an enumeration structure
% =========================================================================
% Create a structure with fields given by <fields> whos values correspond
% to their index in the cell array of strings/char arrays <fields>.
% If <fields> contains identical entries, the index of the first will be
% selected.
%
% E.g. `util.base.enumStruct({'a', 'b', 'c'})` returns a struct with fields
%   a: 1, b: 2, c: 3
%
% ARGUMENTS ---------------------------------------------------------------
%
%   fields      ((1,:), cell of strings/char arrays), Fields to enumerate
%
% Name-Value --------------------------------------------------------------
%
%   'Order'     (string, optional, default='stable') order of fields
%                   - 'stable'      Fields are in order of appearance
%                   - 'sorted'      Fields are lexicographically sorted
%
%   'Dir'       (string, optional, default='first') whether to pick the
%                                   first or last occurance
%                   - 'first'       Indecies correspond to first occurance
%                   - 'last'        Indecies correspond to last occurance
%
% RETURN ------------------------------------------------------------------
%
%   s           (structure), enumeration structure with fields in <fields>
%
% =========================================================================
% This function requires Matlab 2020b or later.
% =========================================================================

%% NOTES: -----------------------------------------------------------------

% -------------------------------------------------------------------------

%% Argument parsing and validation
arguments
    % positional arguments
    fields          {mustBeText}
    % optional name-value pairs
    options.Order   char {mustBeMember(options.Order,{...
                                'sorted',...        % lexicographically sorted
                                'stable',...        % in order of appearance
                                })} = 'stable'
    options.Dir     char {mustBeMember(options.Dir,{...
                                'first',...         % use first appearance
                                'last',...          % use last appearance
                                })} = 'first'
end

%% Enum Struct ------------------------------------------------------------

    if strcmp(options.Dir, 'last') && strcmp(options.Order, 'stable')
        fields = flip(fields);
        [u_fields, ia, ~] = unique(fields, 'stable');
        u_fields = flip(u_fields);
        ia = flip(length(fields) + 1 - ia);
    elseif strcmp(options.Dir, 'last')
        [u_fields, ia, ~] = unique(fields, 'last');
    elseif strcmp(options.Order, 'stable')
        [u_fields, ia, ~] = unique(fields, 'stable');
    else
        [u_fields, ia, ~] = unique(fields);
    end

    enum = mat2cell(ia, ones([1,length(ia)]));
    s = cell2struct(enum, u_fields, 1);
end

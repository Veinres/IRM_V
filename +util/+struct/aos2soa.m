function soa = aos2soa(aos, options)
%SOA2AOS Create a structure of arrays from an array of structures
% =========================================================================
% Convert a array of structures into a structure of arrays.
% If the original fields aren't scalar, different options on how to
% integrate them into the new fields are possible.
%
% ARGUMENTS ---------------------------------------------------------------
%
%   aos         (struct), Array of Structures
%
% Name-Value --------------------------------------------------------------
%
%   'Integration'   (char, optional, default: 'inner'), integrate arrays
%                       by:
%                       - 'nested' -> using nested cell arrays
%                       - 'inner' -> extending dimensionality at left side
%                       - 'outer' -> extending dimensionality at right side
%
% Return ------------------------------------------------------------------
%
%   soa         (struct), Structure of Arrays
%
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ NOTE ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This function requires Matlab R2019b or later.
% =========================================================================

%% NOTES: -----------------------------------------------------------------
% - should support most data types (all of which an array can be created),
% but has only been tested for numeric, cell, string, table and struct
% -------------------------------------------------------------------------

%% Argument parsing and validation

arguments
    aos                 struct
    options.Integration char {mustBeMember(options.Integration,...
                              {'nested','inner','outer'})} = 'inner'
end

if isempty(aos)
    warning('Array of structures is empty. Doing nothing.');
    soa = aos;
    return;
end

type_blacklist = {'table'}; % types that cannot be stored in regular arrays

aos_sz = size(aos);

flds = fields(aos(1));
n_flds = length(flds);
aos_nelem = numel(aos);

%% Construction of Structure of Arrays

soa = struct();
% NOTE : linear indexing is used to simplify the code
for j = 1:n_flds
    if ~strcmp(options.Integration,'nested') && ...
            consistent_size({aos(:).(flds{j})}) && ...
            ~ismember(class(aos(1).(flds{j})), type_blacklist)
        % put everything in one large array by extending the
        % dimensionality.
        fld_sz = size(aos(1).(flds{j}));
        nelem = prod(fld_sz);
        if strcmp(options.Integration,'outer')
            new_fld_sz = num2cell([aos_sz, fld_sz]);
            soa.(flds{j})(new_fld_sz{:}) = aos(end).(flds{j})(end);
            for i = 1:aos_nelem
                soa.(flds{j})(i:aos_nelem:end) = aos(i).(flds{j})(:);
            end
        else % Inner Nesting (i.e. keep contiguous data contiguous)
            new_fld_sz = num2cell([fld_sz, aos_sz]);
            soa.(flds{j})(new_fld_sz{:}) = aos(end).(flds{j})(end);
            for i = 1:aos_nelem
                soa.(flds{j})(1+(i-1)*nelem:i*nelem) = aos(i).(flds{j})(:);
            end
        end
    else % nesting using cell arrays works always
        soa.(flds{j}) = cell(aos_sz);
        for i = 1:aos_nelem
            soa.(flds{j}){i} = aos(i).(flds{j});
        end
    end
end

end

%% Function definitions

function cs = consistent_size(cell_of_mat)
%CONSISTEN_SIZE Check if all matrices in a cell array have the same size
% Also works with nested cell arrays
    cs = false;
    if isempty(cell_of_mat)
        return;
    end
    sz = size(cell_of_mat{1});
    dim = length(sz);
    for i = 2:length(cell_of_mat)
        sz2 = size(cell_of_mat{i});
        if length(sz2) == dim
            if ~all(sz == sz2)
                return;
            end
        else
            return;
        end
    end
    cs = true;
end
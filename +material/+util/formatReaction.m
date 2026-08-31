function [reaction_string] = formatReaction(reactants, products, species, options)
%FORMATREACTION fancy reaction string
% =========================================================================
% Generate a human readable and unique string representation of a reaction
% with optional latex output.
%
% ARGUMENTS ---------------------------------------------------------------
%
%   reactants   (cell), reactants specified using their irm names
%
%   products    (cell), products specified using their irm names
%
%   species     (struct/table, optional), species information
%                   both legacy and new format are supported
%                   See also: material.species
%
% NAME-VALUE --------------------------------------------------------------
%
%   'Style'     (char), in which style the reaction should be printed
%                   - 'normal'  : use the regular irm names and ascii
%                   formatting
%                   - 'latex'   : use the latex names and latex formatting
%
% RETURN ------------------------------------------------------------------
%
%   species_table   (table), table of species
%
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ NOTE ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This function requires Matlab 2019b or later.
% =========================================================================

%% NOTES: -----------------------------------------------------------------

% -------------------------------------------------------------------------

%% Argument parsing and validation
arguments
    reactants cell
    products cell
    species = {}
    options.Style char {mustBeMember(options.Style, ...
        {'normal', 'latex'})} = 'normal'
end

%%

% Sort so that the reaction_string uniquely defines the reaction.
% This also puts the electrons at the end, since all other species start
% with an uppercase letter.
reacts = sort(reactants);
prods = sort(products);

arrow = ' -> ';

switch options.Style
    case 'latex'
        if ~isempty(species)
            [old_name_list, new_name_list] = getSpeciesNameLists(species);
            reacts = map(reacts, old_name_list, new_name_list);
            prods = map(prods, old_name_list, new_name_list);
            arrow = ' $\rightarrow$ ';
        else
            warnCannotUseStyle(options.Style)
        end
end

reaction_string = string(append( ...
    join(reacts,' + '), ...
    arrow, ...
    join(prods, ' + ') ...
    ));

end

%% Function defintions

function new_names = map(old_names, old_name_list, new_name_list)
    new_names = cellfun(@(name) new_name_list{strcmp(name,old_name_list)}, old_names, 'UniformOutput', false);
end

function [old_name_list, new_name_list] = getSpeciesNameLists(species)
    if isstruct(species) % legacy format % TODO: deprecate
        old_name_list = species.Names;
        new_name_list = species.List;
    elseif istable(species) % new format
        old_name_list = species.name(:);
        new_name_list = species.label(:);
    else
        error('material:util:formatReaction:getSpeciesNameList:unknownSpeciesFormat', ...
            "The <species> argument must either be a table (new format) or a struct (legacy format).");
    end
end

function warnCannotUseStyle(style)
    warning('irm:material:util:formatReaction:missingSpeciesInfo', ...
        "Cannot format reaction in %s style since no valid " + ...
        "species information was supplied. Formating in normal style instead.", style);
end
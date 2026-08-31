function [refill, target, n, ind, Eiz] = getSpeciesInfo(species)
%GETSPECIESINFO Extract spcies info required for other setup steps.
% =========================================================================
% Extract species information required by other setup steps. This includes
% the refill gas and target material type, the total number of species, a
% structure linking species names to their index and the ionization energy
% for each species.
%
% ARGUMENTS ---------------------------------------------------------------
%
%   species     (table/struct), species table
%                   A table containing species information as produced by
%                   the material.species function. A legacy species
%                   struct compatible with IRM v1.2 is also supported.
%
% RETURN ------------------------------------------------------------------
%
%   refill      (string), refill gas
%   target      (string), target material
%   n           (integer), # of species
%   ind         (struct), structure linking species names to species index
%   Eiz         (double, array), array containing the energy w.r.t the
%                   corresponding ground state
%                   % FIXME: Eiz is a missleading name
%
%
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ NOTE ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This function requires Matlab 2019b or later.
% =========================================================================

%% NOTES: -----------------------------------------------------------------
% TODO: rename to follow new convention (Pascal Case for functions)
% -------------------------------------------------------------------------

%% Argument parsing and validation
arguments
    % positional arguments
    species     {material.util.valid.mustBeValidSpeciesInfo}
end

switch class(species)
    case 'struct' % legacy
        refill = species.Refill_gases;
        target = species.Target;
        n = length(species.Names);
        ind = species.s;
        Eiz = species.Energy;
    case 'table'
        refill = species.Properties.UserData.refill;
        target = species.Properties.UserData.target;
        n = height(species);
        ind = util.base.enumStruct(species.Names);
        Eiz = species.E;
    otherwise
        error('Invalid Input Type. <species> must be either a species table or a struct containing relevant species information.');
end

end

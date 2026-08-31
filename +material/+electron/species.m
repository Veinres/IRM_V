function [species_table] = species(T_g, T_gi)
%SPECIES generate table of electron species
% =========================================================================
% Generate a table containing relevant electron species.
%
% ARGUMENTS ---------------------------------------------------------------
%
%   T_g         (numeric), The temperature of the working gas
%                   This is ignored - just here to have the same interface.
%
%   T_gi        (numeric), The temperature of working gas ions
%                   This is ignored - just here to have the same interface.
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
    % optional positional arguments
    T_g         {mustBeNumeric, mustBeReal, mustBeScalarOrEmpty} = 0.0431
    T_gi        {mustBeNumeric, mustBeReal, mustBeScalarOrEmpty} = 1
end

me  = 9.109e-31;

%% Species table ----------------------------------------------------------
var_names       = {'parent' ,'name'     ,'label'            ,'comp' ,'M'    ,'Q'    ,'T'    ,'state','E'        ,'degen','beta' ,'n0'       };
species_cell    = {'e'      ,'e'        ,'e'                ,{[-1]} ,me     , -1    , NaN   , 'e'   , 0         , 1     , 0     ,  1e17     ;...
                   'e'      ,'eh'       ,'e$^h$'            ,{[-1]} ,me     , -1    , NaN   , 'e'   , 0         , 1     , 0     ,  1e3      };
% -------------------------------------------------------------------------

species_table = cell2table(species_cell, 'VariableNames', var_names);
end

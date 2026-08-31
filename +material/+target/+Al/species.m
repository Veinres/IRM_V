function [species_table] = species(T_g, T_gi)
%SPECIES generate table of aluminium species
% =========================================================================
% Generate a table containing relevant aluminium species.
%
% ARGUMENTS ---------------------------------------------------------------
%
%   T_g         (numeric, optional, default: 1eV), Working gas
%                   temperature in electron volt.
%
%   T_gi        (numeric, optional, default: 1eV), Working gas ion
%                   temperature in electron volt.
%                   Will be ignored.
%
% RETURN ------------------------------------------------------------------
%
%   species_table   (table), table of species
%
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ NOTE ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This function requires Matlab 2019b or later.
% =========================================================================

%% NOTES: -----------------------------------------------------------------
%
% -------------------------------------------------------------------------

%% Argument parsing and validation
arguments
    % optional positional arguments
    T_g         {mustBeNumeric, mustBeReal, mustBeScalarOrEmpty} = 0.0431
    T_gi        {mustBeNumeric, mustBeReal, mustBeScalarOrEmpty} = 1
end

TAl = 3/2*3.39; % 3/2 times the cohesive energy in eV

mAl = 26.982*1.66053906660e-27; % mass in kg

%% Species table ----------------------------------------------------------
var_names       = {'parent' ,'name'     ,'label'            ,''     ,'M'    ,'Q'    ,'T'    ,'state','E'        ,'degen','beta' ,'n0'       };
species_cell    = {'Al'     ,'Al'       ,'Al'               ,{[13]} ,mAl    , 0     , TAl   , 'grd' , 0         , NaN   , 0     , 1e12      ;...
                   'Al'     ,'Ali'      ,'Al$^+$'           ,{[13]} ,mAl    , +1    , TAl   , 'ion' , 6.8281    , NaN   , 0.9   , 1e3       ;...
                   'Al'     ,'Alii'     ,'Al$^{2+}$'        ,{[13]} ,mAl    , +2    , TAl   , 'ion' , 13.5755   , NaN   , 0.9   , 1e1       };
% -------------------------------------------------------------------------

species_table = cell2table(species_cell, 'VariableNames', var_names);
end


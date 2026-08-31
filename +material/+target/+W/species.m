function [species_table] = species(T_g, T_gi)
%SPECIES generate table of tungsten species
% =========================================================================
% Generate a table containing relevant tungsten species.
%
% ARGUMENTS ---------------------------------------------------------------
%
%   T_g         (numeric, optional, default: 1eV), Working gas
%                   temperature in electron volt.
%                   Will be ignored.
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

% -------------------------------------------------------------------------

%% Argument parsing and validation
arguments
    % optional positional arguments
    T_g         {mustBeNumeric, mustBeReal, mustBeScalarOrEmpty} = 0.0431
    T_gi        {mustBeNumeric, mustBeReal, mustBeScalarOrEmpty} = 1
end

% TW = 13.35;
% 
% mW  = 3.0527348e-25;

TW = 3/2*8.90; % 3/2 times the cohesive energy in eV

mW  = 183.84*1.66053906660e-27; % mass in kg

%% Species table ----------------------------------------------------------
var_names       = {'parent' ,'name'     ,'label'            ,'comp'     ,'M'    ,'Q'    ,'T'    ,'state','E'        ,'degen','beta' ,'n0'       };
species_cell    = {'W'      ,'W'        ,'W'                ,{[74]}     ,mW     , 0     , TW    , 'grd' , 0         , NaN   , 0     ,  1e12     ;...
                   'W'      ,'Wi'       ,'W$^+$'            ,{[74]}     ,mW     ,+1     , TW    , 'ion' , 7.8640    , NaN   , 0.9   ,  1e3      ;...
                   'W'      ,'Wii'      ,'W$^{2+}$'         ,{[74]}     ,mW     ,+2     , TW    , 'ion' , 16.100    , NaN   , 0.9   ,  1e1      };
% -------------------------------------------------------------------------

species_table = cell2table(species_cell, 'VariableNames', var_names);
end


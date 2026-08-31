function [species_table] = species(T_g, T_gi)
%SPECIES generate table of molybdenum species
% =========================================================================
% Generate a table containing relevant molybdenum species.
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

TMo = 3/2*6.82; % 3/2 times the cohesive energy in eV

% mMo = 1.6048807E-25;% mass in kg
mMo  = 95.95*1.66053906660e-27; % mass in kg

%% Species table ----------------------------------------------------------
var_names       = {'parent' ,'name'     ,'label'            ,'comp'     ,'M'    ,'Q'    ,'T'    ,'state','E'        ,'degen','beta' ,'n0'       };
species_cell    = {'Mo'     ,'Mo'       ,'Mo(GS)'           ,{[42]}     ,mMo    , 0     , TMo   , 'grd' , 0         , NaN   , 0     ,  1e12     ;...
                   'Mo'     ,'Moi'      ,'Mo$^+$'           ,{[42]}     ,mMo    ,+1     , TMo   , 'ion' , 7.0924    , NaN   , 0.9   ,  1e3      ;...
                   'Mo'     ,'Moii'     ,'Mo$^{2+}$'        ,{[42]}     ,mMo    ,+2     , TMo   , 'ion' , 16.16     , NaN   , 0.9   ,  1e1      };

% -------------------------------------------------------------------------

species_table = cell2table(species_cell, 'VariableNames', var_names);
end


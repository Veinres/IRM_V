function [species_table] = species(T_g, T_gi)
%SPECIES generate table of carbon species
% =========================================================================
% Generate a table containing relevant carbon species.
%
% ARGUMENTS ---------------------------------------------------------------
%
%   T_g         (numeric, optional, default: 1eV), Working gas
%                   temperature in electron volt.
%
%   T_gi        (numeric, optional, default: 1eV), Working gas ion
%                   temperature in electron volt.
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

% TC = 11.05;
% TCi = 11.05;
% 
% mC = 1.9944235e-26;

TC = 3/2*7.37; % 3/2 times the cohesive energy in eV
TCi = TC;

mC = 12.0107*1.66053906660e-27; % mass in kg

%% Species table ----------------------------------------------------------
var_names       = {'parent' ,'name'     ,'label'            ,'comp' ,'M'    ,'Q'    ,'T'    ,'state','E'        ,'degen','beta' ,'n0'       };
species_cell    = {'C'      ,'C'        ,'C'                ,{[6]}  ,mC     , 0     , TC    ,'grd'  , 0         , NaN   , 0     , 1E12      ;...
                   'C'      ,'Cm1'      ,'C$^m_1$'          ,{[6]}  ,mC     , 0     , T_g   ,'exm'  , 1.2601    , NaN   , 0     , 0         ;...
                   'C'      ,'Cm2'      ,'C$^m_2$'          ,{[6]}  ,mC     , 0     , T_g   ,'exm'  , 2.68034   , NaN   , 0     , 0         ;...
                   'C'      ,'Cm3'      ,'C$^m_3$'          ,{[6]}  ,mC     , 0     , T_g   ,'exm'  , 4.17896   , NaN   , 0     , 0         ;...
                   'C'      ,'Ci'       ,'C$^+$'            ,{[6]}  ,mC     , +1    , TCi   ,'ion'  , 11.26030  , NaN   , 0.9   , 1E3       ;...
                   'C'      ,'Cii'      ,'C$^{2+}$'         ,{[6]}  ,mC     , +2    , T_gi  ,'ion'  , 24.38     , NaN   , 0.9   , 1E1       };
% -------------------------------------------------------------------------

species_table = cell2table(species_cell, 'VariableNames', var_names);
end


function [species_table] = species(T_g, T_gi)
%SPECIES generate table of copper species
% =========================================================================
% Generate a table containing relevant copper species.
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

% TCu = 5.235;
% 
% mCu = 1.0552061e-25;

TCu = 3/2*3.49; % 3/2 times the cohesive energy in eV

mCu = 63.546*1.66053906660e-27; % mass in kg

%% Species table ----------------------------------------------------------
var_names       = {'parent' ,'name'     ,'label'            ,'comp'     ,'M'    ,'Q'    ,'T'    ,'state','E'        ,'degen','beta' ,'n0'       };
species_cell    = {'Cu'     ,'Cu'       ,'Cu(3d$^{10}$4s $^2$S$_{1/2}$)',{[29]} ,mCu, 0 ,TCu    ,'grd'  , 0         , NaN   , 0     , 1e13      ;...
                   'Cu'     ,'Cum1'     ,'Cu(3d$^{9}$4s$^2$ $^2$D$_{5/2}$)',{[29]},mCu, 0,TCu   ,'exm'  , 1.39      , NaN   , 0     , 0         ;...
                   'Cu'     ,'Cum2'     ,'Cu(3d$^{9}$4s$^2$ $^2$D$_{3/2}$)',{[29]},mCu, 0,TCu   ,'exm'  , 1.64      , NaN   , 0     , 0         ;...
                   'Cu'     ,'Cum3'     ,'Cu(3d$^{10}$4p $^2$P$_{1/2,3/2}$)',{[29]},mCu, 0,TCu  ,'exm'  , 3.79      , NaN   , 0     , 0         ;...
                   'Cu'     ,'Cui'      ,'Cu$^+$'           ,{[29]}     ,mCu    ,+1     ,TCu    ,'ion'  , 7.73      , NaN   , 0.9   , 1e3       ;...
                   'Cu'     ,'Cuii'     ,'Cu$^{2+}$'        ,{[29]}     ,mCu    ,+2     ,TCu    ,'ion'  , 20.29     , NaN   , 0.9   , 1e1       };
% -------------------------------------------------------------------------

species_table = cell2table(species_cell, 'VariableNames', var_names);
end


function [species_table] = species(T_g, T_gi)
%SPECIES generate table of helium species
% =========================================================================
% Generate a table containing relevant helium species.
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
    T_g         {mustBeNumeric, mustBeReal, mustBeScalarOrEmpty} = 0.0431 % 500K
    T_gi        {mustBeNumeric, mustBeReal, mustBeScalarOrEmpty} = 1
end

hc = 1.23984198e-4; % eV*cm
k_B = 1.380649e-23; % J/K
e = 1.602176634e-19; % C
amu = 1.66053906660e-27; % kg
% mHe = 6.404e-27;
mHe = 4.002*amu;
n0 = 1/(T_g*e); % 1/m3/Pa

T_ArW = 0.1; % NOTE: source/reason?
T_ArH = 2; % NOTE: source/reason?

%% Species table ----------------------------------------------------------
var_names       = {'parent' ,'name'     ,'label'            ,'comp' ,'M'    ,'Q'    ,'T'    ,'state','E'        ,'degen','beta' ,'n0'       };
species_cell    = {'He'     ,'He'       ,'He(1s$^0$)'       ,{[2]}  ,mHe    , 0     , T_g   ,'grd'  , 0         , NaN   , 0     ,  n0       ;...
                   'He'     ,'Hem2S1'   ,'He(2s$_1$)'       ,{[2]}  ,mHe    , 0     , T_g   ,'exm'  , 19.82     , NaN   , 0     ,  0        ;...
                   'He'     ,'Hem2S0'   ,'He(2s$_0$)'       ,{[2]}  ,mHe    , 0     , T_g   ,'exm'  , 20.62     , NaN   , 0     ,  0        ;...
                   'He'     ,'He2P012'  ,'He(2p$_{0,1,2}$)' ,{[2]}  ,mAr    , 0     , T_g   ,'exm'  , 20.92     , NaN   , 0     ,  0        ;...
                   'He'     ,'He2P1'    ,'He(2p$_1$)'       ,{[2]}  ,mHe    , 0     , T_g   ,'exm'  , 21.07     , NaN   , 0     ,  0        ;...
                   'He'     ,'Hei'      ,'He$^+$'           ,{[2]}  ,mAr    ,+1     , T_gi  ,'ion'  , 24.58     , NaN   , 0.9   ,  1e16     ;...
                   'He'     ,'HeW'      ,'He$^W$(1s$^0$)'   ,{[2]}  ,mHe    , 0     , T_ArW ,'thr'  , 0         , NaN   , 0     ,  0        ;...
                   'He'     ,'HeH'      ,'He$^H$(1s$^0$)'   ,{[2]}  ,mHe    , 0     , T_ArH ,'thr'  , 0         , NaN   , 0     ,  0        };
% -------------------------------------------------------------------------

species_table = cell2table(species_cell, 'VariableNames', var_names);
end

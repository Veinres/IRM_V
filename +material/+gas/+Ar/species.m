function [species_table] = species(T_g, T_gi)
%SPECIES generate table of argon species
% =========================================================================
% Generate a table containing relevant argon species.
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
mAr = 39.95*amu;
n0 = 1/(T_g*e); % 1/m3/Pa

T_ArW = 0.1; % NOTE: source/reason?
T_ArH = 2; % NOTE: source/reason?

% excited atomic states
EArm3P2 = 93143.7653*hc; % [1]
EArm3P0 = 94553.6705*hc; % [1]

EAri = 127109.842*hc; % [1]
EArii = 222848.3*hc; % [2]

% NOTE: there seems to be somthing weird with the labeling, especially of
% the metastable states. Also the energy should probably be weighted over
% the states with different total angular momentum J.
% TODO: check degeneracies

%% Species table ----------------------------------------------------------
var_names       = {'parent' ,'name'     ,'label'            ,'comp' ,'M'    ,'Q'    ,'T'    ,'state','E'        ,'degen','beta' ,'n0'       };
species_cell    = {'Ar'     ,'Ar'       ,'Ar(3p$^6$)'       ,{[18]} ,mAr    , 0     , T_g   ,'grd'  , 0         , 1     , 0     ,  n0       ;...
                   'Ar'     ,'Arm3P0'   ,'Ar(4s[3/2]$_0$)'  ,{[18]} ,mAr    , 0     , T_g   ,'exm'  , EArm3P0   , 6     , 0     ,  0        ;... % FIXME : check degeneracy (6 in Thorsteinssons's code)
                   'Ar'     ,'Arm3P2'   ,'Ar(4s[3/2]$_2$)'  ,{[18]} ,mAr    , 0     , T_g   ,'exm'  , EArm3P2   , 6     , 0     ,  0        ;... % FIXME : check degeneracy (6 in Thorsteinssons's code)
                   'Ar'     ,'Ari'      ,'Ar$^+$'           ,{[18]} ,mAr    ,+1     , T_gi  ,'ion'  , EAri      , 1     , 0.9   ,  1e17     ;... % FIXME : check degeneracy (1 in Thorsteinssons's code)
                   'Ar'     ,'Arii'     ,'Ar$^{2+}$'        ,{[18]} ,mAr    ,+2     , T_gi  ,'ion'  , EArii     , NaN   , 0.9   ,  0        ;... % FIXME : check degeneracy (0 in Thorsteinssons's code)
                   'Ar'     ,'ArW'      ,'Ar$^W$(3p$^6$)'   ,{[18]} ,mAr    , 0     , T_ArW ,'thr'  , 0         , 1     , 0     ,  0        ;...
                   'Ar'     ,'ArH'      ,'Ar$^H$(3p$^6$)'   ,{[18]} ,mAr    , 0     , T_ArH ,'thr'  , 0         , 1     , 0     ,  0        };
% -------------------------------------------------------------------------

% Conf  -1  0 +1         0  | S     | L     | J         | Label           | g
% --------------------------|-------|-------|-----------|-----------------|----------
% --------------------------|-------|-------|-----------|-----------------|----------


% From [1] and [2]:
% Configuration      Term     J   Level(cm-1)  Ref.
% ---------------------------------------------------
% 3p6                1S       0       0.000    VHU99
%
% 3p5(2P°3/2)4s      2[3/2]°  2   93143.7653   M73
%                             1   93750.6031   M73
% 
% 3p5(2P°1/2)4s      2[1/2]°  0   94553.6705   M73
%                             1   95399.8329   VHU99
%
% Ar II (2P°3/2)     Limit       127109.842    VHU99
%
% Ar III (3P2)       Limit       222848.3      M60b

% REFERENCES:
% [1] https://www.physics.nist.gov/PhysRefData/Handbook/Tables/argontable5.htm
%       M73: L. Minnhagen, J. Opt. Soc. Am. 63, 1185 (1973).
%       VHU99: I. Velchev, W. Hogervorst, and W. Ubachs, J. Phys. B 32, L511 (1999).
% [2] https://www.physics.nist.gov/PhysRefData/Handbook/Tables/argontable6.htm
%       M60b: L. Minnhagen, Ark. Fys. 18, 97 (1960).

species_table = cell2table(species_cell, 'VariableNames', var_names);
end

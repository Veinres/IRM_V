function [species_table] = species(T_g, T_gi)
%SPECIES generate table of titanium species
% =========================================================================
% Generate a table containing relevant titanium species.
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

amu = 1.66053906660e-27; % kg
hc = 1.23984198e-4; % eV*cm
mTi = 47.867*amu;

% TTi = 3/2*4.85; % 3/2 times the cohesive energy in eV
TTi = 8.15; % !!! this is different from the value that is usually used % TODO : figure out/ask why?

% excited atomic states
ETii = 55072.5*hc; % [1]
ETiii = 109494*hc; % [2]

%% Species table ----------------------------------------------------------
var_names       = {'parent' ,'name'     ,'label'            ,'comp' ,'M'    ,'Q'    ,'T'    ,'state','E'        ,'degen','beta' ,'n0'       };
species_cell    = {'Ti'     ,'Ti'       ,'Ti'               ,{[22]} ,mTi    , 0     , TTi   , 'grd' , 0         , NaN   , 0     , 1e12      ;...
                   'Ti'     ,'Tii'      ,'Ti$^+$'           ,{[22]} ,mTi    ,+1     , TTi   , 'ion' , ETii      , NaN   , 0.9   , 1e3       ;...
                   'Ti'     ,'Tiii'     ,'Ti$^{2+}$'        ,{[22]} ,mTi    ,+2     , TTi   , 'ion' , ETiii     , NaN   , 0.9   , 1e1       };
% -------------------------------------------------------------------------

% From [1] and [2]:
% Configuration     Term   J   Level(cm-1) Ref.
% ---------------------------------------------------
% 3d24s2            a 3F   2       0.000   F91
%                          3     170.134   F91
%                          4     386.875   F91
%
% Ti II (4F3/2)     Limit      55072.5     SZK90
%
% Ti III (3F2)      Limit     109494       SC85

% REFERENCES:
% [1] https://www.physics.nist.gov/PhysRefData/Handbook/Tables/titaniumtable5.htm
%       SZK90: J. E. Sohl, Y. Zhu, and R. D. Knight, J. Opt. Soc. Am. B 7, 9 (1990).  
% [2] https://www.physics.nist.gov/PhysRefData/Handbook/Tables/titaniumtable6.htm
%       SC85: J. Sugar and C. Corliss, J. Phys. Chem. Ref. Data 14, Suppl. 2 (1985). 

species_table = cell2table(species_cell, 'VariableNames', var_names);
end

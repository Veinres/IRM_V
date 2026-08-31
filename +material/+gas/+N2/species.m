function [species_table] = species(T_g, T_gi)
%SPECIES generate table of nitrogen species
% =========================================================================
% Generate a table containing relevant nitrogen species.
%
% ARGUMENTS ---------------------------------------------------------------
%
%   T_g         (numeric, optional, default: 500K=0.0431eV), Working gas
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
mN = 14.007*amu; % kg
n0 = 1/(T_g*e); % 1/m3/Pa

% warm and hot nitrogen temperatures
T_NW = 0.1; % FIXME : this is simply the same as Ar - should probably be taken from Thomposon distribution
T_NH = 2; % FIXME : this is simply the same as Ar

% excited molecular states
omega_e = [0,2358.57, 14.324, -2.26E-3]; % [1a]
omega_eA= [50203.6, 1460.64,13.87,0.0103]; % [1b]
E_vib = @(v, coeff) hc*dot((v+0.5).^[0,1,2,3], [1,1,-1,1].*coeff); % [2]
dE_vib = @(v) E_vib(v, omega_e)-E_vib(0, omega_e);
EN2A = E_vib(0,omega_eA)-E_vib(0,omega_e);
EN2i = 15.581; % [5]

% excited atomic states
END = (19224.464 + 19233.177)/2*hc; % [3]
ENP = (28838.920 + 28839.306)/2*hc; % [3]
ENi = 117225.7*hc; % [3]

%% Species table ----------------------------------------------------------
% TODO: nicer labels similar to Ar
var_names       = {'parent' ,'name'     ,'label'            ,'comp'     ,'M'    ,'Q'    ,'T'    ,'state','E'        ,'degen','beta' ,'n0'       };
species_cell    = {'N2'     ,'N2'       ,'N$_2(X,v=0)$'     ,{[7,7]}    ,2*mN   , 0     , T_g   ,'grd'  , 0         , 1     , 0     , n0        ;... % grd
                   'N2'     ,'N2v1'     ,'N$_2(X,v=1)$'     ,{[7,7]}    ,2*mN   , 0     , T_g   ,'vib'  , dE_vib(1) , 1     , 0     , 0         ;... % [1a,2]
                   'N2'     ,'N2v2'     ,'N$_2(X,v=2)$'     ,{[7,7]}    ,2*mN   , 0     , T_g   ,'vib'  , dE_vib(2) , 1     , 0     , 0         ;... % [1a,2]
                   'N2'     ,'N2v3'     ,'N$_2(X,v=3)$'     ,{[7,7]}    ,2*mN   , 0     , T_g   ,'vib'  , dE_vib(3) , 1     , 0     , 0         ;... % [1a,2]
                   'N2'     ,'N2v4'     ,'N$_2(X,v=4)$'     ,{[7,7]}    ,2*mN   , 0     , T_g   ,'vib'  , dE_vib(4) , 1     , 0     , 0         ;... % [1a,2]
                   'N2'     ,'N2v5'     ,'N$_2(X,v=5)$'     ,{[7,7]}    ,2*mN   , 0     , T_g   ,'vib'  , dE_vib(5) , 1     , 0     , 0         ;... % [1a,2]
                   'N2'     ,'N2v6'     ,'N$_2(X,v=6)$'     ,{[7,7]}    ,2*mN   , 0     , T_g   ,'vib'  , dE_vib(6) , 1     , 0     , 0         ;... % [1a,2]
                   'N2'     ,'N2A'      ,'N$_2(A)$'         ,{[7,7]}    ,2*mN   , 0     , T_g   ,'exm'  , EN2A      , 3     , 0     , 0         ;... % [1b,2] % FIXME : check degeneracy: S=1 -> 3?
                   'N2'     ,'NS'       ,'N(S)'             ,{[7]}      ,mN     , 0     , T_g   ,'grd'  , 0         , 4     , 0     , 1e3       ;... % grd
                   'N2'     ,'NW'       ,'N(S)$^W$'         ,{[7]}      ,mN     , 0     , T_NW  ,'grd'  , 0         , 4     , 0     , 0         ;... % grd
                   'N2'     ,'NH'       ,'N(S)$^H$'         ,{[7]}      ,mN     , 0     , T_NH  ,'grd'  , 0         , 4     , 0     , 0         ;... % grd
                   'N2'     ,'ND'       ,'N(D)'             ,{[7]}      ,mN     , 0     , T_g   ,'exm'  , END       , 10    , 0     , 0         ;... % [3]
                   'N2'     ,'NP'       ,'N(P)'             ,{[7]}      ,mN     , 0     , T_g   ,'exm'  , ENP       , 6     , 0     , 0         ;... % [3]
                   'N2'     ,'Ni'       ,'N$^+$'            ,{[7]}      ,mN     ,+1     , T_gi  ,'ion'  , ENi       , NaN   , 0.9   , 1e3       ;... % [3,4] % FIXME : check degeneracy (0 in Thorsteinssons's code)
                   'N2'     ,'N2i'      ,'N$_2^+$'          ,{[7,7]}    ,2*mN   ,+1     , T_gi  ,'ion'  , EN2i      , NaN   , 0.9   , 1e15      ;... % [4,5] % FIXME : check degeneracy (0 in Thorsteinssons's code)
                   'N2'     ,'N3i'      ,'N$_3^+$'          ,{[7,7,7]}  ,3*mN   ,+1     , T_gi  ,'ion'  , 0         , NaN   , 0.9   , 0         ;... % [4,6] % FIXME : check degeneracy (0 in Thorsteinssons's code), energy?
                   'N2'     ,'N4i'      ,'N$_4^+$'          ,{[7,7,7,7]},4*mN   ,+1     , T_gi  ,'ion'  , 0         , NaN   , 0.9   , 0         ...  % [4] % FIXME : check degeneracy (0 in Thorsteinssons's code), energy?
                   };
species_table = cell2table(species_cell, 'VariableNames', var_names);
% -------------------------------------------------------------------------

% degen is a new variable corresponding to the degeneracy of the energy
% level. This is needed for detailed balancing.
%
% Following Liebermann (p.63 ff), the degenerecy of a given energy level of
% an atomic species is given by:
%   g = 2*J + 1
% where J is the sum of the orbital and spin angular momenutm quantum
% numbers L and S associated with a given energy level.
% For atomic Nitrogen, the lowest energy levels ([He]2s^2 2p^3) are:
%
% Conf  -1  0 +1  | S     | L     | J         | Term Symbol (LS)| g=2*J+1
% ----------------|-------|-------|-----------|-----------------|----------
% 2p : [^ |^ |^ ] | 3/2   | 0     | 3/2       | ^4S_{3/2}       | 4
% 2p : [^v|^ |  ] | 1/2   | 2     | 3/2 5/2   | ^2D_{3/2|5/2}   | 4 + 6 = 10
% 2p : [^ |^v|  ] | 1/2   | 1     | 1/2 3/2   | ^2P_{3/2|5/2}   | 2 + 4 = 6
% 2p : [^v|  |^ ] | 1/2   | 1     | 1/2 3/2   | ^2P_{3/2|5/2}   | 2 + 4 = 6
% ----------------|-------|-------|-----------|-----------------|----------
%
% which are all metastable because Delta S = 1 ~= 0
%
% (Note: the selection rules are as follows:
%   Delta l = +-1
%   Delta J = +-1 and Delta J = 0 if J ~= 0
% and for light elements (Z ~< 40) also:
%   Delta L = +-1 and Delta L = 0 if L ~= 0
%   Delta S = 0
% )
%
% Let's also look at the lowest energy levels of Ni:
% Conf  -1  0 +1  | S     | L     | J         | Term Symbol (LS)| g=2*J+1
% ----------------|-------|-------|-----------|-----------------|----------
% 2p : [^ |^ |  ] | 2/2   | 1     | 0/2 4/2   | ^3P_{0|2}       | 1 + 5 = 6
% 2p : [^ |  |^ ] | 2/2   | 0     | 2/2       | ^3P_{1}         | 3
% 2p : [^v|  |  ] | 0/2   | 2     | 4/2       | ^1D_{2}         | 5
% 2p : [  |^v|  ] | 0/2   | 0     | 0         | ^1S_{0}         | 1
% ----------------|-------|-------|-----------|-----------------|----------
%
% where ^3P_{0|1|2} is the ground state and the others are not (meta)stable.
%
% Regarding the molecules: According to Liebermann p. 237 or Herman p.75,
% vibrational levels are non-degenerate
% (because harm. oscill. has non degenerate energy levels?).
% The ground state N_2(X,^1\Sigma_g^+) is clearly non-degenerate (Lambda=S=0).
% The first electronically excited state is
% Lambda=0, S=1 => g=S*2+1=3 ?
% ??? But why is that state labeled A, eventhough the spin multipilicity is
% different?
%
% (Compare with
% https://www.physics.nist.gov/PhysRefData/Handbook/Tables/nitrogentable5.htm
% https://www.physics.nist.gov/PhysRefData/Handbook/Tables/nitrogentable6.htm
% note: cm^{-1} -> 0.124meV => cm^{-1} -> 1eV ~ 8066/cm
% )

% Molecules -> Liebermann p.235 ff

% Comments from thorsteinsson (findings from pulsed discharge volume model):
% - vibrational states are important at high pressure
% - N3i and N4i were mostly negligible
% - thorsteinsson questions the accuracy of the dissociation cross-sections
%   and thinks they might have been underestimated

% NOTE: start without N3i and N4i
msk = ~ismember(species_table.name, {'N3i','N4i'});
species_table = species_table(msk,:);
% NOTE: could reduce the six vibrational states to a single effective one
% or only include them for the effective loss calculations
%   - alternatively, simply apply threshold reduction for the corresponding
%   reactions -> we get cross-sections basically for free, but as noted
%   above, thorsteinsson questioned accuracy of dissociation cross-sections

% NOTE: Nii ionisation energy is about 10% higher than Arii

% REFERENCES:
% [1] https://webbook.nist.gov/cgi/cbook.cgi?ID=C7727379&Units=SI&Mask=1000#ref-1
%     https://webbook.nist.gov/cgi/inchi/InChI%3D1S/N2/c1-2
%       a   : Crawford, Welsh, et al., 1949; Bosomworth and Gush, 1965; Reddy and Cho, 1965; ...
%       b   : Dieke and Heath, 1959; Miller, 1965; Miller, 1966
% [2] https://hbcp.chemnetbase.com/faces/documents/09_08/09_08_0001.xhtml
% [3] https://www.physics.nist.gov/PhysRefData/Handbook/Tables/nitrogentable5.htm
%       M75a: C. E. Moore, Natl. Stand. Ref. Data Ser., Natl. Bur. Stand. (U.S.) 3, Sect. 5 (1975).
% [4] R. K. ASUNDI,t G. J. SCHULZ,t AND P. J. CHANTRY, Studies of N3+ and
%       N4+ Ion Formation in Nitrogen Using High-Pressure Mass Spectrometry,
%       1967, https://doi.org/10.1063/1.1712137
% [5] https://webbook.nist.gov/cgi/cbook.cgi?ID=C7727379&Mask=20#Ion-Energetics
% [6] https://webbook.nist.gov/cgi/cbook.cgi?ID=C12596600&Units=SI&Mask=20#Ion-Energetics

end

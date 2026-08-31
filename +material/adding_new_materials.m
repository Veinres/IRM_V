%% Adding New Materials

% TODO : move this to the documentation

%% Species
% 
% The relevant species to be added are usually:
% 
% Atomic:
% 
% - Ground state
% - Metastable excited states
% - Ionised states
% 
% Molecular (if necessary):
% 
% - Ground state + vibrational levels
% - Metastable excited states
% 
% For each species, the required fields are:
% 
% | field     | description                                                           |
% |-----------|-----------------------------------------------------------------------|
% | parent    | the "parent" species - usually same as the ground state               |
% | name      | internally used species name - must be a valid matlab variable name   |
% | label     | fancy, latex compatible name which will be used in plots              |
% | comp      | composition, given in terms of atomic numbers (-1 for electrons)      |
% | M         | mass of the species in kg                                             |
% | Q         | electric charge of the species in e                                   |
% | T         | temperature of the species in eV                                      |
% | state     | type of state : 'grd', 'vib', 'exm', 'ion'                            |
% | E         | ionisation energy in eV                                               |
% | beta      | back attraction probability for ionic species - currently ignored     |
% | n0        | initial density in 1/m3                                               |
% 
%
% https://en.wikipedia.org/wiki/Electron_configuration
% https://en.wikipedia.org/wiki/Term_symbol

%% Electron impact reactions

% # Electron distribution
% 
% For simplicity, a maxwellin distribution is assumed for the hot and cold electron populations (n=1).

syms E c_1 c_2 n E_av;
fE = c_1*E^(1/2)*exp(-c_2*E^n);
c_1 = n/E_av^(3/2)*gamma(5/(2*n))^(3/2)/gamma(3/(2*n))^(5/2);
c_2 = 1/E_av^n*(gamma(5/(2*n))/gamma(3/(2*n)))^n;
n = 1;

% Note: c1 and c2 are obtained from int(fE,E,0,Inf)==1 and int(fE,E,0,Inf)==Eav

% The rate coefficient for electron impact reactions can then be found in
% the following ways:

syms K sigma v_e m_e;
v_e = (2*E/m_e)^(1/2);
K = int(v_e*sigma*fE,E,0,Inf);

% and fit to generalized Arrhenius form:

syms A B C D E T_eff k_B;
T_eff = 2/3/k_B*E_av;
K_fit = (A + B*T_eff + C*T_eff^D)*exp(-E/T_eff);

% Ideally cross-sections are obtinaed from literature.
% If cross-sections are not available, it might be possible to obtain them:

% 1. from the threshold energy (dubbed threshold reduction by JT) - see
% Lieberman 2005 p.266
% given the cross-section of a reaction of the form

syms E_thr sigma0 b0
sigma = piecewise( E <  E_thr, 0,...
                   E >= E_thr, sigma0*(1-E_thr/E));

% the cross-section of a reaction in the same class of reactions that only
% differs in the energy of the reactant can be inferred by only replacing
% the threshold energy. An example of a situation where this could be
% applied is reactions involving metastable states, where switching out one
% reactant with a higher energy metastable would reduce the reaction
% threshold by the difference in energy.

% 2. from detailed balancing - see Lieberman 2005 p.267 ff or Thorsteinsson
% 2008 p.20 ff
% given the cross-section of a reaction, the cross-section of the inverse
% reaction can be obtained

% A + B -> C + D
% C + D -> A + B

% m_R = m_A*m_B/(m_A + m_B)

% In general, Lieberman 2005 is an excellent resource on this.

% Regarding inclusion of reactions:
% Apriori, three-body interactions can be considered rare enough that they
% do not have to be included. This includes in particular electron capture
% deionisation which requires a mediator (More generally, this is the case
% for all reactions with two reactants and only one product).

%% Effective cost of ionisation

% After Lieberman 2005, p.81 ( or Thorseinsson 2008, p.16 )
%
%   K_iz*E_c = K_iz*E_iz + K_ex*E_ex + K_el*E_el
%
% with
%
%   E_el = 3*m_e/M      the mean electron energy loss of elastic scattering
%                       by a gasous species of mass M
%
%   E_c^(alpha) = 1/K_iz_alpha*sum_beta(K_beta_alpha*E_beta_alpha)

%% Notes for N2:
% Some resources are linked in Thorsteinsson 2008, p.29
%
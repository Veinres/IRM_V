classdef const
%CONST Collection of physical constants
% The purpose of this collection is to give easy access and a central
% place for defintions. In performance sensitive code, it might be
% advantagous to directly include the constants in the code.
%
% [1] https://www.nist.gov/si-redefinition/meet-constants

properties (Constant)
    k_B     = 1.380649e-23;         % Boltzman Constant in [J/K] (exact/as defined, ref [1])
    e       = 1.602176634e-19;      % elementary charge in [C] (ref [1])
    amu     = 1.66053906660e-27;    % atomic mass unit in [kg] 
    hc      = 1.23984198e-4;        % Plank constant x speed of light in [eV*cm]
end

end

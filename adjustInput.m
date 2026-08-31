function [input] = adjustInput(input, f, beta, r, sd, z2)
%ADJUSTINPUT adjust the input parameters for the next simulation run
% This avoids having to recreate the enitre input structure each time
% NOTE : this should be just a temporary fix % FIXME

if exist('z2','var') && ~isempty(z2) && z2 > input.Para.z1 % FIXME
    old_L = input.Para.L;
    input.Para.z2 = z2;
    input.Para.L = input.Para.z2-input.Para.z1;
    input.Para.V_IR = input.Para.V_IR/old_L*input.Para.L;
    input.Para.S_IR = 2*pi*(input.Para.r2+input.Para.r1)*(input.Para.L+input.Para.rr);
    input.Para.S_BP = pi*(input.Para.r2+input.Para.r1)*(2*input.Para.L+input.Para.rr);
    input.Para.S_RT = (input.Para.r2+input.Para.r1)*input.Para.rr*pi;
end
if exist('sd','var') && ~isempty(sd) && sd > 1. % FIXME
    refill_ion = input.Spe.Refill_gases{1};
    refill_ion = strcat(refill_ion,'i');
    ind_refill_ion = find(strcmp(input.Spe.Names,refill_ion));
    old_sd = input.Spe.ID(ind_refill_ion);
    input.Spe.ID(ind_refill_ion) = sd;
    input.Spe.ID(1) = input.Spe.ID(1) - old_sd + sd;  % adjust electron density for quasi neutrality
end
% this section is the only different part from a panel_mode_sing_run file 
% Fitting parameter values in single run modified 
input.Para.f = f;
input.Para.beta = beta;
input.Para.r = r;
input.Para.hall = f;% if varf = 1 is selected, f is used to transfer the hall parameter
% Recalculation of some quanties that are linked to the change of parameter
input.Spe.B(input.Range.ion) = input.Para.beta;

% Some optimized inputs % NOTE : spares arrays have been tried and have turned out to be slower in most cases
input.Rea.Rt = input.Rea.R.'; % Matlab has column major arrays (columns are contiguous)
input.Rea.Pt = input.Rea.P.';
input.Rea.deltaR = input.Rea.Pt - input.Rea.Rt; % We don't care about the number of products, only net production is relevant

% TODO: remove unused fields

input.Rea.cfs = zeros([length(input.Rea.reactions),5]);
k_B = 1.380649e-23; % J/K
e = 1.602176634e-19; % C
refill_gas = ismember(input.Spe.PSpecies, input.Spe.Refill_gases) & input.Spe.Q == 0;
kappa = @(T_g_eV, BTg, CTg) (300/(T_g_eV*e/k_B))^BTg*exp(-CTg/(T_g_eV*e/k_B)); % for Thorsteinsson's stuff % FIXME
for j = 1:length(input.Rea.reactions)
    coeffs = input.Rea.reactions(j).coeffs;
    % NOTE: only 1, 2, 6, 7, 8 and 9 are actually used
    % 1 is generalized arrhenius and remaining are polynomial
    % -> can be vectorized easily (requires some coefficient
    % transformations)
    % (c1+c2*T+c3*T^c4)*exp(-c5/T)
    switch input.Rea.reactions(j).coef_type
        case 1
            input.Rea.cfs(j,3) = coeffs(1);
            input.Rea.cfs(j,4) = coeffs(2);
            input.Rea.cfs(j,5) = coeffs(3);
        case 2
            input.Rea.cfs(j,1) = coeffs(1);
        case 6
            input.Rea.cfs(j,1) = coeffs(3);
            input.Rea.cfs(j,2) = coeffs(2);
            input.Rea.cfs(j,3) = coeffs(1);
        case 7
            input.Rea.cfs(j,1) = coeffs(3)/coeffs(4);
            input.Rea.cfs(j,2) = coeffs(2)/coeffs(4);
            input.Rea.cfs(j,3) = coeffs(1)/coeffs(4);
        case 8
            input.Rea.cfs(j,1) = coeffs(1);
            input.Rea.cfs(j,2) = -coeffs(2);
        case 9
            input.Rea.cfs(j,1) = coeffs(1);
            input.Rea.cfs(j,2) = coeffs(2);
            input.Rea.cfs(j,5) = coeffs(3);
        case -1
            % This is thorsteinsson's format
            % A notable difference is, that the gas temperature has to be
            % taken into account for some reactions (N2 mainly).
            % TODO : implement generalized arrhenius fitting for thorsteinsson's code
            K_gas = 1;
            if any(coeffs(4:5) ~= 0)
                T_g_eV = input.Spe.T(logical(input.Rea.R(j,:)) & refill_gas);
                % if length(T_g_eV) ~= 1
                %     warning('wrong number of refill gas species: %s', string(join(Rea.Rcell{j},' ')));
                % end
                T_g_eV = mean(T_g_eV);
                K_gas = kappa(T_g_eV, coeffs(4), coeffs(5));
            end
            input.Rea.cfs(j,3) = coeffs(1)*K_gas;
            input.Rea.cfs(j,4) = coeffs(2);
            input.Rea.cfs(j,5) = coeffs(3);
        otherwise
            error("Rate coefficient types 3, 4 and 5 are no longer supported.");
    end
end

end

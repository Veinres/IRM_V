function [pb] = powerBalance(output, input, options)
%POWERBALANCE compute the individual terms in the energy balance
% =========================================================================
% Extract the individual terms of the power balance equation from the
% simulation output.
%
% See also plt.run.species.powerBalance
%
% ARGUMENTS ---------------------------------------------------------------
%
%   output      (struct), the output produced using rslt.run.output
%
%   input       (struct), the input used for the simulation run
%
% NAME-VALUE --------------------------------------------------------------
%
%   'ConsistentCurrent' (double), parent in which to plot % FIXME should go into input
%
%   'K1'        (double), applied power fraction % FIXME should go into input
%
% RETURN ------------------------------------------------------------------
%
%   pb          (struct), struct containing terms of the energy balance
%
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ NOTE ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This function requires Matlab 2019b or later.
% =========================================================================

%% NOTES: -----------------------------------------------------------------
% BE AWARE THAT THERE IS SOME DANGER THAT THIS MIGHT BECOME OUT OF SYNC
% WITH WHAT IS IMPLEMENTED IN THE ACTUAL ODE.
%
% I decided against putting the energy balance into a separate function for
% performance reasons, but this should be considered when overhauling
% ODEfile.m.
%
% ALSO : Might produce unexpected results when using diatomic/polyatomic
% gases and thus new classes of reactions.
% -------------------------------------------------------------------------

%% Argument parsing and validation
arguments
    output struct
    input struct
    options.ConsistentCurrent double = 0
    options.K1 double = 0.5
end

if isfield(input.IP, 'consistent_current') && input.IP.consistent_current
    options.ConsistentCurrent = input.IP.consistent_current;
end
if isfield(input.IP, 'K1')
    options.K1 = input.IP.K1;
end

if options.ConsistentCurrent > 0 && options.ConsistentCurrent <= 1
    Id_p = ...
        options.ConsistentCurrent*( ...
        sum(output.I(:,input.Range.ion),2) + sum(output.I_se(:,input.Range.ion),2)) ...
        + (1-options.ConsistentCurrent)*output.dis_Id;
else
    Id_p = output.dis_Id;
end

n_ts = length(output.t);
n_reactions = length(input.Rea.reactions);

pb.msk = struct();
pb.applied = options.K1*output.dis_Uir.*Id_p/phys.const.e/input.Para.V_IR; % eV/s/m3 % THIS IS MISLABELED
pb.Ohm_heat = sum(output.I_se(:,input.Range.ion)./input.Spe.Q(input.Range.ion),2).*output.dis_Ush/phys.const.e/input.Para.V_IR; % eV/s/m3 % THIS IS MISLABELED

Rtmp = input.Rea.R;
Rtmp(:,1:2) = false;
reactant = zeros([1,size(input.Rea.R, 1)]); % TODO : precompute
for i = 1:size(input.Rea.R, 1)
    reactant(i) = find(Rtmp(i,:), 1, "first");
end

if ismember('Ar', input.Spe.Refill_gases)
    % FIXME / compatibility Ar
    input.Spe.Energy(input.Spe.s.Arm3P0) = 11.56;
    input.Spe.Energy(input.Spe.s.Arm3P2) = 11.56;
end

if ismember('He', input.Spe.Refill_gases)
    % FIXME / compatibility HeMo
    input.Spe.Energy(input.Spe.s.He2P012) = 20.69;
    input.Spe.Energy(input.Spe.s.He2P1) = 21.218;
end

n_prod_e = 1; % TODO : verify that there is no ionisation reaction freeing more than electron

msk = input.Rea.Range.ionC;
pb.msk.ion_c = msk;
pb.izc_cost = zeros([n_ts, n_reactions]);
pb.izc_cost_dnedt = zeros([n_ts, n_reactions]);
pb.izc_cost(:,msk) = output.Rate(:,msk).*output.Ecc(:,reactant(msk));
pb.izc_cost_dnedt(:,msk) = output.Rate(:,msk).*(3/2*n_prod_e*output.T_ec);

msk = input.Rea.Range.ionH;
pb.msk.h2c = msk;
pb.hot2cold = zeros([n_ts, n_reactions]);
pb.hot2cold(:,msk) = output.Rate(:,msk)*input.Para.U_htc;

msk = input.Rea.Range.ionH;
pb.msk.ion_h = msk;
pb.izh_cost = zeros([n_ts, n_reactions]);
pb.izh_cost_dnedt = zeros([n_ts, n_reactions]);
pb.izh_cost(:,msk) = output.Rate(:,msk).*output.Ech(:,reactant(msk));
pb.izh_cost_dnedt(:,msk) = output.Rate(:,msk)*input.Para.U_htc;

if strcmp('C', input.Spe.Target{1}) % FIXME
    % In carbon version, excitations are also included
    msk = input.Rea.Range.excC;
else
    msk = find(contains(input.Rea.tags, 'dexc')).'; % TODO : precompute
end
pb.msk.deex_c = msk;
pb.deex_c = zeros([n_ts, n_reactions]);
pb.deex_c(:,msk) = output.Rate(:,msk).*input.Spe.Energy(reactant(msk));
% deex_c = dot(Rate(msk), Rea.Vif(msk));

if strcmp('C', input.Spe.Target{1}) % FIXME
    % In carbon version, excitations are also included
    msk = input.Rea.Range.excH;
else
    msk = find(contains(input.Rea.tags, 'dexh')).'; % TODO : precompute
end
pb.msk.deex_h = msk;
pb.deex_h = zeros([n_ts, n_reactions]);
pb.deex_h(:,msk) = output.Rate(:,msk).*input.Spe.Energy(:,reactant(msk));
% deex_h = dot(Rate(msk), Rea.Vif(msk));

msk = input.Rea.Range.penning;
% deex_P = dot(Rate(msk), sum(Spe.Energy(Rtmp(msk,:)),2) - sum(Spe.Energy(Ptmp(msk,:)),2) - 3/2*T_ec);
pb.msk.deex_P = msk;
pb.deex_P = zeros([n_ts, n_reactions]);
pb.deex_P_dnedt = zeros([n_ts, n_reactions]);
pb.deex_P(:,msk) = -output.Rate(:,msk).*input.Rea.Vif(msk);
pb.deex_P_dnedt(:,msk) = -output.Rate(:,msk).*(3/2*n_prod_e*output.T_ec);

if strcmp('Mo', input.Spe.Target{1})
    % FIXME / compatibility HeMo
    pb.deex_P(:,:) = 0;
    pb.deex_P_dnedt(:,:) = 0;
    pb.izc_cost = 40*pb.izc_cost;
    pb.izc_cost_dnedt = 40*pb.izc_cost_dnedt;
end

end

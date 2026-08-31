function [results, analysed, additional] = analyse(input, output, options)
%ANALYSE compute interesting properties from irm run output
% =========================================================================
% The computed properties include the FOM, ionised flux fraction and flux
% parmeters alpha and beta
%
%   See also: rslt.run.output, rslt.run.fom
%
% ARGUMENTS ---------------------------------------------------------------
%
%   input       (struct), input used for IRM run
%
%   output      (struct), output from IRM run (see rslt.run.output)
%
% NAME-VALUE --------------------------------------------------------------
%
%   'SaveLocation'  (char), directory where .mat files should be saved
%                       By default, nothing is saved.
%
%   'Compatibility' (logical, default=false), whether to use old computations
%                       Only use to check against old data.
%                       There will still be some differences, especially
%                       for alpha_R and alpha_R_all. But F_flux and thus
%                       the fitting should be the same.
%
% RETURN ------------------------------------------------------------------
%
%   results     (struct), struct containing properties required for fitting
%
%   analysed    (struct), struct also containing flux parameters
%
%   additional  (struct), some other variables - will be discontinued
%
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ NOTE ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This function requires Matlab 2019b or later.
% =========================================================================

%% NOTES: -----------------------------------------------------------------
% This is just meant to be temporary unitl the entire I/O has been
% overhauled.
% -------------------------------------------------------------------------

%% Argument parsing and validation
arguments
    input struct
    output struct
    options.SaveLocation char = ''
    options.Compatibility = false;
end

%% Fitting Parameters
results.r = input.Para.r;
results.beta1 = input.Para.beta;
results.f = input.Para.f;

%% Pulse information
i_pulse_end = find(output.t >= input.IP.pulseLength, 1);
i_solver_end = length(input.solver.time);
i_IRM_end = length(output.t);
if isempty(i_pulse_end)
    % calculate properties from results up until the simulation run failure
    % if simulation failed before the end of the pulse
    i_pulse_end = i_IRM_end;
end

%% Compute FOM
% Only the current up until the end of the pulse is considered when
% computing the FOM.
% If the simulation run terminated before reaching the end of the pulse,
% the IRM current is assumed zero, and the reference current is
% interpolated from the measured current in the discharge structure.
i_fom_end = find(input.solver.time >= input.IP.pulseLength, 1);

I_se = sum(output.I_se,2);
I_ion = sum(output.I,2);
I_IRM = I_se + I_ion;

t_FOM = input.solver.time;
I_FOM = zeros([i_solver_end, 1]);
I_FOM(1:i_IRM_end) = I_IRM;
I_ref = zeros([i_solver_end, 1]);
I_ref(1:i_IRM_end) = output.dis_Id;
I_ref(i_IRM_end+1:i_fom_end) = interp1(input.disch.T, input.disch.I, ...
    t_FOM(i_IRM_end+1:i_fom_end));

[results.fom, results.foms] = rslt.run.fom( ...
    I_ref(1:i_fom_end), I_FOM(1:i_fom_end), t_FOM(1:i_fom_end), ...
    'method', 'max', 'weights', '1+lin');

% fom_old = sqrt((max(dis_Id)-max(I_tot))^2); % C
% fom_old = sqrt((max(dis_Id)-max(I_tot))^2); % Cu

%% Preparation
% define species logical masks
target      = ismember(input.Spe.PSpecies, input.Spe.Target);
working_gas = ismember(input.Spe.PSpecies, input.Spe.Refill_gases);
ion         = false(size(target)); ion(input.Range.ion) = true;
refill      = false(size(target)); refill(input.Range.refill) = true;
meta        = false(size(target)); meta(input.Range.meta) = true;
sput        = false(size(target)); sput([input.Range.sput_metal,input.Range.sput_gas]) = true;
kickout     = false(size(target)); kickout(input.Range.kickout) = true;
grd         = ismember(input.Spe.Names, input.Spe.Target) | ...
              ismember(input.Spe.Names, input.Spe.Refill_gases);
% define reactions logical masks
target_ion  = input.Spe.Names{ismember(input.Spe.PSpecies, input.Spe.Target) & input.Spe.Q == 1};
if options.Compatibility
    % Note: Cui -> Cuii used to be included as well
    % Note: only one penning reaction used to be included
    ionisation = cellfun(@(P) ismember(target_ion, P), input.Rea.Pcell) ;
    %| cellfun(@(P) ismember(strcat(target_ion,'i'), P), input.Rea.Pcell);
else
    ionisation = cellfun(@(R) ~ismember(target_ion, R), input.Rea.Rcell) & ...
        cellfun(@(P) ismember(target_ion, P), input.Rea.Pcell);
end

% A small correction trick:
% we add the difference of the density to the initial density
% to account for the fluxes between the end of the simulated time frame
% and the start of the next pulse
output.Diffrate(end, :) = output.Diffrate(end,  :) + ...
    (output.n(end, 1:end-1) - output.n(1, 1:end-1))*input.Para.V_IR/1e-6;
% we also do something similar for the ions still left in the IR after
% ther end of the simulated time frame
output.GAMMA_ion_BP(end, ion) = output.GAMMA_ion_BP(end, ion) + ...
    (output.n(end, ion) - output.n(1, ion))*input.Para.V_IR/1E-6;
% NOTE: for a reasonable choice of the simulated time frame, these
% corrections should be very small (with the exception of the refill
% gases)

flux_i = sum(output.GAMMA_ion_BP(:, target & ion), 2)*input.Para.S_BP; % in 1/s
flux_n = sum(output.Diffrate(:, target & ~ion), 2)*input.Para.V_IR; % in 1/s
if options.Compatibility
    % Note: we used to not take the afterglow into account, therefore there
    % might be some notable differences to results from old runs. Properties
    % that are affect include in particular the ionised flux fraction.
    tot_flux_i = sum(flux_i(1:i_pulse_end));
    tot_flux_n = sum(flux_n(1:i_pulse_end));
else
    tot_flux_i = sum(flux_i);
    tot_flux_n = sum(flux_n);
end
if options.Compatibility
    R_sput = sum(output.sputrate(:,:, target & sput & grd), 2); %changed from R_sput = sum(output.sputrate(:, target & sput & grd), 2);
    R_ion = sum(output.Rate(:, ionisation), 2);
else
    R_sput = sum(output.sputrate(:,:, target & sput), 2); % changed from R_sput = sum(output.sputrate(:, target & sput), 2);
    R_ion = sum(output.Rate(:, ionisation), 2);
end

xi_n_over_xi_i = 2; % transport parameter ratio

%% Compute Flux and Flux parameter

results.F_flux = (1 + xi_n_over_xi_i*tot_flux_n/tot_flux_i)^(-1);

if nargout > 1 || ~isempty(options.SaveLocation)
    % Analysed - flux parameters including variations
    analysed.r      = results.r;
    analysed.beta1  = results.beta1;
    analysed.f      = results.f;
    analysed.fom    = results.fom;
    analysed.foms   = results.foms;
    analysed.F_flux = results.F_flux;

    if options.Compatibility
        analysed.F_density = sum(output.n(1:i_pulse_end, target & ion & input.Spe.Q == 1), "all")/ ... % FIXME: switch to second version
            sum(output.n(1:i_pulse_end, target & (grd | input.Spe.Q == 1) ), "all"); % This has questionable meaning % FIXME: switch to second version
    else
        analysed.F_density = sum(output.n(1:i_pulse_end, target & ion), "all")/ ...
            sum(output.n(1:i_pulse_end, target), "all"); % This has questionable meaning
    end
    
    test_value1=sum(R_ion(1:i_pulse_end));
    test_value2=sum(R_sput(1:i_pulse_end));
    analysed.alpha_R = sum(R_ion(1:i_pulse_end))/sum(R_sput(1:i_pulse_end)); % This has questionable meaning
    analysed.alpha_R_all = sum(R_ion)/sum(R_sput);
    analysed.alpha_F_flux = analysed.F_flux/(1 - input.Para.beta + input.Para.beta*analysed.F_flux);
    analysed.beta_av = sum(output.GAMMA_ion_RT(:, target & ion), "all")*input.Para.S_RT/...
        (input.Para.S_RT*sum(output.GAMMA_ion_RT(:, target & ion), "all") + ...
         input.Para.S_BP*sum(output.GAMMA_ion_BP(:, target & ion), "all"));

    analysed.hall = input.Para.f; % FIXME : remove

    if options.Compatibility
        analysed.GAMMA_0_all = sum(output.sputrate(:,:, target & sput & grd), "all"); % in 1/s
        analysed.GAMMA_BP_all = sum(output.Diffrate(:, target & grd), "all") + ...
            (input.Para.S_BP/input.Para.V_IR)*sum(output.GAMMA_ion_BP(:, target & ion), "all"); % in 1/s
    else
        analysed.GAMMA_0_all = sum(output.sputrate(:,:, target & sput & ~ion), "all"); % in 1/s
        analysed.GAMMA_BP_all = sum(output.Diffrate(:, target & ~ion), "all") + ...
            (input.Para.S_BP/input.Para.V_IR)*sum(output.GAMMA_ion_BP(:, target & ion), "all"); % in 1/s
    end
    analysed.Fdep_alphabeta = 1 - (analysed.alpha_R*analysed.beta_av);
    analysed.Fdep_Gamma = analysed.GAMMA_BP_all/analysed.GAMMA_0_all;

    if ~isempty(options.SaveLocation)
        save(fullfile(options.SaveLocation,'Analysed'), "-struct", "analysed");
    end

    % Additional - some random stuff for compatibility - will be removed
    if nargout > 2
        warning("Export of additional data is only included for compatibility and will be removed.");
        additional.pulse.width = input.Para.pulseLength;
        additional.pulse.time_end_i = i_pulse_end;
        additional.pulse.time_i = 1:i_pulse_end;
        additional.alpha_R_t = R_ion(1:i_pulse_end)./R_sput(1:i_pulse_end);
        additional.alpha_R_t_all = R_ion./R_sput;
        additional.(sprintf('R_sput_%s', input.Spe.Target{1})) = R_sput(1:i_pulse_end);
        additional.(sprintf('R_sput_%s_all', input.Spe.Target{1})) = R_sput;
        additional.(sprintf('R_iz_%s', input.Spe.Target{1})) = R_ion(1:i_pulse_end);
        additional.(sprintf('R_iz_%s_all', input.Spe.Target{1})) = R_ion;
        F_flux_t = (1 + S_i/S_n*flux_n./flux_i).^(-1);
        additional.alpha_F_flux_t = F_flux_t./(1 - input.Para.beta + input.Para.beta*F_flux_t);
        if ~isempty(options.SaveLocation)
            save(fullfile(options.SaveLocation,'Additional'), "-struct", "additional");
        end
    end
end

end

function [k, fig, ks] = rateCoeffFromCS(E, sigma, Te, options)
%RATECOEFFFROMCS Compute a rate coefficient from CS and temperature
% =========================================================================
% Compute a rate coefficient given a energy depenent
% cross-section and assuming a Maxwellian EEDF:
%
%   f(E) = 2*(E/pi)^(1/2)*(beta)^(3/2)*exp(-beta*E)
%   beta = 1/(kB*T)
%
%   k(T) = int_0^Inf sigma(E)*v(E)*f(E) dE
%   v(E) = (2*E/me)^(1/2)
%
%   v(E)*f(E) = (8/(me*pi))^(1/2)*beta^(3/2)*E*exp(-beta*E)
%
% ARGUMENTS ---------------------------------------------------------------
%
%   E           (double, (:,1)), electron energy
%
%   sigma       (double, (:,1)), crossection sigma(E) at energy E
%
%   Te          (double, (1,:)), electron temperature range for output
%                   The unit is assumed to be the same as the one used for
%                   the energy
%
% NAME-VALUE --------------------------------------------------------------
%
%   'Plot'      (logical, default=false) Whether to produce plots
%
%   'PlotExtra' (logical, default=false) Whether to produce additional plots
%
% RETURN ------------------------------------------------------------------
%
%   k           (double, (1,:)), average of rho at a temperature Te
%
%   fig         (figure handle or empty), figure handle if Plot on
%
%   ks          (double, (:,:)), cumultative integrals (only computed if
%                   output argument is present)
%
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ NOTE ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Caller is responsible for assuring correct input format/orientation.
% =========================================================================

arguments
    E (:,1) double
    sigma (:,1) double
    Te (1,:) double
    options.Plot logical = false
    options.PlotExtra logical = false
end

me = 9.10938188e-31; % kg

beta = 1./Te;
v_fE = sqrt(8/(me*pi))*beta.^(3/2).*E.*exp(-beta.*E);

if nargout < 3
    ks = [];
    k = trapz(E,sigma.*v_fE,1);
else
    ks = cumtrapz(E,sigma.*v_fE,1);
    k = ks(end,:);
end

if options.Plot
    fig(1) = plotK(Te, k);
    if options.PlotExtra
        fig(2) = plotSigma(Te, v_fE, E, sigma);
        if ~isempty(ks)
            fig(3) = plotKS(E, Te, ks);
        end
    end
end

end

%% function defintions

function fig = plotK(Te, K)
    fig = figure;
    plot(Te, K);
    xlabel('$T_{\rm e}$ [$\rm eV$]');
    ylabel('$\langle v\,\sigma \rangle$ [$\rm m^{3}s^{-1}$]');
    set(gca, 'xscale', 'log');
    set(gca, 'yscale', 'log');
    ylims = ylim();
    ylims(1) = max(1e-30, ylims(1));
    ylim(ylims);
    % xlim([max(min(Te),1e-1), max(Te)]);
end

function fig = plotSigma(Te, v_fE, E, sigma)
    fig = figure;
    plot(E, sigma);
    xlabel('$\epsilon_{\rm e}$ [$\rm eV$]');
    ylabel('$\sigma$ [$\rm m^{-2}$]');
    set(gca, 'xscale', 'log');
    set(gca, 'yscale', 'log');
    ylims = ylim();
    ylims(1) = max(1e-30, ylims(1));
    ylims(2) = max(1e-10, max(sigma)*1.1);
    ylim(ylims);
    % xlim([max(min(E),1e-2), max(E)]);
end

function fig = plotKS(E, Te, Ks)
    fig = figure;
    [Tes, Es] = meshgrid(Te, E);
    % surf(Tes(1:10:end,1:10:end), Es(1:10:end,1:10:end), Ks(1:10:end,1:10:end));
    % contourf(Tes, Es, log10(abs(1-Ks./Ks(end,:))), 11);
    contourf(Tes, Es, abs(1-Ks./Ks(end,:)), 11);
    cb = colorbar();
    cb.Label.Interpreter = 'latex';
    cb.Label.String = '$\left\vert\delta\langle v\,\sigma\rangle\right\vert$';
    cb.Limits =[0,1];
    hold on;
    % msk = 1:1:length(Te);
    % emsk = 2:1:length(E);
    % c = colororder();
    % for i = 2:1:length(E)
    %     plot3(Te(msk), E(i)*ones(size(msk)), abs(Ks(i,msk)-Ks(end,msk))./Ks(end,msk), 'Color', c(1,:)*(i/length(E)));
    % end
    xlabel('$T_{\rm e}$ [$\rm eV$]');
    ylabel('$E_{\rm max}$ [$\rm eV$]');
    % zlabel('$\langle v\,\sigma \rangle$ [$\rm m^{3}s^{-1}$]');
    set(gca, 'xscale', 'log');
    set(gca, 'yscale', 'log');
    % set(gca, 'zscale', 'log');
    % view(90,0)
    % zlims = zlim();
    % zlims(1) = max(zlims(1),1e-30);
    % zlim(zlims);
    ylims = ylim();
    ylims(1) = max(1e-2, ylims(1));
    ylim(ylims);
    % xlims = xlim();
    % xlims(1) = max(1e-2, xlims(1));
    % xlim(xlims);
end

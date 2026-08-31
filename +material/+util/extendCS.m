function [E_new, sigma_new, fig] = extendCS(E, sigma, E_new, options)
%EXTENDCS Inter/extrapolate crossections.
% =========================================================================
% Given a tabulated crosssection sigma(E) calculates the value of the
% crosssection at the energies specified by E_new. Between the known values,
% the crosssection is interpolated. By default, the energies above or
% below the known vlaues are extrapolated.
%
% ARGUMENTS ---------------------------------------------------------------
%
%   E           (double, (:,1)), electron energy
%
%   sigma       (double, (1,:)), crosssection sigma(E) at energy (E)
%
% NAME-VALUE --------------------------------------------------------------
%
%   'InterpMethod'      (char, default='linear'), interpolation method
%                           The same as in interp1.
%
%   'ThresholdEnergy'   (double, default=0), energy below which the
%                           crosssection is set to zero.
%                           Setting the threshold energy to a negative
%                           value will set the crosssection to zero at
%                           values below the minimum known one.                         
%
%   'HighEnergyExtrap'  (char, default='extrap'), extrapolation method for 
%                           energies above the known values.
%                           Available options:
%                           - 'extrap': extrapolate using the interpolation
%                                     method (same as in interp1)
%                           - 'invsqrt': extrapolate as E^(-1/2)
%                           - 'lower': the lower of the former two
%                           - 'const': extrapolate with the last known value
%                           - 'zero': extrapolate with zero
%
%   'XLogTrans'         (logical, default=true), wether to transform the
%                           the energies to log scale before interpolation
%
%   'YLogTrans'         (logical, default=true), wether to transform the
%                           the crossection to log scale before interpolation
%
%   'Plot'              (logical, default=false), wether to plot the
%                           interpolated crosssection
%
% RETURN ------------------------------------------------------------------
%
%   E_new       (double, (:,1)), new electron energy
%
%   sigma_new   (double, (:,1)), new crossection values
%
%   fig         (figure handle or empty), figure handle if Plot on
%
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ NOTE ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Requires Matlab 2019b or newer.
% =========================================================================

arguments
    E (:,1) double
    sigma (:,1) double {util.valid.mustBeSameSize(sigma, E)}
    E_new (:,1) double
    options.InterpMethod char {mustBeMember(options.InterpMethod, ...
        {'linear', 'nearest', 'next', 'previous', 'pchip',...
        'cubic', 'v5cubic', 'makima', 'spline'})} = 'linear'
    options.ThresholdEnergy (1,1) double = -1
    options.HighEnergyExtrap char {mustBeMember(options.HighEnergyExtrap, ...
        {'extrap','invsqrt','lower','const','zero'})} = 'extrap'
    options.XLogTrans logical = true
    options.YLogTrans logical = true
    options.Plot logical = false
end

finite = isfinite(E) & isfinite(sigma);
if sum(finite) ~= length(sigma)
    warning("Non-finite elements have been removed.");
    E = E(finite);
    sigma = sigme(finite);
end

[E, ia] = unique(E);
if length(ia) ~= length(sigma)
    warning("Non-unique energy values have been removed.");
    sigma = sigma(ia);
end

if options.XLogTrans
    E = log(E + 1e-300);
    E_new = log(E_new);
end
if options.YLogTrans
    sigma = log(sigma + 1e-300);
end

sigma_new = interp1(E, sigma, E_new, options.InterpMethod, 'extrap');

if options.XLogTrans
    E = exp(E);
    E_new = exp(E_new);
end
if options.YLogTrans
    sigma = exp(sigma);
    sigma_new = exp(sigma_new);
end

if options.ThresholdEnergy < 0
    options.ThresholdEnergy = min(E);
end
sigma_new(E_new < options.ThresholdEnergy) = 0;

high_E_msk = E_new > E(end);
switch options.HighEnergyExtrap
    case 'invsqrt'
        sigma_new(high_E_msk) = sigma(end).*sqrt(E(end)./E_new(high_E_msk));
    case 'lower'
        sigma_invsqrt = sigma(end).*sqrt(E(end)./E_new(high_E_msk));
        sigma_new(high_E_msk) = min(sigma_invsqrt, sigma_new(high_E_msk));
    case 'const'
        sigma_new(high_E_msk) = sigma(end);
    case 'zero'
        sigma_new(high_E_msk) = 0;
    case 'fit'
        error("'fit' extrapolation method is not yet implemented."); % TODO : implement
    otherwise % 'extrap'
        % interp already did the extrapolation
        if ~( max(sigma_new(high_E_msk)) < E(end) )
            warning("Non-degreasing high energy extrapolation");
        end
end

if options.Plot
    fig = plotCS(E, sigma, E_new, sigma_new, options.ThresholdEnergy);
end

end

%% function defintions

function fig = plotCS(E, sigma, E_new, sigma_new, E_th, fig)
    if exist('fig', 'var') && ~isempty(fig)
        fig = figure(fig);
    else
        fig = figure();
    end
    hold on;
    h = [];
    h(1) = scatter(E, sigma, 'filled');
    h(2) = plot(E_new, sigma_new);
    xlabel('$\epsilon$ [$\rm eV$]');
    ylabel('$\sigma$ [$\rm m^2$]');
    set(gca, 'XScale', 'log');
    set(gca, 'YScale', 'log');
    ylims = ylim();
    ylims(1) = max(ylims(1), 1e-30);
    if exist('E_th','var') && ~isempty(E_th)
        plot(E_th*[1,1], [1e-300,1e+300], 'k:');
    end
    legend(h, {'original', 'interpolated'});
    ylim(ylims);
end


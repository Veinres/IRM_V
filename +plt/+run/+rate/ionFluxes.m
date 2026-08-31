function [fig] = ionFluxes(output, input, options)
%IONFLUXES plot the ion fluxes towards the race track and/or bulk plasma
% =========================================================================
% The ion fluxes can be plotted either as actual fluxes, or as the
% resulting rate.
%
% See also plt.run.util.perSpeciesProperty
% ARGUMENTS ---------------------------------------------------------------
%
%   output      (struct), the output produced using rslt.run.output
%
%   input       (struct), the input used for the simulation run
%
% NAME-VALUE --------------------------------------------------------------
%
%   'Parent'    (figure or axes object), parent in which to plot
%
%   'XLim'      (double (1,2)), x axis limits
%                   By default the limits are not modified.
%
%   'YLim'      (double (1,2)), y axis limits
%                   By default the limits are not modified.
%
%   'Mask'      (logical (:,1) or double (:,1)), valid species index/mask
%
%   'UnitsOf'   (char, default='Flux')
%                   - 'flux' : plot actual fluxes
%                   - 'rate' : plot rates instead
%
%   'Towards'   (char, default='both')
%                   - 'RT'   : only plot fluxes towards racetrack
%                   - 'BP'   : only plot fluxes towards bulk plasma
%                   - 'both' : plot both
%
%   'SpeciesColors'(double (:,3)), colors to be used for species
%
% RETURN ------------------------------------------------------------------
%
%   fig         (figure handle), plotted figure
%
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ NOTE ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This function requires Matlab 2019b or later.
% =========================================================================

%% NOTES: -----------------------------------------------------------------
% -------------------------------------------------------------------------

%% Argument parsing and validation
arguments
    output struct
    input struct
end
arguments
    options.Parent = []
    options.Mask (:,1) = []
    options.XLim (1,2) double = [NaN,NaN]
    options.YLim (1,2) double = [NaN,NaN]
    options.UnitsOf char {mustBeMember(options.UnitsOf, {'flux', 'rate'})} = 'flux'
    options.Towards char {mustBeMember(options.Towards, {'RT','BP','both'})} = 'both'
    options.SpeciesColors (:,3) double = []
end

[fig, ax] = util.fig.getAx(options.Parent);
options.Parent = ax;

if isempty(options.Mask)
    n_species = length(input.Spe.Names);
    options.Mask = 1:n_species;
end
options.Mask = util.mask.op(options.Mask, input.Range.ion, @intersect);

if strcmp(options.UnitsOf, 'flux')
    varn = '$\Gamma$';
    units = '[$\rm m^{-2}\,s^{-1}$]';
else
    varn = '$\frac{{\rm d}n}{{\rm d}t}$';
    units = '[$\rm m^{-3}\,s^{-1}$]';
end

options.YLabel = strcat(varn, ' ', units); 
options.XLabel = '$t$ [$\rm \mu s$]';

options2 = rmfield(options, 'UnitsOf');
options2 = rmfield(options2, 'Towards');
if ~strcmp(options.Towards, 'BP')
    if strcmp(options.UnitsOf, 'rate')
        options2.YTrans = @(x) input.Para.S_BP/input.Para.V_IR*x;
    end
    if strcmp(options.Towards, 'both')
        options2.LgndStrTrans = @(spe) sprintf('BP %s', spe);
    end
    options2.PltArgs = {'LineStyle', '--'};
    options_ = namedargs2cell(options2);
    plt.run.util.perSpeciesProperty(output, input, 'GAMMA_ion_RT', options_{:});
end
if ~strcmp(options.Towards, 'RT')
    if strcmp(options.UnitsOf, 'rate')
        options2.YTrans = @(x) input.Para.S_RT/input.Para.V_IR*x;
    end
    if strcmp(options.Towards, 'both')
        options2.LgndStrTrans = @(spe) sprintf('RT %s', spe);
    end
    options2.PltArgs = {'LineStyle', '-'};
    options_ = namedargs2cell(options2);
    plt.run.util.perSpeciesProperty(output, input, 'GAMMA_ion_BP', options_{:});
end

end

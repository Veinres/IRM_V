function [filename, output] = effectiveCost(species, options)
%MATERIAL.EFFECTIVECOST create the structure containing EC data
% =========================================================================
% Generate a structure containing the effective energy cost per
% ion/electron pair generated from a given species.
% ARGUMENTS ---------------------------------------------------------------
%
%   species     (table/struct), species table
%                   A table containing species information as produced by
%                   the material.species function. A legacy species
%                   struct compatible with IRM v1.2 is also supported.
%
% Name-Value --------------------------------------------------------------
%
%   Output      (string, optional, default: 'legacy'), Output type
%                   Possible options are:
%                       - 'default' default output structure % FIXME
%                       - 'table'   table output
%                                   (NOTE: this is intended for easy
%                                   inspection and not for computationally
%                                   heavy tasks, as tables in matlab are
%                                   slow)
%                       - 'legacy'  legacy output structure compatible with
%                                   IRM v1.2
%
%   Filename    (string, optional), Output file path (relative to irm root
%                   directory or absolute)
%                   By default, the output is written to
%                   '+material/reactions/<gas><target>.mat' where <gas> and
%                   <target> are the element symbols of the working gas and
%                   target material respectively. For lagacy output, the
%                   prefix 'Ec_' is added to the default filename.
%
% Return ------------------------------------------------------------------
%
%   filename    (string), Output file path
%
%   output      (struct/table), generated output. Struct or table depending
%                   on output option.
%
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ NOTE ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This function requires Matlab R2020b or later.
% =========================================================================

%% NOTES: -----------------------------------------------------------------
% Background:
%
% The effective cost of ionisation designates the energy lost by the
% electron population per created electron-ion pair and is calculated on a
% per ionizable species basis.
%
% After Lieberman 2005, p.81, eq. 3.5.8, for some species 'a' that
% can be ionised to create a (e-, a+) pair:
%
% n_a*K_{iz,a}*E_{c,a} = n_a*K_{iz,a}*E_{iz,a} + n_a*K_{ex,a}*E_{ex,a} +
%                        n_a*K_{el,a}*E_{el,a} + ...
%                      = n_a*sum_{b=e. procsses} K_{b,a}*E_{b,a}
% 
% where the sum is over all processes involving species 'a' and electrons.
% For atomic species in particular, these are ionization, excitation, and
% elastic (polarization) scattering. In molecular discharges, additional 
% losses are created through association, dessociation as well as
% vibrational and rotational excitation.
%
% To get to effective cost, we can normalise by n_A*K_{iz,a} (c.f.
% Gudmundsson 2002, p. 2), leading to:
%
% E_{c,a} = E_{iz,a} + sum_{b=e. procsses} K_{b,a}/K_{iz,a}*E_{b,a}
%
% To avoid counting something twice, it is however important that we only
% include processes that are not already explicitly taken into account in
% the plasma chemistry - e.g. for the ionisation of ground state Ar,
% we do not include the exitation to Arm3P0, if an Arm3P0 population and
% a corresponding reaction are included in the model.
%
% The different rate coefficients/cross-sections and energies have to be
% taken from literature, however for energy loss due to elastic scattering
% on neutrals there is a simple expression:
%
% E_{el,a} = 3*m_e/M_a*T_e
%
% -------------------------------------------------------------------------

%% Argument parsing and validation
arguments
    % positional arguments
    species     {material.util.valid.mustBeValidSpeciesInfo}
    % optional name-value pairs
    options.Output char {mustBeMember(options.Output,{...
                                'default',...       % default output structure
                                'legacy',...        % legacy output structure
                                'table'...          % table output for visual inspection
                                })} = 'legacy' % FIXME !!!
    options.Filename {mustBeTextScalar(options.Filename)} = ''
end

%%


if ismember({'N2'}, species.Refill_gases)
    output = material.gas.N2.effectiveCosts(species, 'forceRegen', false);
    Ec = output;
    if isempty(options.Filename)
        options.Filename = fullfile('pre-cal/Ec', sprintf('Ec_%s.mat', ...
            string(join(horzcat(species.Refill_gases, species.Target), ""))));
    end
    
    if ~isempty(options.Filename)
        pth = fileparts(options.Filename);
        if ~exist(pth, 'dir')
            mkdir(pth)
        end
    end

    save(options.Filename, 'Ec');
    filename = options.Filename;
else
    warning('Not implemented yet. Using "create_Ec.m".');
    
    cd pre-cal/Ec/
    [~, output] = create_Ec(species);
    cd  ../../

    if ~isempty(options.Filename)
        pth = fileparts(options.Filename);
        if ~exist(pth, 'dir')
            mkdir(pth)
        end
        Ec = output;
        save(options.Filename, 'Ec');
        filename = options.Filename;
    end
end

end

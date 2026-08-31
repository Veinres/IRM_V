function [Ec] = effectiveCosts(species, options)
%EFFECTIVECOSTS generate table of nitrogen species reactions
% =========================================================================
% s.
% =========================================================================

%% NOTES: -----------------------------------------------------------------
% TODO : do this properly and uniformly for all elements
% -------------------------------------------------------------------------

arguments
    species struct {material.util.valid.mustBeValidSpeciesInfo}
    options.loadThorsteinsson logical = true
    options.forceRegen logical = false
    options.Plot logical = false
    options.PlotExtra logical = false
end

% ATM were just getting everything from thorsteinssons code
if options.loadThorsteinsson

    ec_file = fullfile(material.gas.N2.external.thorsteinsson.path, "ec.mat");
    if options.forceRegen || ~isfile(ec_file)
        material.gas.N2.external.thorsteinsson.importReactions;
    end
    ts_ec = load(ec_file);
    el_reactions = struct2table(ts_ec.energyloss);
    el_reactions.names = material.gas.N2.external.thorsteinsson.SpeciesTranslator.fromIndex(el_reactions.React);

    n_species = length(species.Names);

    ch = {'c','h'};
    Ec = struct();
    for i_ch = 1:2
        ec_struct = ts_ec.(sprintf('%ce', ch{i_ch}));
        Te = ec_struct.Te;

        Ec.(ch{i_ch}) = zeros([n_species, length(ec_struct.Te)]);
        Ec.(sprintf('Te%c_min', ch{i_ch})) = ec_struct.TeMIN;
        Ec.(sprintf('Te%c_max', ch{i_ch})) = ec_struct.TeMAX;
        Ec.(sprintf('dTe%c', ch{i_ch})) = Te(2) - Te(1);

        E_new = logspace(-3,4,701);
        n_rea = height(el_reactions);

        rea_types = unique(el_reactions.ReactType);
        rea_type = struct();
        for i_rt = 1:length(rea_types)
            rea_type.(rea_types{i_rt}) = strcmp(rea_types{i_rt}, el_reactions.ReactType);
        end

        KxE = zeros([n_rea,length(Te)]);
        cross_sections = struct();
        for i_rea = 1:n_rea
            E = ec_struct.EnergyLossConstants.CS(i_rea).Energy;
            sigma = ec_struct.EnergyLossConstants.CS(i_rea).sigma;
            [cross_sections(i_rea).E, cross_sections(i_rea).sigma] = material.util.extendCS(E, sigma, E_new, "HighEnergyExtrap", "lower");
            KxE(i_rea,:) = material.util.rateCoeffFromCS(cross_sections(i_rea).E, cross_sections(i_rea).sigma, Te)...
                .*el_reactions.Thresh(i_rea).*Te.^rea_type.el(i_rea);
        end
        % K_ex*E_ex, K_el*(3*m_e/M)*T_e

        for i_spe = 1:n_species
            spe_msk = strcmp(species.Names{i_spe}, el_reactions.names);
            if ~any(spe_msk); continue; end
            rea_msk = ~strcmp('iz', el_reactions.ReactType);
            Ec.(ch{i_ch})(i_spe,:) = el_reactions.Thresh(spe_msk & ~rea_msk) + ...
                sum(KxE(spe_msk & rea_msk,:), 1)./(KxE(spe_msk & ~rea_msk,:)/el_reactions.Thresh(spe_msk & ~rea_msk));
        end

        if options.PlotExtra
            for i_spe = 1:n_species
                spe_msk = strcmp(species.Names{i_spe}, el_reactions.names);
                if any(spe_msk)
                    figure;
                    title(sprintf("EC %s %s", ch{i_ch}, species.Names{i_spe}));
                    hold on;
                    xlabel('$T_e$ [eV]');
                    ylabel('$K_r\,\varepsilon_r$ [$\rm eV\,m^3\,s^{-1}$]');
                    set(gca, 'xscale', 'log');
                    set(gca, 'yscale', 'log');
                    legend();
                    for i_rt = 1:length(rea_types)
                        for i_rea = 1:height(el_reactions)
                            if ~spe_msk(i_rea) || ~rea_type.(rea_types{i_rt})(i_rea)
                                continue;
                            end
                            plot(Te(1:10:end), KxE(i_rea,1:10:end), ...
                                'DisplayName', sprintf("%d : %s %s", i_rea, el_reactions.ReactType{i_rea}, species.Names{i_spe}));
                        end
                    end
                end
            end
        end

        if options.Plot
            figure;
            title(sprintf('Ec %s', ch{i_ch}));
            hold on;
            xlabel('$T_e$ [eV]');
            ylabel('$\varepsilon_c$ [$\rm eV$]');
            set(gca, 'xscale', 'log');
            set(gca, 'yscale', 'log');
            legend();
            for i_spe = 1:n_species
                if any(Ec.(ch{i_ch})(i_spe,:) ~= 0)
                    plot(Te(1:10:end), Ec.(ch{i_ch})(i_spe,1:10:end), ...
                        'DisplayName', sprintf("%s", species.Names{i_spe}));
                end
            end
        end

    end
else
    error("Only Thorsteinsson's reactions are available ATM.");
end

end

function [reactions_table] = reactions(options)
%SPECIES generate table of argon/nitrogen species reactions
% =========================================================================
% Generate a table containing relevant argon/nitrogen species reactions.
% =========================================================================

%% NOTES: -----------------------------------------------------------------
% TODO : check if it would make sense to give the reactions unique names
% -------------------------------------------------------------------------

arguments
    options.loadThorsteinsson logical = true
    options.forceRegen logical = false
end

%% Reactions table --------------------------------------------------------
var_names       = {'name'       ,'reactants'    ,'products'         ,'eq_type'  ,'coeffs'                               ,'type' ,'source'};
% >> Ionisation from grd state --------------------------------------------
%                  name         reactants       products            eq_type     coeffs                                  type    source
% >> Ionisation from metastable state -------------------------------------
% >> Excitation from grd state --------------------------------------------
% >> Deexcitation ---------------------------------------------------------
% -------------------------------------------------------------------------

% reactions_cell = [grd_ion; ion_ion; meta_ion; grd_meta; meta_grd];
% reactions_table = cell2table(reactions_cell, 'VariableNames', var_names);
reactions_table = table('Size', [0,7], 'VariableTypes', {'cell', 'cell', 'cell', 'double', 'cell', 'cell', 'cell'}, 'VariableNames', var_names);

% ATM were just getting everything from thorsteinssons code
if options.loadThorsteinsson
    reactions_file = fullfile(material.gas.N2.external.thorsteinsson.path, "reactions.mat");
    if options.forceRegen || ~isfile(reactions_file)
        material.gas.N2.external.thorsteinsson.importReactions;
    end
    reactions_table = load(reactions_file).irm_reactions;
    ar_spe = material.gas.Ar.species().name;
    e_spe = material.electron.species().name;
    must_contain = ar_spe;
    can_only_contain = vertcat(ar_spe, e_spe);
    reactions_table = material.util.filterReactions(reactions_table, can_only_contain, must_contain);
else
    error("Only Thorsteinsson's reactions are available ATM.");
    % reactions_table = material.gas.Ar.N2.reactions();
    % NOTE : a smarter way to do this would be to check during reaction
    % creation which and flip the order if a e.g. N2.Ar.reactions() doesn exist
end

end

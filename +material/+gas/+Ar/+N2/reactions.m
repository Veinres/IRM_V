function [reactions_table] = reactions()
%SPECIES generate table of argon/nitrogen species reactions
% =========================================================================
% Generate a table containing relevant nitrogen species reactions.
% =========================================================================

%% NOTES: -----------------------------------------------------------------
% TODO : check if it would make sense to give the reactions unique names
% -------------------------------------------------------------------------


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

end

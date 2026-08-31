function [reactions_table] = reactions()
%SPECIES generate table of tungsten species reactions
% =========================================================================
% Generate a table containing relevant tungsten species reactions.
% =========================================================================

%% NOTES: -----------------------------------------------------------------
% FIXME : source don't seem to be correct
% TODO : cross-check sources with references given in papers (of course
% also applies to other materials)
% TODO : check if it would make sense to give the reactions unique names
% -------------------------------------------------------------------------

%% Reactions table --------------------------------------------------------
var_names       = {'name'       ,'reactants'    ,'products'         ,'eq_type'  ,'coeffs'                               ,'type' ,'source'};
% >> Ionisation from grd state --------------------------------------------
%                  name         reactants       products            eq_type     coeffs                                  type    source
grd_ion         = {'izcW'       ,{'e','W'}      ,{'Wi','e','e'}     ,1          ,[6.3966e-14 0.4839 8.221]              ,'ion'  ,'WO';...
                   'izhW'       ,{'eh','W'}     ,{'Wi','eh','e'}    ,1          ,[4.2507e-10 -1.1791 256.38]            ,'ion'  ,'WO'};

% >> Ionisation from ionised state ----------------------------------------
%                  name         reactants       products            eq_type     coeffs                                  type    source
ion_ion         = {'izcWi'      ,{'e','Wi'}     ,{'Wii','e','e'}    ,1          ,[1.446e-14 0.7143 14.5193]             ,'ion'  ,'WO';...
                   'izhWi'      ,{'eh','Wi'}    ,{'Wii','eh','e'}   ,1          ,[4.2507e-10 -1.3047 273.55]            ,'ion'  ,'WO'};

% -------------------------------------------------------------------------

reactions_cell = [grd_ion; ion_ion];
reactions_table = cell2table(reactions_cell, 'VariableNames', var_names);
end

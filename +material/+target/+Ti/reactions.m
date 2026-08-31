function [reactions_table] = reactions()
%SPECIES generate table of titanium species reactions
% =========================================================================
% Generate a table containing relevant titanium species reactions.
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
grd_ion         = {'izcTi'       ,{'e','Ti'}    ,{'Tii','e','e'}    ,1          ,[2.83e-13 0.0579 8.716]                ,'ion'  ,'TiO';...
                   'izhTi'       ,{'eh','Ti'}   ,{'Tii','eh','e'}   ,1          ,[1.1757e-12 -0.3039 21.11]             ,'ion'  ,'TiO'};

% >> Ionisation from ionised state ----------------------------------------
%                  name         reactants       products            eq_type     coeffs                                  type    source
ion_ion         = {'izcTii'      ,{'e','Tii'}   ,{'Tiii','e','e'}   ,1          ,[1.86e-14 0.460 12.99]                 ,'ion'  ,'TiO';...
                   'izhTii'      ,{'eh','Tii'}  ,{'Tiii','eh','e'}  ,1          ,[8.1858e-12 -0.669 200.9]              ,'ion'  ,'TiO'};

% -------------------------------------------------------------------------

reactions_cell = [grd_ion; ion_ion];
reactions_table = cell2table(reactions_cell, 'VariableNames', var_names);
end

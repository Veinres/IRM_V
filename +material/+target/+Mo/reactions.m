function [reactions_table] = reactions()
%SPECIES generate table of molybdenum species reactions
% =========================================================================
% Generate a table containing relevant molybdenum species reactions.
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
grd_ion         = {'izcMo'      ,{'e','Mo'}     ,{'Moi','e','e'}    ,1          ,[4.95E-14 0.7 7.6]                     ,'ion'  ,'JTG';...
                   'izhMo'      ,{'eh','Mo'}    ,{'Moi','eh','e'}   ,8          ,[4.0134E-13 1.1436E-16]                ,'ion'  ,'JTG'};


% >> Ionisation from ionised state ----------------------------------------
%                  name         reactants       products            eq_type     coeffs                                  type    source
ion_ion         = {'izcMoi'     ,{'e','Moi'}    ,{'Moii','e','e'}   ,1          ,[2.91E-14 0.5 16.57]                   ,'ion'  ,'JTG';...
                   'izhMoi'     ,{'eh','Moi'}   ,{'Moii','eh','e'}  ,8          ,[1.6688E-13 3.859E-17]                 ,'ion'  ,'JTG'};

% -------------------------------------------------------------------------

reactions_cell = [grd_ion; ion_ion];
reactions_table = cell2table(reactions_cell, 'VariableNames', var_names);
end

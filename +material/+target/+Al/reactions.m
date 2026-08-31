function [reactions_table] = reactions()
%SPECIES generate table of aluminium species reactions
% =========================================================================
% Generate a table containing relevant aluminium species reactions.
% =========================================================================

%% NOTES: -----------------------------------------------------------------
% TODO : cross-check sources with references given in papers (of course
% also applies to other materials)
% TODO : check if it would make sense to give the reactions unique names
% -------------------------------------------------------------------------

%% Reactions table --------------------------------------------------------
var_names       = {'name'       ,'reactants'    ,'products'         ,'eq_type'  ,'coeffs'                               ,'type' ,'source'};
% >> Ionisation from grd state --------------------------------------------
%                  name         reactants       products            eq_type     coeffs                                  type    source
grd_ion         = {'izcAl'       ,{'e','Al'}    ,{'Ali','e','e'}    ,1          ,[1.3467e-13 0.3576 -6.7829]            ,'ion'  ,'Huo2017';...
                   'izhAl'       ,{'eh','Al'}   ,{'Ali','eh','e'}   ,3          ,[-0.074347 0.637867 -29.516747]        ,'ion'  ,'Huo2017'};

% >> Ionisation from ionised state ----------------------------------------
%                  name         reactants       products            eq_type     coeffs                                  type    source
ion_ion         = {'izcAli'      ,{'e','Ali'}   ,{'Alii','e','e'}   ,1          ,[2.34e-14 0.59 17.44]                  ,'ion'  ,'Huo2017';...
                   'izhAli'      ,{'eh','Ali'}  ,{'Alii','eh','e'}  ,3          ,[-0.1008 1.2011 -34.6841]              ,'ion'  ,'Huo2017'};

% >> Ionisation from ionised state ----------------------------------------
%                  name         reactants       products            eq_type     coeffs                                  type    source
ion_ion         = {'izcAli'      ,{'e','Ali'}   ,{'Alii','e','e'}   ,1          ,[2.34e-14 0.59 17.44]                  ,'ion'  ,'Huo2017';...
                   'izhAli'      ,{'eh','Ali'}  ,{'Alii','eh','e'}  ,3          ,[-0.1008 1.2011 -34.6841]              ,'ion'  ,'Huo2017'};

% >> Excitation from grd state --------------------------------------------
% Only used for energy loss calculation
%                  name         reactants       products            eq_type     coeffs                                  type    source
% grd_meta        = {'excAl'       ,{'e','Al'}    ,{'Alm1','e'}      ,1          ,[1.821e-12 0.8679 -6.975]              ,'exc'   ,'Huo2017';...
%                    'excAl'       ,{'e','Al'}    ,{'Alm2','e'}      ,1          ,[5.7148e-12 -1.2858 -6.975]            ,'exc'   ,'Huo2017';...
%                    'excAl'       ,{'e','Al'}    ,{'Alm3','e'}      ,1          ,[1.7195e-12 -1.3692 -9.0616]           ,'exc'   ,'Huo2017'};
% Something's wrong with this one
% ion_grd         = {'recAli'      ,{'e','Ali'}   ,{'Al','e'}        ,3          ,[0.0104 0.1134 -11.7]                  ,'rec'   ,'Huo2017'};
% -------------------------------------------------------------------------

reactions_cell = [grd_ion; ion_ion];
reactions_table = cell2table(reactions_cell, 'VariableNames', var_names);
end

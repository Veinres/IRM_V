function [reactions_table] = reactions()
%SPECIES generate table of carbon species reactions
% =========================================================================
% Generate a table containing relevant carbon species reactions.
% =========================================================================

%% NOTES: -----------------------------------------------------------------
% FIXME : source don't seem to be correct
% TODO : cross-check sources with references given in papers (of course
% also applies to other materials)
% TODO : check if it would make sense to give the reactions unique names
% -------------------------------------------------------------------------

%% Reactions table --------------------------------------------------------
% added by Henrik Eliasson, 2021-03-26
var_names       = {'name'       ,'reactants'    ,'products'         ,'eq_type'  ,'coeffs'                               ,'type' ,'source'};
% >> Ionisation from grd state --------------------------------------------
%                  name         reactants       products            eq_type     coeffs                                  type    source
grd_ion         = {'izcC'       ,{'C','e'}      ,{'Ci','e','e'}     ,1          ,[1.515e-14 0.5868 11.8972]             ,'ion'  ,'';...
                   'izhC'       ,{'C','eh'}     ,{'Ci','eh','e'}    ,8          ,[1.4348e-13 3.3441e-17]                ,'ion'  ,''};

% >> Ionisation from ionised state ----------------------------------------
%                  name         reactants       products            eq_type     coeffs                                  type    source
ion_ion         = {'izcCi'      ,{'Ci','e'}     ,{'Cii','e','e'}    ,1          ,[8.98e-15 0.3872 24.56]                ,'ion'  ,'';...
                   'izhCi'      ,{'Ci','eh'}    ,{'Cii','eh','e'}   ,1          ,[1.4838e-13 -0.2304 67.33]             ,'ion'  ,''};

% >> Ionisation from metastable state -------------------------------------
%                  name         reactants       products            eq_type     coeffs                                  type    source
meta_ion        = {'izcC1'      ,{'Cm1','e'}    ,{'Ci','e','e'}     ,1          ,[1.4120e-14 0.5991 10.7]               ,'ion'  ,'';...
                   'izhC1'      ,{'Cm1','eh'}   ,{'Ci','eh','e'}    ,8          ,[1.433e-13 3.33e-17]                   ,'ion'  ,'';...
                   %
                   'izcC2'      ,{'Cm2','e'}    ,{'Ci','e','e'}     ,1          ,[1.21e-14 0.6404 9.2267]               ,'ion'  ,'';...
                   'izhC2'      ,{'Cm2','eh'}   ,{'Ci','eh','e'}    ,8          ,[1.433e-13 3.33e-17]                   ,'ion'  ,'';...
                   %
                   'izcC3'      ,{'Cm3','e'}    ,{'Ci','e','e'}     ,1          ,[1.008e-14 0.6819 7.2335]              ,'ion'  ,'';...
                   'izhC3'      ,{'Cm3','eh'}   ,{'Ci','eh','e'}    ,8          ,[1.428e-13 3.32e-17]                   ,'ion'  ,''};

% >> Excitation from grd state --------------------------------------------
%                  name         reactants       products            eq_type     coeffs                                  type    source
grd_meta        = {'excC'       ,{'C','e'}      ,{'Cm1','e'}        ,1          ,[3.315e-14 -0.498 1.995]               ,'exc'  ,'';...
                   'exhC'       ,{'C','eh'}     ,{'Cm1','eh'}       ,8          ,[3.489e-15 2.504e-17]                  ,'exc'  ,'';...
                   %
                   'excC'       ,{'C','e'}      ,{'Cm2','e'}        ,1          ,[4.9e-15 -0.584 3.462]                 ,'exc'  ,'';...
                   'exhC'       ,{'C','eh'}     ,{'Cm2','eh'}       ,8          ,[3.543e-16 2.581e-18]                  ,'exc'  ,'';...
                   %
                   'excC'       ,{'C','e'}      ,{'Cm3','e'}        ,1          ,[3.831e-14 -0.813 5.057]               ,'exc'  ,'';...
                   'exhC'       ,{'C','eh'}     ,{'Cm3','eh'}       ,8          ,[1.701e-15 1.2105e-17]                 ,'exc'  ,''};

% >> De-/Excitation from meta to meta -------------------------------------
%                  name         reactants       products            eq_type     coeffs                                  type    source
meta_meta       = {'excC'       ,{'Cm1','e'}    ,{'Cm2','e'}        ,1          ,[5.796e-15 -0.2076 1.6752]             ,'exc'  ,'';...
                   'exhC'       ,{'Cm1','eh'}   ,{'Cm2','eh'}       ,8          ,[3.4144e-15 1.0218e-17]                ,'exc'  ,'';...
                   %
                   'excC'       ,{'Cm2','e'}    ,{'Cm1','e'}        ,1          ,[2.738e-14 -0.1811 1.3185]             ,'exc'  ,'';...
                   'exhC'       ,{'Cm2','eh'}   ,{'Cm1','eh'}       ,8          ,[1.8364e-14 6.0929e-17]                ,'exc'  ,''};

% >> Deexcitation ---------------------------------------------------------
%                  name         reactants       products            eq_type     coeffs                                  type    source
meta_grd        = {'excC'       ,{'Cm1','e'}    ,{'C','e'}          ,1          ,[6.78e-15 -0.523 0.757]                ,'exc'  ,'';...
                   'exhC'       ,{'Cm1','eh'}   ,{'C','eh'}         ,8          ,[7.1673e-16 5.018e-18]                 ,'exc'  ,'';...
                   %
                   'excC'       ,{'Cm2','e'}    ,{'C','e'}          ,1          ,[5.193e-15 -0.6205 0.8638]             ,'exc'  ,'';...
                   'exhC'       ,{'Cm2','eh'}   ,{'C','eh'}         ,8          ,[3.7491e-16 2.7709e-18]                ,'exc'  ,'';...
                   %
                   'excC'       ,{'Cm3','e'}    ,{'C','e'}          ,1          ,[7.275e-15 -0.7829 0.9309]             ,'exc'  ,'';...
                   'exhC'       ,{'Cm3','eh'}   ,{'C','eh'}         ,8          ,[3.7181e-16 2.7095e-18]                ,'exc'  ,''};

% -------------------------------------------------------------------------

reactions_cell = [grd_ion; ion_ion; meta_ion; grd_meta; meta_meta; meta_grd];
reactions_table = cell2table(reactions_cell, 'VariableNames', var_names);
end


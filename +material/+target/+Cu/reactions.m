function [reactions_table] = reactions()
%SPECIES generate table of copper species reactions
% =========================================================================
% Generate a table containing relevant copper species reactions.
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
                   % 20
grd_ion         = {'izcCu'       ,{'e','Cu'}    ,{'Cui','e','e'}    ,1          ,[3.898e-14 0.484 7.1344]               ,'ion'  ,'JTG';...
                   'izhCu'       ,{'eh','Cu'}   ,{'Cui','eh','e'}   ,8          ,[1.6508e-13  4.7434e-16]               ,'ion'  ,'JTG'};

% >> Ionisation from ionised state ----------------------------------------
%                  name         reactants       products            eq_type     coeffs                                  type    source
                   % 24
ion_ion         = {'izcCui'      ,{'e','Cui'}   ,{'Cuii','e','e'}   ,1          ,[2.0485e-15 0.325 33.1]                ,'ion'  ,'JTG';...
                   'izhCui'      ,{'eh','Cui'}  ,{'Cuii','eh','e'}  ,8          ,[6.2816e-15 1.553e-17]                 ,'ion'  ,'JTG'};

% >> Ionisation from metastable state -------------------------------------
%                  name         reactants       products            eq_type     coeffs                                  type    source
                   % 21
meta_ion        = {'izcCum1'      ,{'e','Cum1'} ,{'Cui','e','e'}    ,1          ,[3.2926e-14 0.5282 5.7511]             ,'ion'  ,'JTG';...
                   'izhCum1'      ,{'eh','Cum1'},{'Cui','eh','e'}   ,8          ,[1.6423e-13 4.7394e-16]                ,'ion'  ,'JTG';...
                   % 22
                   'izcCum2'      ,{'e','Cum2'} ,{'Cui','e','e'}    ,1          ,[3.1879e-14 0.5369 5.504]              ,'ion'  ,'JTG';...
                   'izhCum2'      ,{'eh','Cum2'},{'Cui','eh','e'}   ,8          ,[1.6407e-13 4.7384e-16]                ,'ion'  ,'JTG';...
                   % 23
                   'izcCum3'      ,{'e','Cum3'} ,{'Cui','e','e'}    ,1          ,[2.3576e-14 0.6213 3.4204]             ,'ion'  ,'JTG';...
                   'izhCum3'      ,{'eh','Cum3'},{'Cui','eh','e'}   ,8          ,[1.6261e-13 4.7258e-16]                ,'ion'  ,'JTG'};

% >> Excitation from grd state --------------------------------------------
%                  name         reactants       products            eq_type     coeffs                                  type    source
                   % 10
grd_meta        = {'excCu'       ,{'e','Cu'}    ,{'Cum1','e'}       ,1          ,[4.0774e-14 -0.6702 2.162]             ,'exc'  ,'JTG';...
                   'exhCu'       ,{'eh','Cu'}   ,{'Cum1','eh'}      ,1          ,[9.1027e-13 -1.2646 92.15]             ,'exc'  ,'JTG';...
                   % 11
                   'excCu'       ,{'e','Cu'}    ,{'Cum2','e'}       ,1          ,[2.6154e-14 -0.6436 2.4424]            ,'exc'  ,'JTG';...
                   'exhCu'       ,{'eh','Cu'}   ,{'Cum2','eh'}      ,1          ,[6.50e-13 -1.264 93.92]                ,'exc'  ,'JTG';...
                   % 12
                   'excCu'       ,{'e','Cu'}    ,{'Cum3','e'}       ,1          ,[1.9064e-13 -0.1462 4.5264]            ,'exc'  ,'JTG';...
                   'exhCu'       ,{'eh','Cu'}   ,{'Cum3','eh'}      ,8          ,[2.0912e-13 1.5119e-16]                ,'exc'  ,'JTG'};

% >> De-/Excitation from meta to meta -------------------------------------
%                  name         reactants       products            eq_type     coeffs                                  type    source
                   % 14
meta_meta       = {'dexcCum3'   ,{'e','Cum3'}   ,{'Cum1','e'}       ,2          ,[2e6]                                  ,'exc'  ,'JTG';...
                   'dexhCum3'   ,{'eh','Cum3'}  ,{'Cum1','eh'}      ,2          ,[2e6]                                  ,'exc'  ,'JTG';...
                   % 15
                   'dexcCum3'   ,{'e','Cum3'}   ,{'Cum2','e'}       ,2          ,[1.65e6]                               ,'exc'  ,'JTG';...
                   'dexhCum3'   ,{'eh','Cum3'}  ,{'Cum2','eh'}      ,2          ,[1.65e6]                               ,'exc'  ,'JTG';...
                   % 19
                   'excCum1'    ,{'e','Cum1'}   ,{'Cum2','e'}       ,1          ,[1.1757e-13 0.0075 0.2355]             ,'exc'  ,'JTG';...
                   'exhCum1'    ,{'eh','Cum1'}  ,{'Cum2','eh'}      ,8          ,[1.2944e-13 8.9187e-17]                ,'exc'  ,'JTG'};

% >> Deexcitation ---------------------------------------------------------
%                  name         reactants       products            eq_type     coeffs                                  type    source
                   % 13
meta_grd        = {'dexcCum3'   ,{'e','Cum3'}   ,{'Cu','e'}         ,1          ,[1.271e-13 -0.1462 0.7364]             ,'exc'  ,'JTG';...
                   'dexhCum3'   ,{'eh','Cum3'}  ,{'Cu','eh'}        ,9          ,[1.394e-13 -1.008e-16 -3.79]           ,'exc'  ,'JTG';...
                   % 16
                   'dexcCum3'   ,{'e','Cum3'}   ,{'Cu','e'}         ,2          ,[1.39e8]                               ,'exc'  ,'JTG';...
                   'dexhCum3'   ,{'eh','Cum3'}  ,{'Cu','eh'}        ,2          ,[1.39e8]                               ,'exc'  ,'JTG';...
                   % 17
                   'dexcCum1'   ,{'e','Cum1'}   ,{'Cu','e'}         ,1          ,[1.359e-14 -0.523 0.772]               ,'exc'  ,'JTG';...
                   'dexhCum1'   ,{'eh','Cum1'}  ,{'Cu','eh'}        ,1          ,[3.034e-13 -1.2646 90.81]              ,'exc'  ,'JTG';...
                   % 18
                   'dexcCum2'   ,{'e','Cum2'}   ,{'Cu','e'}         ,1          ,[1.3077e-14 -0.6536 0.8]               ,'exc'  ,'JTG';...
                   'dexhCum2'   ,{'eh','Cum2'}  ,{'Cu','eh'}        ,1          ,[3.25e-13 -1.264 92.28]                ,'exc'  ,'JTG'};

% -------------------------------------------------------------------------

reactions_cell = [grd_ion; ion_ion; meta_ion; grd_meta; meta_meta; meta_grd];
reactions_table = cell2table(reactions_cell, 'VariableNames', var_names);
end

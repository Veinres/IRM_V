function [reactions_table] = reactions()
%SPECIES generate table of argon species reactions
% =========================================================================
% Generate a table containing relevant argon species reactions.
% =========================================================================

%% NOTES: -----------------------------------------------------------------
% FIXME : sources don't seem to be correct
% TODO : cross-check sources with references given in papers (of course
% also applies to other materials)
% TODO : check if it would make sense to give the reactions unique names
% -------------------------------------------------------------------------

%% Reactions table --------------------------------------------------------
var_names       = {'name'       ,'reactants'    ,'products'         ,'eq_type'  ,'coeffs'                               ,'type' ,'source'};
% >> Ionisation from grd state --------------------------------------------
%                  name         reactants       products            eq_type     coeffs                                  type    source
grd_ion         = {'izcAr'      ,{'e','Ar'}     ,{'Ari','e','e'}    ,1          ,[2.34e-14 0.59 17.44]                  ,'ion'  ,'butler2018three';...
                   'izcArH'     ,{'e','ArH'}    ,{'Ari','e','e'}    ,1          ,[2.34e-14 0.59 17.44]                  ,'ion'  ,'butler2018three';...
                   'izcArW'     ,{'e','ArW'}    ,{'Ari','e','e'}    ,1          ,[2.34e-14 0.59 17.44]                  ,'ion'  ,'butler2018three';...
                   'izhAr'      ,{'eh','Ar'}    ,{'Ari','eh','e'}   ,1          ,[8e-14 0.16 27.53]                     ,'ion'  ,'butler2018three';...
                   'izhGSAri'   ,{'eh','Ar'}    ,{'Arii','eh','e'}  ,8          ,[6.169e-15 1.6316E-17]                 ,'ion'  ,'butler2018three';...
                   'izhArW'     ,{'eh','ArW'}   ,{'Ari','eh','e'}   ,1          ,[8e-14 0.16 27.53]                     ,'ion'  ,'butler2018three';...
                   'izhArH'     ,{'eh','ArH'}   ,{'Ari','eh','e'}   ,1          ,[8e-14 0.16 27.53]                     ,'ion'  ,'butler2018three'};

[Reactionlist]=add_reaction({'e','He'},{'Hei','e','e'},1,[2.1394E-15 0.6321 24.5919],'ion','BiagiV8.97',Reactionlist,'izcHe');
[Reactionlist]=add_reaction({'e','HeW'},{'Hei','e','e'},1,[2.1394E-15 0.6321 24.5919],'ion','BiagiV8.97',Reactionlist,'izcHeW');
[Reactionlist]=add_reaction({'e','HeH'},{'Hei','e','e'},1,[2.1394E-15 0.6321 24.5919],'ion','BiagiV8.97',Reactionlist,'izcHeH');

[Reactionlist]=add_reaction({'e','He'},{'Hei','e','e'},2,[0.0],'ion','BiagiV8.97',Reactionlist,'izcHe');
[Reactionlist]=add_reaction({'e','HeW'},{'Hei','e','e'},2,[0.0],'ion','BiagiV8.97',Reactionlist,'izcHeW');
[Reactionlist]=add_reaction({'e','HeH'},{'Hei','e','e'},2,[0.0],'ion','BiagiV8.97',Reactionlist,'izcHeH');

[Reactionlist]=add_reaction({'eh','He'},{'Hei','eh','e'},1,[6.1442E-11 -1.2 305.7],'ion','BiagiV8.97',Reactionlist,'izhHe');
[Reactionlist]=add_reaction({'eh','HeW'},{'Hei','eh','e'},1,[6.1442E-11 -1.2 305.7],'ion','BiagiV8.97',Reactionlist,'izhHeW');
[Reactionlist]=add_reaction({'eh','HeH'},{'Hei','eh','e'},1,[6.1442E-11 -1.2 305.7],'ion','BiagiV8.97',Reactionlist,'izhHeH');

% >> Ionisation from ionised state ----------------------------------------
% Ar2+ ionization included for the C-IRM, see Elliason 2021
%                  name         reactants       products            eq_type     coeffs                                  type    source
ion_ion         = {'izcAri'     ,{'e','Ari'}    ,{'Arii','e','e'}   ,1          ,[8.6365e-15 0.6746 24.3019]            ,'ion'  ,'butler2018three';...
                   'izhAri'     ,{'eh','Ari'}   ,{'Arii','eh','e'}  ,8          ,[5.22e-14 4.943e-17]                   ,'ion'  ,'butler2018three'};
                 %{'chexAri'    ,{'Ari','Ari'}  ,{'Arii','Ar'}      ,2          ,[6.4e-18]                              ,'ch_trans',''            }; % FIXME : should this be included?


% >> Ionisation from metastable state -------------------------------------
% Ar ionization from the metastable levels are fits done by JT to the
% cross-sections of Dixon 1973, see e.g. [Stancu15_045011]. JT refitted
% the cold electron rate coefficient (which gives a close match to those 
% published by Stancu) and made a new fit for the hot electron distribution
% function. For the ionization from the hot electrons, the cross-section is
% extrapolated to 1000eV
% Dixon73 data is for a combined 4s level. Therefore, to consider each of
% the two metastable levels, the data is divided by 2.
% same applies to the excitation from the two levels from hot electrons
%                  name         reactants       products            eq_type     coeffs                                  type    source
meta_ion        = {'izcArm3P0'  ,{'e','Arm3P0'} ,{'Ari','e','e'}    ,1          ,[1.1436e-13 0.2548 4.4005]             ,'ion'  ,'butler2018three';...
                   'izcArm3P2'  ,{'e','Arm3P2'} ,{'Ari','e','e'}    ,1          ,[1.1436e-13 0.2548 4.4005]             ,'ion'  ,'butler2018three';...
                   %
                   'izhArm3P0'  ,{'eh','Arm3P0'},{'Ari','eh','e'}   ,6          ,[1.5213e-19 -2.9599E-16 1.8155e-13]    ,'ion'  ,'butler2018three';...
                   'izhArm3P2'  ,{'eh','Arm3P2'},{'Ari','eh','e'}   ,6          ,[1.5213e-19 -2.9599E-16 1.8155e-13]    ,'ion'  ,'butler2018three'};

% >> Excitation from grd state --------------------------------------------
% these are the new rates from L.L. Alves, ''The IST-Lisbon database on
% LXCat'' J. Phys. Conf. Series 2014, 565, 1  A. Yanguas-Gil, J. Cotrino
% and L.L. Alves ''An update of argon inelastic cross sections for plasma
% discharges''
% 2005 J.   Phys. D: Appl. Phys. 38 1588-1598
%                  name         reactants       products            eq_type     coeffs                                  type    source
grd_meta        = {'excAr3P0'   ,{'e','Ar'}     ,{'Arm3P0','e'}     ,1          ,[2.8603e-15 -0.8572 14.6219]           ,'exc' ,'butler2018three';...
                   'excArW3P0'  ,{'e','ArW'}    ,{'Arm3P0','e'}     ,1          ,[2.8603e-15 -0.8572 14.6219]           ,'exc' ,'butler2018three';...
                   'excArH3P0'  ,{'e','ArH'}    ,{'Arm3P0','e'}     ,1          ,[2.8603e-15 -0.8572 14.6219]           ,'exc' ,'butler2018three';...
                   'excAr3P2'   ,{'e','Ar'}     ,{'Arm3P2','e'}     ,1          ,[1.6170e-14 -0.8238 14.1256]           ,'exc' ,'butler2018three';...
                   'excArW3P2'  ,{'e','ArW'}    ,{'Arm3P2','e'}     ,1          ,[1.6170e-14 -0.8238 14.1256]           ,'exc' ,'butler2018three';...
                   'excArH3P2'  ,{'e','ArH'}    ,{'Arm3P2','e'}     ,1          ,[1.6170e-14 -0.8238 14.1256]           ,'exc' ,'butler2018three';...
% the same for the Ar^met excitation from the hot electron distribution.
% Each of these has three cross-sections because the cross-sections ar % FIXME QUESTION : Why? explanation is incomplete
%                  name         reactants       products            eq_type     coeffs                                  type    source
                   'exhAr'      ,{'eh','Ar'}    ,{'Arm3P0','eh'}    ,1          ,[1.8045E-23 2 0]                       ,'exc'  ,'butler2018three';...
                   'exhAr'      ,{'eh','Ar'}    ,{'Arm3P0','eh'}    ,1          ,[-2.9825E-20 1 0]                      ,'exc'  ,'butler2018three';...
                   'exhAr'      ,{'eh','Ar'}    ,{'Arm3P0','eh'}    ,1          ,[1.3574E-17 0 0]                       ,'exc'  ,'butler2018three';...
                   %
                   'exhAr'      ,{'eh','ArW'}   ,{'Arm3P0','eh'}    ,1          ,[1.8045E-23 2 0]                       ,'exc'  ,'butler2018three';...
                   'exhAr'      ,{'eh','ArW'}   ,{'Arm3P0','eh'}    ,1          ,[-2.9825E-20 1 0]                      ,'exc'  ,'butler2018three';...
                   'exhAr'      ,{'eh','ArW'}   ,{'Arm3P0','eh'}    ,1          ,[1.3574E-17 0 0]                       ,'exc'  ,'butler2018three';...
                   %
                   'exhAr'      ,{'eh','ArH'}   ,{'Arm3P0','eh'}    ,1          ,[1.8045E-23 2 0]                       ,'exc'  ,'butler2018three';...
                   'exhAr'      ,{'eh','ArH'}   ,{'Arm3P0','eh'}    ,1          ,[-2.9825E-20 1 0]                      ,'exc'  ,'butler2018three';...
                   'exhAr'      ,{'eh','ArH'}   ,{'Arm3P0','eh'}    ,1          ,[1.3574E-17 0 0]                       ,'exc'  ,'butler2018three';...
                   %
                   'exhAr'      ,{'eh','Ar'}    ,{'Arm3P2','eh'}    ,1          ,[1.1397E-22 2 0]                       ,'exc'  ,'butler2018three';...
                   'exhAr'      ,{'eh','Ar'}    ,{'Arm3P2','eh'}    ,1          ,[-1.8975E-19 1 0]                      ,'exc'  ,'butler2018three';...
                   'exhAr'      ,{'eh','Ar'}    ,{'Arm3P2','eh'}    ,1          ,[8.7910E-17 0 0]                       ,'exc'  ,'butler2018three';...
                   %
                   'exhAr'      ,{'eh','ArW'}   ,{'Arm3P2','eh'}    ,1          ,[1.1397E-22 2 0]                       ,'exc'  ,'butler2018three';...
                   'exhAr'      ,{'eh','ArW'}   ,{'Arm3P2','eh'}    ,1          ,[-1.8975E-19 1 0]                      ,'exc'  ,'butler2018three';...
                   'exhAr'      ,{'eh','ArW'}   ,{'Arm3P2','eh'}    ,1          ,[8.7910E-17 0 0]                       ,'exc'  ,'butler2018three';...
                   %
                   'exhAr'      ,{'eh','ArH'}   ,{'Arm3P2','eh'}    ,1          ,[1.1397E-22 2 0]                       ,'exc'  ,'butler2018three';...
                   'exhAr'      ,{'eh','ArH'}   ,{'Arm3P2','eh'}    ,1          ,[-1.8975E-19 1 0]                      ,'exc'  ,'butler2018three';...
                   'exhAr'      ,{'eh','ArH'}   ,{'Arm3P2','eh'}    ,1          ,[8.7910E-17 0 0]                       ,'exc'  ,'butler2018three'};

% >> Deexcitation ---------------------------------------------------------
% calculated by Gudmundsson based on detailed balancing
%                  name         reactants       products            eq_type     coeffs                                  type    source
meta_grd        = {'dexcArm3P0' ,{'e','Arm3P0'} ,{'Ar','e'}         ,1          ,[2.86e-15 -0.8572 -2.8989]             ,'exc'  ,'butler2018three';...
                   'dexcArm3P2' ,{'e','Arm3P2'} ,{'Ar','e'}         ,1          ,[3.23e-15 -0.8238 -2.578]              ,'exc'  ,'butler2018three';...
                   'dexhArm3P0' ,{'eh','Arm3P0'},{'Ar','eh'}        ,7          ,[1.8045E-23 -2.9825E-20 1.357E-17 1]   ,'exc'  ,'butler2018three';...
                   'dexhArm3P2' ,{'eh','Arm3P2'},{'Ar','eh'}        ,7          ,[1.1397E-22 -1.8975E-19 8.7910E-17 5]  ,'exc'  ,'butler2018three'};

% -------------------------------------------------------------------------

reactions_cell = [grd_ion; ion_ion; meta_ion; grd_meta; meta_grd];
reactions_table = cell2table(reactions_cell, 'VariableNames', var_names);
end


%% He

if ismember('He',Spe.PSpeciess)

% >> Ionisation from grd state


% >> Ionisation from metastable state
% He ionization from the metastable levels are fits done by Zakaria to the
% cross-sections of Biagi (transcription of data from SF Biagi's Fortran code, Magboltz.) taken from Lxcat 
[Reactionlist]=add_reaction({'e','Hem2S1'},{'Hei','e','e'},2,[0],'ion','BiagiV8.97',Reactionlist,'izcHem2S1');
[Reactionlist]=add_reaction({'eh','Hem2S1'},{'Hei','eh','e'},1,[1.4589E-10 -1.14 164.5],'ion','Triniti_Lxcat',Reactionlist,'izhHem2S1');
% [Reactionlist]=add_reaction({'eh','Hem2S0'},{'Hei','eh','e'},6,[no data],'ion','BiagiV8.97',Reactionlist,'izhArm3P2');

% >> Excitation from grd state
 
% He^met excitation from the hot electron distribution.

[Reactionlist]=add_reaction({'e','He'},{'Hem2S1','e'},1,[2.3459e-15 -0.7374 20.1227],'exc','BiagiV8.97',Reactionlist,'excHe');
[Reactionlist]=add_reaction({'e','He'},{'Hem2S0','e'},1,[9.3116e-16 -0.3126 20.4779],'exc','BiagiV8.97',Reactionlist,'excHe');
[Reactionlist]=add_reaction({'e','He'},{'He2P012','e'},1,[2.3401e-15 -0.4682 21.8094],'exc','BiagiV8.97',Reactionlist,'excHe');
[Reactionlist]=add_reaction({'e','He'},{'He2P1','e'},1,[1.3083e-15 0.5650 20.6208],'exc','BiagiV8.97',Reactionlist,'excHe');

[Reactionlist]=add_reaction({'e','HeW'},{'Hem2S1','e'},1,[2.3459e-15 -0.7374 20.1227],'exc','BiagiV8.97',Reactionlist,'excHe');
[Reactionlist]=add_reaction({'e','HeW'},{'Hem2S0','e'},1,[9.3116e-16 -0.3126 20.4779],'exc','BiagiV8.97',Reactionlist,'excHe');
[Reactionlist]=add_reaction({'e','HeW'},{'He2P012','e'},1,[2.3401e-15 -0.4682 21.8094],'exc','BiagiV8.97',Reactionlist,'excHe');
[Reactionlist]=add_reaction({'e','HeW'},{'He2P1','e'},1,[1.3083e-15 0.5650 20.6208],'exc','BiagiV8.97',Reactionlist,'excHe');

[Reactionlist]=add_reaction({'e','HeH'},{'Hem2S1','e'},1,[2.3459e-15 -0.7374 20.1227],'exc','BiagiV8.97',Reactionlist,'excHe');
[Reactionlist]=add_reaction({'e','HeH'},{'Hem2S0','e'},1,[9.3116e-16 -0.3126 20.4779],'exc','BiagiV8.97',Reactionlist,'excHe');
[Reactionlist]=add_reaction({'e','HeH'},{'He2P012','e'},1,[2.3401e-15 -0.4682 21.8094],'exc','BiagiV8.97',Reactionlist,'excHe');
[Reactionlist]=add_reaction({'e','HeH'},{'He2P1','e'},1,[1.3083e-15 0.5650 20.6208],'exc','BiagiV8.97',Reactionlist,'excHe');

[Reactionlist]=add_reaction({'eh','He'},{'Hem2S1','eh'},1,[6.5132e-14 -1.4435 70.9356],'exc','BiagiV8.97',Reactionlist,'exhHe');
[Reactionlist]=add_reaction({'eh','He'},{'Hem2S0','eh'},1,[2.4735e-13 -1.1477 208.8655],'exc','BiagiV8.97',Reactionlist,'exhHe');
[Reactionlist]=add_reaction({'eh','He'},{'He2P012','eh'},1,[1.6293e-13 -1.4598 71.6636],'exc','BiagiV8.97',Reactionlist,'exhHe');
[Reactionlist]=add_reaction({'eh','He'},{'He2P1','eh'},1,[2.1952e-11 -1.1823 283.3282],'exc','BiagiV8.97',Reactionlist,'exhHe');

[Reactionlist]=add_reaction({'eh','HeW'},{'Hem2S1','eh'},1,[6.5132e-14 -1.4435 70.9356],'exc','BiagiV8.97',Reactionlist,'exhHe');
[Reactionlist]=add_reaction({'eh','HeW'},{'Hem2S0','eh'},1,[2.4735e-13 -1.1477 208.8655],'exc','BiagiV8.97',Reactionlist,'exhHe');
[Reactionlist]=add_reaction({'eh','HeW'},{'He2P012','eh'},1,[1.6293e-13 -1.4598 71.6636],'exc','BiagiV8.97',Reactionlist,'exhHe');
[Reactionlist]=add_reaction({'eh','HeW'},{'He2P1','eh'},1,[2.1952e-11 -1.1823 283.3282],'exc','BiagiV8.97',Reactionlist,'exhHe');

[Reactionlist]=add_reaction({'eh','HeH'},{'Hem2S1','eh'},1,[6.5132e-14 -1.4435 70.9356],'exc','BiagiV8.97',Reactionlist,'exhHe');
[Reactionlist]=add_reaction({'eh','HeH'},{'Hem2S0','eh'},1,[2.4735e-13 -1.1477 208.8655],'exc','BiagiV8.97',Reactionlist,'exhHe');
[Reactionlist]=add_reaction({'eh','HeH'},{'He2P012','eh'},1,[1.6293e-13 -1.4598 71.6636],'exc','BiagiV8.97',Reactionlist,'exhHe');
[Reactionlist]=add_reaction({'eh','HeH'},{'He2P1','eh'},1,[2.1952e-11 -1.1823 283.3282],'exc','BiagiV8.97',Reactionlist,'exhHe');

% > Deexcitation

[Reactionlist]=add_reaction({'e','Hem2S1'},{'He','e'},1,[2.3459e-15 -0.7374 20.1227],'exc','BiagiV8.97',Reactionlist,'dexcHem2S1');
[Reactionlist]=add_reaction({'e','Hem2S0'},{'He','e'},1,[9.3116e-16  -0.3126  20.4779],'exc','BiagiV8.97',Reactionlist,'dexcHem2S0');
[Reactionlist]=add_reaction({'e','He2P012'},{'He','e'},1,[2.3401e-15 -0.4682 21.8094],'exc','BiagiV8.97',Reactionlist,'dexcHe2P012');
[Reactionlist]=add_reaction({'e','He2P1'},{'He','e'},1,[1.3083e-15 0.5650 20.6208],'exc','BiagiV8.97',Reactionlist,'dexcHe2P1');


[Reactionlist]=add_reaction({'eh','Hem2S1'},{'He','eh'},1,[6.5132e-14 -1.4435 70.9356],'exc','BiagiV8.97',Reactionlist,'dexhHem2S1');
[Reactionlist]=add_reaction({'eh','Hem2S0'},{'He','eh'},1,[2.4735e-13 -1.1477 208.8655],'exc','BiagiV8.97',Reactionlist,'dexhHem2S0');
[Reactionlist]=add_reaction({'eh','He2P012'},{'He','eh'},1,[1.6293e-13 -1.4598 71.6636],'exc','BiagiV8.97',Reactionlist,'dexhHe2P012');
[Reactionlist]=add_reaction({'eh','He2P1'},{'He','eh'},1,[2.1952e-11 -1.1823 283.3282],'exc','BiagiV8.97',Reactionlist,'dexhHe2P1');

end
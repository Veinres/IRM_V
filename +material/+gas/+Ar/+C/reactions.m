function [reactions_table] = reactions()
%SPECIES generate table of carbon + argon species reactions
% =========================================================================
% Generate a table containing relevant carbon + argon species reactions.
% =========================================================================

%% NOTES: -----------------------------------------------------------------
% FIXME : source don't seem to be correct
% TODO : cross-check sources with references given in papers (of course
% also applies to other materials)
% TODO : check if it would make sense to give the reactions unique names
% NOTE : these rates seem a bit sketchy...
% -------------------------------------------------------------------------

%% Reactions table --------------------------------------------------------
%There is absolutely no source for these reaction rates, it's just a guess,
%based on the penning ionisation rates for titanium.
var_names       = {'name'       ,'reactants'    ,'products'         ,'eq_type'  ,'coeffs'                               ,'type' ,'source'};
% >> Charge exchange ------------------------------------------------------
%                  name         reactants       products            eq_type     coeffs                                  type    source
ch_tran         = {'chexAri'    ,{'Ari','C'}    ,{'Ar','Ci'}        ,2          ,[6.4e-18]                              ,'ch_trans','';...
                   'chexAri'    ,{'Ari','Cm1'}  ,{'Ar','Ci'}        ,2          ,[6.4e-18]                              ,'ch_trans','';...
                   'chexAri'    ,{'Ari','Cm2'}  ,{'Ar','Ci'}        ,2          ,[6.4e-18]                              ,'ch_trans','';...
                   'chexAri'    ,{'Ari','Cm3'}  ,{'Ar','Ci'}        ,2          ,[6.4e-18]                              ,'ch_trans',''};

% >> Penning ionisation ---------------------------------------------------
%                  name         reactants       products            eq_type     coeffs                                  type    source
penning         = {'Pen'        ,{'Arm3P0','C'} ,{'Ar','Ci','e'}    ,2          ,[4.2e-15]                              ,'pen'  ,'';...
                   'Pen'        ,{'Arm3P0','Cm1'},{'Ar','Ci','e'}   ,2          ,[4.2e-15]                              ,'pen'  ,'';...
                   'Pen'        ,{'Arm3P0','Cm2'},{'Ar','Ci','e'}   ,2          ,[4.2e-15]                              ,'pen'  ,'';...
                   'Pen'        ,{'Arm3P0','Cm3'},{'Ar','Ci','e'}   ,2          ,[4.2e-15]                              ,'pen'  ,'';...
                   'Pen'        ,{'Arm3P2','C'} ,{'Ar','Ci','e'}    ,2          ,[4.2e-15]                              ,'pen'  ,'';...
                   'Pen'        ,{'Arm3P2','Cm1'},{'Ar','Ci','e'}	,2          ,[4.2e-15]                              ,'pen'  ,'';...
                   'Pen'        ,{'Arm3P2','Cm2'},{'Ar','Ci','e'}   ,2          ,[4.2e-15]                              ,'pen'  ,'';...
                   'Pen'        ,{'Arm3P2','Cm3'},{'Ar','Ci','e'}   ,2          ,[4.2e-15]                              ,'pen'  ,''};

% -------------------------------------------------------------------------

reactions_cell = [ch_tran; penning];
reactions_table = cell2table(reactions_cell, 'VariableNames', var_names);
end


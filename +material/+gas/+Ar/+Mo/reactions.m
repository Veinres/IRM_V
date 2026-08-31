function [reactions_table] = reactions()
%SPECIES generate table of molybdenum + argon species reactions
% =========================================================================
% Generate a table containing relevant tungsten + argon species reactions.
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
ch_tran         = {'chexAri'    ,{'Ari','Mo'}   ,{'Ar','Moi'}       ,2          ,[2e-16]                                ,'ch_trans','Supposed'};

% >> Penning ionisation ---------------------------------------------------
%                  name         reactants       products            eq_type     coeffs                                  type    source
penning         = {'Pen'        ,{'Arm3P0','Mo'},{'Ar','Moi','e'}   ,2          ,[5.3e-15]                              ,'pen'  ,'Supposed';...
                   'Pen'        ,{'Arm3P2','Mo'},{'Ar','Moi','e'}	,2          ,[5.3e-15]                              ,'pen'  ,'Supposed'};

% -------------------------------------------------------------------------

reactions_cell = [ch_tran; penning];
reactions_table = cell2table(reactions_cell, 'VariableNames', var_names);
end

function [reactions_table] = reactions()
%SPECIES generate table of molybdenum + helium species reactions
% =========================================================================
% Generate a table containing relevant tungsten + helium species reactions.
% =========================================================================

%% NOTES: -----------------------------------------------------------------
% FIXME : source don't seem to be correct
% TODO : cross-check sources with references given in papers (of course
% also applies to other materials)
% TODO : check if it would make sense to give the reactions unique names
% -------------------------------------------------------------------------

%% Reactions table --------------------------------------------------------
%There is absolutely no source for these reaction rates, it's just a guess,
%based on the penning ionisation rates for titanium.
var_names       = {'name'       ,'reactants'    ,'products'         ,'eq_type'  ,'coeffs'                               ,'type' ,'source'};
% >> Charge exchange ------------------------------------------------------
%                  name         reactants       products            eq_type     coeffs                                  type    source
ch_tran         = {'chexHei'    ,{'Hei','Mo'}   ,{'He','Moi'}       ,2          ,[0]                                    ,'ch_trans','Supposed'};
% ch_tran{end+1}         = {'chexMoi'    ,{'Moi','He'}    ,{'Mo','Moi'}        ,2          ,[5.5e-16]                            ,'ch_trans','Supposed'};

% >> Penning ionisation ---------------------------------------------------
%                  name         reactants       products            eq_type     coeffs                                  type    source
penning         = {'Pen'        ,{'Hem2S1','Mo'},{'He','Moi','e'}   ,2          ,[2e-19]                                ,'pen'  ,'Supposed';...
                   'Pen2'       ,{'Hem2S0','Mo'},{'He','Moi','e'}	,2          ,[0]                                    ,'pen'  ,'Supposed'};

% -------------------------------------------------------------------------

reactions_cell = [ch_tran; penning];
reactions_table = cell2table(reactions_cell, 'VariableNames', var_names);
end

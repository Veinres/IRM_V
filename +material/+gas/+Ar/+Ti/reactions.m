function [reactions_table] = reactions()
%SPECIES generate table of titanium + argon species reactions
% =========================================================================
% Generate a table containing relevant titanium + argon species reactions.
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
ch_tran         = {'chexAri'    ,{'Ari','Ti'}   ,{'Ar','Tii'}       ,2          ,[1e-15]                                ,'ch_trans','TiO'};

% >> Penning ionisation ---------------------------------------------------
%                  name         reactants       products            eq_type     coeffs                                  type    source
penning         = {'Pen'        ,{'Arm3P0','Ti'},{'Ar','Tii','e'}   ,2          ,[3.17e-15]                             ,'pen'  ,'TiO';...
                   'Pen'        ,{'Arm3P2','Ti'},{'Ar','Tii','e'}   ,2          ,[3.17e-15]                             ,'pen'  ,'TiO'};

% -------------------------------------------------------------------------

reactions_cell = [ch_tran; penning];
reactions_table = cell2table(reactions_cell, 'VariableNames', var_names);
end


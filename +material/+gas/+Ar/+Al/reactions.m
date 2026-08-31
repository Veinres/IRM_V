function [reactions_table] = reactions()
%SPECIES generate table of aluminium + argon species reactions
% =========================================================================
% Generate a table containing relevant aluminium + argon species reactions.
% =========================================================================

%% NOTES: -----------------------------------------------------------------
% -------------------------------------------------------------------------

%% Reactions table --------------------------------------------------------
%There is absolutely no source for these reaction rates, it's just a guess,
%based on the penning ionisation rates for titanium.
var_names       = {'name'       ,'reactants'    ,'products'         ,'eq_type'  ,'coeffs'                               ,'type' ,'source'};
% >> Charge exchange ------------------------------------------------------
%                  name         reactants       products            eq_type     coeffs                                  type    source
ch_tran         = {'chexAri'    ,{'Ari','Al'}   ,{'Ar','Ali'}       ,2          ,[1e-15]                                ,'ch_trans','Huo2017'};

% >> Penning ionisation ---------------------------------------------------
%                  name         reactants       products            eq_type     coeffs                                  type    source
penning         = {'Pen'        ,{'Arm3P0','Al'},{'Ar','Ali','e'}   ,2          ,[5.9e-16]                             ,'pen'  ,'Huo2017';...
                   'Pen'        ,{'Arm3P2','Al'},{'Ar','Ali','e'}   ,2          ,[5.9e-16]                             ,'pen'  ,'Huo2017'};

% -------------------------------------------------------------------------

reactions_cell = [ch_tran; penning];
reactions_table = cell2table(reactions_cell, 'VariableNames', var_names);
end


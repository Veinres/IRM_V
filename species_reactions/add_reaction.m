function [ NewReactionset] = add_reaction( Rn,Pn,coef_type,coe,ty,rf,Reactionset,nametag)
%UNTITLED Summary of this function goes here
%   Rn: a numerical vector or a cell of strings of Reactants, ex:[1, 2]. Same for Pn. coe should
%   be a vector of length five, that is the Arrehnius coefficients. ty is
%   type and should be a string, ex: 'Wall_reactions'. rf is the reference,
%   of course has to be a string. Reactionset is the reactionset before
%   addition considering.
if isempty(fieldnames(Reactionset)) % means that we are gonna create the first row
    j=length(Reactionset);
else
    j=length(Reactionset)+1; 
end

  Reactionset(j).React=Rn;
  Reactionset(j).Prod=Pn;
  Reactionset(j).Ref=rf;
  Reactionset(j).coef_type=coef_type;
  Reactionset(j).coeffs=coe;
  Reactionset(j).type=ty;
  Reactionset(j).tag=nametag;
  
  NewReactionset=Reactionset;
end


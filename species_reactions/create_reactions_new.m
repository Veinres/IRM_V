function create_reactions_new(Spe)
% create_reactions_new(Spe)
%Reactruct is a big struct that contains all information of the chemistry.
% This function creates one. And will save it.
%   A structure is first created to store the absoulute information of the
%   chemistry by typing the "names" of the reactants and products. Then we
%   encode them in to numbers by a specified string cell, "Names". And then
%   calculate useful quantities that's saved into a final structure and
%   will be used for the matrix formalism calculation of the balance eqs.

% ~~~~~~~~~~~~~~~~~~~~~~
Names=Spe.Names;  % ~~~~   is the only thing that needs input for this file
% ~~~~~~~~~~~~~~~~~~~~~~

%% Adding reactions
Reactionlist=struct(); % creating an empty structure.   

% add_reaction() requires:
% (1) Input species
% (2) Output species
% (3) Reaction equation type (Reaction rate can depend on electron temperature)
% (4) Parameters that correspond to reaction equation type.
% (5) Type. For electron collisions, this specifies whether it is a collision
% with hot or cold electron populations.
% (6) A reference to the source of this reaction
% (7) The reaction set variable to which a reaction is added.
% (8) Nametag of this reaction
% Reaction equation types:
% (1) Electron collision
% K=Parameters(1)*Tel^Parameters(2)*exp(-Parameters(3)/Tel);
% (2) Constant
% K=constant
% (3) loglog polynome
% K=exp(polyval(Polynome,log(T)));

%% Ar

if ismember('Ar',Spe.PSpeciess)

% >> Ionisation from grd state 
[Reactionlist]=add_reaction({'e','Ar'},{'Ari','e','e'},1,[2.34e-14 0.59 17.44],'ion','butler2018three',Reactionlist,'izcAr');
[Reactionlist]=add_reaction({'e','ArH'},{'Ari','e','e'},1,[2.34e-14 0.59 17.44],'ion','butler2018three',Reactionlist,'izcArH');
[Reactionlist]=add_reaction({'e','ArW'},{'Ari','e','e'},1,[2.34e-14 0.59 17.44],'ion','butler2018three',Reactionlist,'izcArW');
[Reactionlist]=add_reaction({'eh','Ar'},{'Ari','eh','e'},1,[8e-14 0.16 27.53],'ion','butler2018three',Reactionlist,'izhAr');
[Reactionlist]=add_reaction({'eh','ArW'},{'Ari','eh','e'},1,[8e-14 0.16 27.53],'ion','butler2018three',Reactionlist,'izhArW');
[Reactionlist]=add_reaction({'eh','ArH'},{'Ari','eh','e'},1,[8e-14 0.16 27.53],'ion','butler2018three',Reactionlist,'izhArH');

[Reactionlist]=add_reaction({'eh','Ar'},{'Arii','eh','e','e'},8,[6.169e-15 1.6316E-17],'ion','butler2018three',Reactionlist,'izhGSAri'); % CHECK : Missing e-?
[Reactionlist]=add_reaction({'eh','ArW'},{'Arii','eh','e','e'},8,[6.169e-15 1.6316E-17],'ion','butler2018three',Reactionlist,'izhGSAri'); % CHECK : Missing e-?
[Reactionlist]=add_reaction({'eh','ArH'},{'Arii','eh','e','e'},8,[6.169e-15 1.6316E-17],'ion','butler2018three',Reactionlist,'izhGSAri'); % CHECK : Missing e-?
[Reactionlist]=add_reaction({'eh','Arm3P0'},{'Arii','eh','e','e'},8,[6.169e-15 1.6316E-17],'ion','butler2018three',Reactionlist,'izhGSAri'); % CHECK : Missing e-?
[Reactionlist]=add_reaction({'eh','Arm3P2'},{'Arii','eh','e','e'},8,[6.169e-15 1.6316E-17],'ion','butler2018three',Reactionlist,'izhGSAri'); % CHECK : Missing e-?


% >> Ionisation from ionised state
% Ar2+ ionization included for the C-IRM, see Elliason 2021
[Reactionlist]=add_reaction({'e','Ari'},{'Arii','e','e'},1,[8.6365e-15 0.6746 24.3019],'ion','butler2018three',Reactionlist,'izcAri');
[Reactionlist]=add_reaction({'eh','Ari'},{'Arii','eh','e'},8,[5.22e-14 4.943e-17],'ion','butler2018three',Reactionlist,'izhAri');

% >> Ionisation from metastable state
% Ar ionization from the metastable levels are fits done by JT to the
% cross-sections of Dixon 1973, see e.g. [Stancu15_045011]. JT refitted
% the cold electron rate coefficient (which gives a close match to those 
% published by Stancu) and made a new fit for the hot electron distribution
% function. For the ionization from the hot electrons, the cross-section 
% extrapolated to 1000eV
% Dixon73 data is for a combined 4s level. Therefore, to consider each of
% the two metastable levels, the data is divided by 2. 
[Reactionlist]=add_reaction({'e','Arm3P0'},{'Ari','e','e'},1,[1.1436e-13  0.2548  4.4005],'ion','butler2018three',Reactionlist,'izcArm3P0'); 
[Reactionlist]=add_reaction({'e','Arm3P2'},{'Ari','e','e'},1,[1.1436e-13  0.2548  4.4005],'ion','butler2018three',Reactionlist,'izcArm3P2'); 
% same applies to the excitation from the two levels from hot electrons
[Reactionlist]=add_reaction({'eh','Arm3P0'},{'Ari','eh','e'},6,[1.5213e-19  -2.9599E-16  1.8155e-13],'ion','butler2018three',Reactionlist,'izhArm3P0');
[Reactionlist]=add_reaction({'eh','Arm3P2'},{'Ari','eh','e'},6,[1.5213e-19  -2.9599E-16  1.8155e-13],'ion','butler2018three',Reactionlist,'izhArm3P2');


%[Reactionlist]=add_reaction({'Ari','Ari'},{'Arii','Ar'},2,[6.4e-18],'ch_trans','',Reactionlist,'chexAri');% FIXME : should this be included?

% >> Excitation from grd state
% these are the new rates from L.L. Alves, ''The IST-Lisbon database on LXCat'' J. Phys. Conf. Series 2014, 565, 1
%  A. Yanguas-Gil, J. Cotrino and L.L. Alves ''An update of argon inelastic cross sections for plasma discharges''
% 2005 J.   Phys. D: Appl. Phys. 38 1588-1598
[Reactionlist]=add_reaction({'e','Ar'},{'Arm3P0','e'},1,[2.8603e-15 -0.8572 14.6219],'exc','butler2018three',Reactionlist,'excAr3P0');
[Reactionlist]=add_reaction({'e','ArW'},{'Arm3P0','e'},1,[2.8603e-15 -0.8572 14.6219],'exc','butler2018three',Reactionlist,'excArW3P0');
[Reactionlist]=add_reaction({'e','ArH'},{'Arm3P0','e'},1,[2.8603e-15 -0.8572 14.6219],'exc','butler2018three',Reactionlist,'excArH3P0');
[Reactionlist]=add_reaction({'e','Ar'},{'Arm3P2','e'},1,[1.6170e-14 -0.8238 14.1256],'exc','butler2018three',Reactionlist,'excAr3P2');
[Reactionlist]=add_reaction({'e','ArW'},{'Arm3P2','e'},1,[1.6170e-14 -0.8238 14.1256],'exc','butler2018three',Reactionlist,'excArW3P2');
[Reactionlist]=add_reaction({'e','ArH'},{'Arm3P2','e'},1,[1.6170e-14 -0.8238 14.1256],'exc','butler2018three',Reactionlist,'excArH3P2');
 
% the same for the Ar^met excitation from the hot electron distribution.
% Each of these has three cross-sections because the cross-sections ar % FIXME QUESTION : Why? explanation is incomplete
[Reactionlist]=add_reaction({'eh','Ar'},{'Arm3P0','eh'},1,[1.8045E-23 2 0],'exc','butler2018three',Reactionlist,'exhAr');
[Reactionlist]=add_reaction({'eh','Ar'},{'Arm3P0','eh'},1,[-2.9825E-20 1 0],'exc','butler2018three',Reactionlist,'exhAr');
[Reactionlist]=add_reaction({'eh','Ar'},{'Arm3P0','eh'},1,[1.3574E-17 0 0],'exc','butler2018three',Reactionlist,'exhAr');
 
[Reactionlist]=add_reaction({'eh','ArW'},{'Arm3P0','eh'},1,[1.8045E-23 2 0],'exc','butler2018three',Reactionlist,'exhAr');
[Reactionlist]=add_reaction({'eh','ArW'},{'Arm3P0','eh'},1,[-2.9825E-20 1 0],'exc','butler2018three',Reactionlist,'exhAr');
[Reactionlist]=add_reaction({'eh','ArW'},{'Arm3P0','eh'},1,[1.3574E-17 0 0],'exc','butler2018three',Reactionlist,'exhAr');
 
[Reactionlist]=add_reaction({'eh','ArH'},{'Arm3P0','eh'},1,[1.8045E-23 2 0],'exc','butler2018three',Reactionlist,'exhAr');
[Reactionlist]=add_reaction({'eh','ArH'},{'Arm3P0','eh'},1,[-2.9825E-20 1 0],'exc','butler2018three',Reactionlist,'exhAr');
[Reactionlist]=add_reaction({'eh','ArH'},{'Arm3P0','eh'},1,[1.3574E-17 0 0],'exc','butler2018three',Reactionlist,'exhAr');
 
[Reactionlist]=add_reaction({'eh','Ar'},{'Arm3P2','eh'},1,[1.1397E-22 2 0],'exc','butler2018three',Reactionlist,'exhAr');
[Reactionlist]=add_reaction({'eh','Ar'},{'Arm3P2','eh'},1,[-1.8975E-19 1 0],'exc','butler2018three',Reactionlist,'exhAr');
[Reactionlist]=add_reaction({'eh','Ar'},{'Arm3P2','eh'},1,[8.7910E-17 0 0],'exc','butler2018three',Reactionlist,'exhAr');
 
[Reactionlist]=add_reaction({'eh','ArW'},{'Arm3P2','eh'},1,[1.1397E-22 2 0],'exc','butler2018three',Reactionlist,'exhAr');
[Reactionlist]=add_reaction({'eh','ArW'},{'Arm3P2','eh'},1,[-1.8975E-19 1 0],'exc','butler2018three',Reactionlist,'exhAr');
[Reactionlist]=add_reaction({'eh','ArW'},{'Arm3P2','eh'},1,[8.7910E-17 0 0],'exc','butler2018three',Reactionlist,'exhAr');
 
[Reactionlist]=add_reaction({'eh','ArH'},{'Arm3P2','eh'},1,[1.1397E-22 2 0],'exc','butler2018three',Reactionlist,'exhAr');
[Reactionlist]=add_reaction({'eh','ArH'},{'Arm3P2','eh'},1,[-1.8975E-19 1 0],'exc','butler2018three',Reactionlist,'exhAr');
[Reactionlist]=add_reaction({'eh','ArH'},{'Arm3P2','eh'},1,[8.7910E-17 0 0],'exc','butler2018three',Reactionlist,'exhAr');

% > Deexcitation
% calculated by Gudmundsson based on detailed balancing
[Reactionlist]=add_reaction({'e','Arm3P0'},{'Ar','e'},1,[2.86e-15 -0.8572 -2.8989],'dexc','butler2018three',Reactionlist,'dexcArm3P0');
[Reactionlist]=add_reaction({'e','Arm3P2'},{'Ar','e'},1,[3.23e-15 -0.8238 -2.578],'dexc','butler2018three',Reactionlist,'dexcArm3P2');
 
% calculated by Gudmundsson based on detailed balancing
[Reactionlist]=add_reaction({'eh','Arm3P0'},{'Ar','eh'},7,[1.8045E-23 -2.9825E-20 1.357E-17 1],'dexc','butler2018three',Reactionlist,'dexhArm3P0');
[Reactionlist]=add_reaction({'eh','Arm3P2'},{'Ar','eh'},7,[1.1397E-22 -1.8975E-19 8.7910E-17 5],'dexc','butler2018three',Reactionlist,'dexhArm3P2');
end

%% Ne
if ismember('Ne',Spe.PSpeciess)
% >> Ionisation from grd state R10
[Reactionlist]=add_reaction({'e','Ne'},{'Nei','e','e'},1,[9.7310e-16 0.9775 21.2151],'ion','krishnakumar1988',Reactionlist,'izcNe'); %R10
[Reactionlist]=add_reaction({'e','NeW'},{'Nei','e','e'},1,[9.7310e-16 0.9775 21.2151],'ion','krishnakumar1988',Reactionlist,'izcNeW'); %R10
[Reactionlist]=add_reaction({'e','NeH'},{'Nei','e','e'},1,[9.7310e-16 0.9775 21.2151],'ion','krishnakumar1988',Reactionlist,'izcNeH'); %R10

[Reactionlist]=add_reaction({'eh','Ne'},{'Nei','eh','e'},1,[1.6217e-10 -1.2025 329.9588],'ion','krishnakumar1988',Reactionlist,'izhNe'); %R10
[Reactionlist]=add_reaction({'eh','NeW'},{'Nei','eh','e'},1,[1.6217e-10 -1.2025 329.9588],'ion','krishnakumar1988',Reactionlist,'izhNeW'); %R10
[Reactionlist]=add_reaction({'eh','NeH'},{'Nei','eh','e'},1,[1.6217e-10 -1.2025 329.9588],'ion','krishnakumar1988',Reactionlist,'izhNeH'); %R10

%R18
%[Reactionlist]=add_reaction({'eh','Ne'},{'Neii','eh','e','e'},1,[9.9929e-12 -1.2324 360.2744],'ion','butler2018three',Reactionlist,'izhGSNei'); % CHECK : Missing e-?

% >> Ionisation from ionised state
% R17
%[Reactionlist]=add_reaction({'eh','Nei'},{'Neii','eh','e'},1,[6.5766e-11 -1.1911 340.0608],'ion','butler2018three',Reactionlist,'izhNei');

% ionizarion from meta states R15,16
[Reactionlist]=add_reaction({'e','Nem2P0'},{'Nei','e','e'},1,[9.72166e-14  0.1227  5.5967],'ion','johnston1996',Reactionlist,'izcNem2P0'); %R15
[Reactionlist]=add_reaction({'e','Nem2P2'},{'Nei','e','e'},1,[9.7216e-14  0.1227  5.5967],'ion','johnston1996',Reactionlist,'izcNem2P2'); %R16
[Reactionlist]=add_reaction({'eh','Nem2P0'},{'Nei','eh','e'},1,[3.9876e-11  -1.2700  54.9432],'ion','johnston1996',Reactionlist,'izhNem2P0'); %R15
[Reactionlist]=add_reaction({'eh','Nem2P2'},{'Nei','eh','e'},1,[3.9876e-11  -1.2700  54.9432],'ion','johnston1996',Reactionlist,'izhNem2P2'); %R16

% excitation from grd to metastable R11, R12
[Reactionlist]=add_reaction({'e','Ne'},{'Nem2P0','e'},1,[2.3859e-16 -0.3753 16.7322],'exc','butler2018three',Reactionlist,'excNe2P0'); %R12
[Reactionlist]=add_reaction({'e','Ne'},{'Nem2P2','e'},1,[1.1890e-15 -0.3794 16.7069],'exc','butler2018three',Reactionlist,'excNe2P2'); %R11
[Reactionlist]=add_reaction({'e','NeW'},{'Nem2P0','e'},1,[2.3859e-16 -0.3753 16.7322],'exc','butler2018three',Reactionlist,'excNeW2P0'); %R12
[Reactionlist]=add_reaction({'e','NeW'},{'Nem2P2','e'},1,[1.1890e-15 -0.3794 16.7069],'exc','butler2018three',Reactionlist,'excNeW2P2'); %R11
[Reactionlist]=add_reaction({'e','NeH'},{'Nem2P0','e'},1,[2.3859e-16 -0.3753 16.7322],'exc','butler2018three',Reactionlist,'excNeH2P0'); %R12
[Reactionlist]=add_reaction({'e','NeH'},{'Nem2P2','e'},1,[1.1890e-15 -0.3794 16.7069],'exc','butler2018three',Reactionlist,'excNeH2P2'); %R11

[Reactionlist]=add_reaction({'eh','Ne'},{'Nem2P0','eh'},1,[1.8427e-14 -1.4649 59.7411],'exc','butler2018three',Reactionlist,'excNe2P0'); %R12
[Reactionlist]=add_reaction({'eh','Ne'},{'Nem2P2','eh'},1,[8.4732e-14 -1.4667 57.3887],'exc','butler2018three',Reactionlist,'excNe2P2'); %R11
[Reactionlist]=add_reaction({'eh','NeW'},{'Nem2P0','eh'},1,[1.8427e-14 -1.4649 59.7411],'exc','butler2018three',Reactionlist,'excNeW2P0'); %R12
[Reactionlist]=add_reaction({'eh','NeW'},{'Nem2P2','eh'},1,[8.4732e-14 -1.4667 57.3887],'exc','butler2018three',Reactionlist,'excNeW2P2'); %R11
[Reactionlist]=add_reaction({'eh','NeH'},{'Nem2P0','eh'},1,[1.8427e-14 -1.4649 59.7411],'exc','butler2018three',Reactionlist,'excNeH2P0'); %R12
[Reactionlist]=add_reaction({'eh','NeH'},{'Nem2P2','eh'},1,[8.4732e-14 -1.4667 57.3887],'exc','butler2018three',Reactionlist,'excNeH2P2'); %R11

% > Deexcitation
% calculated by Gudmundsson based on detailed balancing R13, R14
[Reactionlist]=add_reaction({'e','Nem2P0'},{'Ne','e'},1,[2.3859e-16 -0.3753 0.0],'dexc','',Reactionlist,'dexcNem2P0');
[Reactionlist]=add_reaction({'e','Nem2P2'},{'Ne','e'},1,[2.378e-16 -0.3797 0.0869],'dexc','',Reactionlist,'dexcNem2P2');

[Reactionlist]=add_reaction({'eh','Nem2P0'},{'Ne','eh'},1,[1.8427E-14 -1.4649 43.93],'dexc','',Reactionlist,'dexhNem2P0');
[Reactionlist]=add_reaction({'eh','Nem2P2'},{'Ne','eh'},1,[1.6946E-14 -1.4667 40.7687],'dexc','',Reactionlist,'dexhNem2P2');

%Penning ionisation metastables collision R19
[Reactionlist]=add_reaction({'Nem2P0','Nem2P2'},{'Ne','Nei','eh'},2,[3.20E-16],'pen','',Reactionlist,'Pen');
[Reactionlist]=add_reaction({'Nem2P2','Nem2P2'},{'Ne','Nei','eh'},2,[3.20E-16],'pen','',Reactionlist,'Pen');
[Reactionlist]=add_reaction({'Nem2P0','Nem2P0'},{'Ne','Nei','eh'},2,[3.20E-16],'pen','',Reactionlist,'Pen');
[Reactionlist]=add_reaction({'Nem2P2','Nem2P0'},{'Ne','Nei','eh'},2,[3.20E-16],'pen','',Reactionlist,'Pen');

end

%% Ar Ne
if ismember('Ar',Spe.PSpeciess) && ismember('Ne',Spe.PSpeciess)

%charge exchange
[Reactionlist]=add_reaction({'Nei','Ar'},{'Ne','Ari'},2,[6.40E-18],'ch_trans','',Reactionlist,'chexNeiAr');
[Reactionlist]=add_reaction({'Nei','Arm3P2'},{'Ne','Ari'},2,[6.40E-18],'ch_trans','',Reactionlist,'chexNeiAr');
[Reactionlist]=add_reaction({'Nei','Arm3P0'},{'Ne','Ari'},2,[6.40E-18],'ch_trans','',Reactionlist,'chexNeiAr');

%Penning ionisation 
%[Reactionlist]=add_reaction({'Arm3P0','Nem3P2'},{'Ne','Ari','eh'},2,[3.20E-16],'pen','',Reactionlist,'Pen');
%[Reactionlist]=add_reaction({'Arm3P2','Nem3P2'},{'Ne','Ari','eh'},2,[3.20E-16],'pen','',Reactionlist,'Pen');
%[Reactionlist]=add_reaction({'Arm3P0','Nem3P0'},{'Ne','Ari','eh'},2,[3.20E-16],'pen','',Reactionlist,'Pen');
%[Reactionlist]=add_reaction({'Arm3P2','Nem3P0'},{'Ne','Ari','eh'},2,[3.20E-16],'pen','',Reactionlist,'Pen');
%[Reactionlist]=add_reaction({'Nem3P0','Arm3P2'},{'Ne','Ari','eh'},2,[3.20E-16],'pen','',Reactionlist,'Pen');
%[Reactionlist]=add_reaction({'Nem3P2','Arm3P2'},{'Ne','Ari','eh'},2,[3.20E-16],'pen','',Reactionlist,'Pen');
%[Reactionlist]=add_reaction({'Nem3P0','Arm3P0'},{'Ne','Ari','eh'},2,[3.20E-16],'pen','',Reactionlist,'Pen');
%[Reactionlist]=add_reaction({'Nem3P2','Arm3P0'},{'Ne','Ari','eh'},2,[3.20E-16],'pen','',Reactionlist,'Pen');

end   

%% He

if ismember('He',Spe.PSpeciess)

% >> Ionisation from grd state
% Ionisation of helium (24.58eV) by cold electron (1-15eV) isnt possible 

[Reactionlist]=add_reaction({'e','He'},{'Hei','e','e'},1,[2.1394E-15 0.6321 24.5919],'ion','BiagiV8.97',Reactionlist,'izcHe');
[Reactionlist]=add_reaction({'e','HeW'},{'Hei','e','e'},1,[2.1394E-15 0.6321 24.5919],'ion','BiagiV8.97',Reactionlist,'izcHeW');
[Reactionlist]=add_reaction({'e','HeH'},{'Hei','e','e'},1,[2.1394E-15 0.6321 24.5919],'ion','BiagiV8.97',Reactionlist,'izcHeH');

[Reactionlist]=add_reaction({'e','He'},{'Hei','e','e'},2,[0.0],'ion','BiagiV8.97',Reactionlist,'izcHe');
[Reactionlist]=add_reaction({'e','HeW'},{'Hei','e','e'},2,[0.0],'ion','BiagiV8.97',Reactionlist,'izcHeW');
[Reactionlist]=add_reaction({'e','HeH'},{'Hei','e','e'},2,[0.0],'ion','BiagiV8.97',Reactionlist,'izcHeH');

[Reactionlist]=add_reaction({'eh','He'},{'Hei','eh','e'},1,[6.1442E-11 -1.2 305.7],'ion','BiagiV8.97',Reactionlist,'izhHe');
[Reactionlist]=add_reaction({'eh','HeW'},{'Hei','eh','e'},1,[6.1442E-11 -1.2 305.7],'ion','BiagiV8.97',Reactionlist,'izhHeW');
[Reactionlist]=add_reaction({'eh','HeH'},{'Hei','eh','e'},1,[6.1442E-11 -1.2 305.7],'ion','BiagiV8.97',Reactionlist,'izhHeH');

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

[Reactionlist]=add_reaction({'e','Hem2S1'},{'He','e'},1,[2.3459e-15 -0.7374 20.1227],'dexc','BiagiV8.97',Reactionlist,'dexcHem2S1');
[Reactionlist]=add_reaction({'e','Hem2S0'},{'He','e'},1,[9.3116e-16  -0.3126  20.4779],'dexc','BiagiV8.97',Reactionlist,'dexcHem2S0');
[Reactionlist]=add_reaction({'e','He2P012'},{'He','e'},1,[2.3401e-15 -0.4682 21.8094],'dexc','BiagiV8.97',Reactionlist,'dexcHe2P012');
[Reactionlist]=add_reaction({'e','He2P1'},{'He','e'},1,[1.3083e-15 0.5650 20.6208],'dexc','BiagiV8.97',Reactionlist,'dexcHe2P1');


[Reactionlist]=add_reaction({'eh','Hem2S1'},{'He','eh'},1,[6.5132e-14 -1.4435 70.9356],'dexc','BiagiV8.97',Reactionlist,'dexhHem2S1');
[Reactionlist]=add_reaction({'eh','Hem2S0'},{'He','eh'},1,[2.4735e-13 -1.1477 208.8655],'dexc','BiagiV8.97',Reactionlist,'dexhHem2S0');
[Reactionlist]=add_reaction({'eh','He2P012'},{'He','eh'},1,[1.6293e-13 -1.4598 71.6636],'dexc','BiagiV8.97',Reactionlist,'dexhHe2P012');
[Reactionlist]=add_reaction({'eh','He2P1'},{'He','eh'},1,[2.1952e-11 -1.1823 283.3282],'dexc','BiagiV8.97',Reactionlist,'dexhHe2P1');

end

%% Ti

if ismember("Ti",Spe.PSpeciess)
    
% > Ionisation from grd state
[Reactionlist]=add_reaction({'e','Ti'},{'Tii','e','e'},1,[2.8278e-13 0.0579 8.7163],'ion','TiO',Reactionlist,'izcTi'); % NOTE : the sign of Te exponent is different Huo17
[Reactionlist]=add_reaction({'eh','Ti'},{'Tii','eh','e'},1,[1.1757e-12 -0.3039 21.1107],'ion','TiO',Reactionlist,'izhTi');

% > Ionisation from ionised state
[Reactionlist]=add_reaction({'e','Tii'},{'Tiii','e','e'},1,[1.8556e-14 0.4598 12.9927],'ion','TiO',Reactionlist,'izcTii');
[Reactionlist]=add_reaction({'eh','Tii'},{'Tiii','eh','e'},1,[8.1858e-12 -0.669 200.93],'ion','TiO',Reactionlist,'izhTii');

% > Ar interaction
if ismember("Ar",Spe.PSpeciess)
[Reactionlist]=add_reaction({'Ari','Ti'},{'Ar','Tii'},2,[1e-15],'ch_trans','TiO',Reactionlist,'chexAri'); 
[Reactionlist]=add_reaction({'Arm3P0','Ti'},{'Ar','Tii','e'},2,[3.17e-15],'pen','TiO',Reactionlist,'Pen');
[Reactionlist]=add_reaction({'Arm3P2','Ti'},{'Ar','Tii','e'},2,[3.17e-15],'pen','TiO',Reactionlist,'Pen');
end

end

%% W

if ismember('W',Spe.PSpeciess)
    
% > Ionisation from grd state
[Reactionlist]=add_reaction({'e','W'},{'Wi','e','e'},1,[6.3966e-14 0.4839 8.221],'ion','WO',Reactionlist,'izcW');
[Reactionlist]=add_reaction({'eh','W'},{'Wi','eh','e'},1,[4.2507e-10 -1.1791 256.38],'ion','WO',Reactionlist,'izhW');

% > Ionisation from ionised state
[Reactionlist]=add_reaction({'e','Wi'},{'Wii','e','e'},1,[1.446e-14 0.7143 14.5193],'ion','WO',Reactionlist,'izcWi');
[Reactionlist]=add_reaction({'eh','Wi'},{'Wii','eh','e'},1,[4.2507e-10 -1.3047 273.55],'ion','WO',Reactionlist,'izhWi');

% > Ar interaction
if ismember('Ar',Spe.PSpeciess)
[Reactionlist]=add_reaction({'Ari','W'},{'Ar','Wi'},2,[2e-16],'ch_trans','WO',Reactionlist,'chexAri'); 
[Reactionlist]=add_reaction({'Arm3P0','W'},{'Ar','Wi','e'},2,[5.3e-15],'pen','WO',Reactionlist,'Pen');
[Reactionlist]=add_reaction({'Arm3P2','W'},{'Ar','Wi','e'},2,[5.3e-15],'pen','WO',Reactionlist,'Pen');
end

end

%% C

%%if ismember('C',Spe.PSpeciess)

% FIXME MERGE !!! NOTE: seems unused anyway
%%error('!!!!!!');

%%cd('../pre-cal/carbon')
%%load carbon_C_Rea.mat
%%cd('../../species_reactions')
%{
[Reactionlist]=add_reaction({'C','eh'},{'Ci','eh','e'},1,[3.692e-15,1.182,9.332],'eH','reference',Reactionlist,'izhC');
[Reactionlist]=add_reaction({'C','e'},{'Ci','e','e'},1,[3.692e-15,1.182,9.332],'eC','reference',Reactionlist,'izcC');
[Reactionlist]=add_reaction({'Cm1','eh'},{'Ci','eh','e'},1,[3.692e-15,1.182,9.332],'eH','reference',Reactionlist,'izhC');
[Reactionlist]=add_reaction({'Cm1','e'},{'Ci','e','e'},1,[3.692e-15,1.182,9.332],'eC','reference',Reactionlist,'izcC');
[Reactionlist]=add_reaction({'Cm2','eh'},{'Ci','eh','e'},1,[3.692e-15,1.182,9.332],'eH','reference',Reactionlist,'izhC');
[Reactionlist]=add_reaction({'Cm2','e'},{'Ci','e','e'},1,[3.692e-15,1.182,9.332],'eC','reference',Reactionlist,'izcC');
[Reactionlist]=add_reaction({'Cm3','eh'},{'Ci','eh','e'},1,[3.692e-15,1.182,9.332],'eH','reference',Reactionlist,'izhC');
[Reactionlist]=add_reaction({'Cm3','e'},{'Ci','e','e'},1,[3.692e-15,1.182,9.332],'eC','reference',Reactionlist,'izcC');
%}
if ismember('C',Spe.PSpeciess) && ismember('Ar',Spe.PSpeciess) 
%There is absolutely no source for these reaction rates, it's just a guess,

%based on the penning ionization rates for titanium.
%
[Reactionlist]=add_reaction({'Ari','C'},{'Ar','Ci'},2,[6.4e-18],'ch_trans','',Reactionlist,'chexAri'); %
[Reactionlist]=add_reaction({'Ari','Cm1'},{'Ar','Ci'},2,[6.4e-18],'ch_trans','',Reactionlist,'chexAri');
[Reactionlist]=add_reaction({'Ari','Cm2'},{'Ar','Ci'},2,[6.4e-18],'ch_trans','',Reactionlist,'chexAri');
[Reactionlist]=add_reaction({'Ari','Cm3'},{'Ar','Ci'},2,[6.4e-18],'ch_trans','',Reactionlist,'chexAri'); 
[Reactionlist]=add_reaction({'Arm3P0','C'},{'Ar','Ci','e'},2,[4.2e-15],'pen','',Reactionlist,'Pen');
[Reactionlist]=add_reaction({'Arm3P0','Cm1'},{'Ar','Ci','e'},2,[4.2e-15],'pen','',Reactionlist,'Pen');
[Reactionlist]=add_reaction({'Arm3P0','Cm2'},{'Ar','Ci','e'},2,[4.2e-15],'pen','',Reactionlist,'Pen');
[Reactionlist]=add_reaction({'Arm3P0','Cm3'},{'Ar','Ci','e'},2,[4.2e-15],'pen','',Reactionlist,'Pen');
[Reactionlist]=add_reaction({'Arm3P2','C'},{'Ar','Ci','e'},2,[4.2e-15],'pen','',Reactionlist,'Pen');
[Reactionlist]=add_reaction({'Arm3P2','Cm1'},{'Ar','Ci','e'},2,[4.2e-15],'pen','',Reactionlist,'Pen');
[Reactionlist]=add_reaction({'Arm3P2','Cm2'},{'Ar','Ci','e'},2,[4.2e-15],'pen','',Reactionlist,'Pen');
[Reactionlist]=add_reaction({'Arm3P2','Cm3'},{'Ar','Ci','e'},2,[4.2e-15],'pen','',Reactionlist,'Pen');
%
%added by Henrik Eliasson, 2021-03-26
%doubly ionized hot and cold e
[Reactionlist]=add_reaction({'Ci','e'},{'Cii','e','e'},1,[8.98e-15 0.3872 24.56],'ion','',Reactionlist,'izcCi');
[Reactionlist]=add_reaction({'Ci','eh'},{'Cii','eh','e'},1,[1.4838e-13 -0.2304 67.33],'ion','',Reactionlist,'izhCi');
%C->Cm1(C'1D') hot and cold e
[Reactionlist]=add_reaction({'C','e'},{'Cm1','e'},1,[3.315e-14 -0.498 1.995],'exc','',Reactionlist,'excC');
[Reactionlist]=add_reaction({'C','eh'},{'Cm1','eh'},8,[3.489e-15 2.504e-17],'exc','',Reactionlist,'exhC');
%C->Cm2(C'1S') hot and cold e
[Reactionlist]=add_reaction({'C','e'},{'Cm2','e'},1,[4.9e-15 -0.584 3.462],'exc','',Reactionlist,'excC');
[Reactionlist]=add_reaction({'C','eh'},{'Cm2','eh'},8,[3.543e-16 2.581e-18],'exc','',Reactionlist,'exhC');
%C->Cm3(C'5S0') hot and cold e
[Reactionlist]=add_reaction({'C','e'},{'Cm3','e'},1,[3.831e-14 -0.813 5.057],'exc','',Reactionlist,'excC');
[Reactionlist]=add_reaction({'C','eh'},{'Cm3','eh'},8,[1.701e-15 1.2105e-17],'exc','',Reactionlist,'exhC');
%Cm1->C hot and cold e
[Reactionlist]=add_reaction({'Cm1','e'},{'C','e'},1,[6.78e-15 -0.523 0.757],'dexc','',Reactionlist,'dexcC');
[Reactionlist]=add_reaction({'Cm1','eh'},{'C','eh'},8,[7.1673e-16 5.018e-18],'dexc','',Reactionlist,'dexhC');
%Cm2->C hot and cold e
[Reactionlist]=add_reaction({'Cm2','e'},{'C','e'},1,[5.193e-15 -0.6205 0.8638],'dexc','',Reactionlist,'dexcC');
[Reactionlist]=add_reaction({'Cm2','eh'},{'C','eh'},8,[3.7491e-16 2.7709e-18],'dexc','',Reactionlist,'dexhC');
%Cm3->C hot and cold e
[Reactionlist]=add_reaction({'Cm3','e'},{'C','e'},1,[7.275e-15 -0.7829 0.9309],'dexc','',Reactionlist,'dexcC');
[Reactionlist]=add_reaction({'Cm3','eh'},{'C','eh'},8,[3.7181e-16 2.7095e-18],'dexc','',Reactionlist,'dexhC');
%Cm1->Cm2 hot and cold e
[Reactionlist]=add_reaction({'Cm1','e'},{'Cm2','e'},1,[5.796e-15 -0.2076 1.6752],'exc','',Reactionlist,'excC');
[Reactionlist]=add_reaction({'Cm1','eh'},{'Cm2','eh'},8,[3.4144e-15 1.0218e-17],'exc','',Reactionlist,'exhC');
%Cm2->Cm1 hot and cold e
[Reactionlist]=add_reaction({'Cm2','e'},{'Cm1','e'},1,[2.738e-14 -0.1811 1.3185],'dexc','',Reactionlist,'dexcC');
[Reactionlist]=add_reaction({'Cm2','eh'},{'Cm1','eh'},8,[1.8364e-14 6.0929e-17],'dexc','',Reactionlist,'dexhC');
%Ionization
%C
[Reactionlist]=add_reaction({'C','e'},{'Ci','e','e'},1,[1.515e-14 0.5868 11.8972],'ion','',Reactionlist,'izcC');
[Reactionlist]=add_reaction({'C','eh'},{'Ci','eh','e'},8,[1.4348e-13 3.3441e-17],'ion','',Reactionlist,'izhC');
%Cm1
[Reactionlist]=add_reaction({'Cm1','e'},{'Ci','e','e'},1,[1.4120e-14 0.5991 10.7],'ion','',Reactionlist,'izcC1');
[Reactionlist]=add_reaction({'Cm1','eh'},{'Ci','eh','e'},8,[1.433e-13 3.33e-17],'ion','',Reactionlist,'izhC1');
%Cm2
[Reactionlist]=add_reaction({'Cm2','e'},{'Ci','e','e'},1,[1.21e-14 0.6404 9.2267],'ion','',Reactionlist,'izcC2');
[Reactionlist]=add_reaction({'Cm2','eh'},{'Ci','eh','e'},8,[1.433e-13 3.33e-17],'ion','',Reactionlist,'izhC2');
%Cm3
[Reactionlist]=add_reaction({'Cm3','e'},{'Ci','e','e'},1,[1.008e-14 0.6819 7.2335],'ion','',Reactionlist,'izcC3');
[Reactionlist]=add_reaction({'Cm3','eh'},{'Ci','eh','e'},8,[1.428e-13 3.32e-17],'ion','',Reactionlist,'izhC3');

end % test

if ismember('C',Spe.PSpeciess) && ismember('Ne',Spe.PSpeciess)

[Reactionlist]=add_reaction({'Nei','C'},{'Ne','Ci'},2,[6.4e-18],'ch_trans','',Reactionlist,'chexNei'); %
[Reactionlist]=add_reaction({'Nei','Cm1'},{'Ne','Ci'},2,[6.4e-18],'ch_trans','',Reactionlist,'chexAri');
[Reactionlist]=add_reaction({'Nei','Cm2'},{'Ne','Ci'},2,[6.4e-18],'ch_trans','',Reactionlist,'chexAri');
[Reactionlist]=add_reaction({'Nei','Cm3'},{'Ne','Ci'},2,[6.4e-18],'ch_trans','',Reactionlist,'chexAri'); 
[Reactionlist]=add_reaction({'Nem2P0','C'},{'Ne','Ci','e'},2,[4.2e-15],'pen','',Reactionlist,'Pen');
[Reactionlist]=add_reaction({'Nem2P0','Cm1'},{'Ne','Ci','e'},2,[4.2e-15],'pen','',Reactionlist,'Pen');
[Reactionlist]=add_reaction({'Nem2P0','Cm2'},{'Ne','Ci','e'},2,[4.2e-15],'pen','',Reactionlist,'Pen');
[Reactionlist]=add_reaction({'Nem2P0','Cm3'},{'Ne','Ci','e'},2,[4.2e-15],'pen','',Reactionlist,'Pen');
[Reactionlist]=add_reaction({'Nem2P2','C'},{'Ne','Ci','e'},2,[4.2e-15],'pen','',Reactionlist,'Pen');
[Reactionlist]=add_reaction({'Nem2P2','Cm1'},{'Ne','Ci','e'},2,[4.2e-15],'pen','',Reactionlist,'Pen');
[Reactionlist]=add_reaction({'Nem2P2','Cm2'},{'Ne','Ci','e'},2,[4.2e-15],'pen','',Reactionlist,'Pen');
[Reactionlist]=add_reaction({'Nem2P2','Cm3'},{'Ne','Ci','e'},2,[4.2e-15],'pen','',Reactionlist,'Pen');

end

%% Cu

if ismember('Cu',Spe.PSpeciess)

% > Ionisation
%20
[Reactionlist]=add_reaction({'e','Cu'},{'Cui','e','e'},1,[3.898e-14 0.484 7.1344],'ion','JTG',Reactionlist,'izcCu');
[Reactionlist]=add_reaction({'eh','Cu'},{'Cui','eh','e'},8,[1.6508e-13  4.7434e-16],'ion','JTG',Reactionlist,'izhCu');
%21
[Reactionlist]=add_reaction({'e','Cum1'},{'Cui','e','e'},1,[3.2926e-14 0.5282 5.7511],'ion','JTG',Reactionlist,'izcCum1');
[Reactionlist]=add_reaction({'eh','Cum1'},{'Cui','eh','e'},8,[1.6423e-13 4.7394e-16],'ion','JTG',Reactionlist,'izhCum1');
%22
[Reactionlist]=add_reaction({'e','Cum2'},{'Cui','e','e'},1,[3.1879e-14 0.5369 5.504],'ion','JTG',Reactionlist,'izcCum2');
[Reactionlist]=add_reaction({'eh','Cum2'},{'Cui','eh','e'},8,[1.6407e-13 4.7384e-16],'ion','JTG',Reactionlist,'izhCum2');
%23
[Reactionlist]=add_reaction({'e','Cum3'},{'Cui','e','e'},1,[2.3576e-14 0.6213 3.4204],'ion','JTG',Reactionlist,'izcCum3');
[Reactionlist]=add_reaction({'eh','Cum3'},{'Cui','eh','e'},8,[1.6261e-13 4.7258e-16],'ion','JTG',Reactionlist,'izhCum3');
%24
[Reactionlist]=add_reaction({'e','Cui'},{'Cuii','e','e'},1,[2.0485e-15 0.325 33.1],'ion','JTG',Reactionlist,'izcCui');
[Reactionlist]=add_reaction({'eh','Cui'},{'Cuii','eh','e'},8,[6.2816e-15 1.553e-17],'ion','JTG',Reactionlist,'izhCui');

% > Excitation
%10
[Reactionlist]=add_reaction({'e','Cu'},{'Cum1','e'},1,[4.0774e-14 -0.6702 2.162],'exc','JTG',Reactionlist,'excCu');
[Reactionlist]=add_reaction({'eh','Cu'},{'Cum1','eh'},1,[9.1027e-13 -1.2646 92.15],'exc','JTG',Reactionlist,'exhCu');
%11
[Reactionlist]=add_reaction({'e','Cu'},{'Cum2','e'},1,[2.6154e-14 -0.6436 2.4424],'exc','JTG',Reactionlist,'excCu');
[Reactionlist]=add_reaction({'eh','Cu'},{'Cum2','eh'},1,[6.50e-13 -1.264 93.92],'exc','JTG',Reactionlist,'exhCu');
%12
[Reactionlist]=add_reaction({'e','Cu'},{'Cum3','e'},1,[1.9064e-13 -0.1462 4.5264],'exc','JTG',Reactionlist,'excCu');
[Reactionlist]=add_reaction({'eh','Cu'},{'Cum3','eh'},8,[2.0912e-13 1.5119e-16],'exc','JTG',Reactionlist,'exhCu');
%13
[Reactionlist]=add_reaction({'e','Cum3'},{'Cu','e'},1,[1.271e-13 -0.1462 0.7364],'dexc','JTG',Reactionlist,'dexcCum3');
[Reactionlist]=add_reaction({'eh','Cum3'},{'Cu','eh'},9,[1.394e-13 -1.008e-16 -3.79],'dexc','JTG',Reactionlist,'dexhCum3');
%14
[Reactionlist]=add_reaction({'e','Cum3'},{'Cum1','e'},2,[2e6],'dexc','JTG',Reactionlist,'dexcCum3');
[Reactionlist]=add_reaction({'eh','Cum3'},{'Cum1','eh'},2,[2e6],'dexc','JTG',Reactionlist,'dexhCum3');
%15
[Reactionlist]=add_reaction({'e','Cum3'},{'Cum2','e'},2,[1.65e6],'dexc','JTG',Reactionlist,'dexcCum3');
[Reactionlist]=add_reaction({'eh','Cum3'},{'Cum2','eh'},2,[1.65e6],'dexc','JTG',Reactionlist,'dexhCum3');
%16
[Reactionlist]=add_reaction({'e','Cum3'},{'Cu','e'},2,[1.39e8],'dexc','JTG',Reactionlist,'dexcCum3');
[Reactionlist]=add_reaction({'eh','Cum3'},{'Cu','eh'},2,[1.39e8],'dexc','JTG',Reactionlist,'dexhCum3');
%17
[Reactionlist]=add_reaction({'e','Cum1'},{'Cu','e'},1,[1.359e-14 -0.523 0.772],'dexc','JTG',Reactionlist,'dexcCum1');
[Reactionlist]=add_reaction({'eh','Cum1'},{'Cu','eh'},1,[3.034e-13 -1.2646 90.81],'dexc','JTG',Reactionlist,'dexhCum1');
%18
[Reactionlist]=add_reaction({'e','Cum2'},{'Cu','e'},1,[1.3077e-14 -0.6536 0.8],'dexc','JTG',Reactionlist,'dexcCum2');
[Reactionlist]=add_reaction({'eh','Cum2'},{'Cu','eh'},1,[3.25e-13 -1.264 92.28],'dexc','JTG',Reactionlist,'dexhCum2');
%19
[Reactionlist]=add_reaction({'e','Cum1'},{'Cum2','e'},1,[1.1757e-13 0.0075 0.2355],'exc','JTG',Reactionlist,'excCum1');
[Reactionlist]=add_reaction({'eh','Cum1'},{'Cum2','eh'},8,[1.2944e-13 8.9187e-17],'exc','JTG',Reactionlist,'exhCum1');

% Ar interaction
if ismember('Ar',Spe.PSpeciess)
%25
[Reactionlist]=add_reaction({'Ari','Cu'},{'Ar','Cui'},2,[1e-15],'ch_trans','Supposed',Reactionlist,'chexAri'); 
%26
[Reactionlist]=add_reaction({'Arm3P0','Cu'},{'Ar','Cui','e'},2,[4.2e-15],'pen','Supposed',Reactionlist,'Pen');
[Reactionlist]=add_reaction({'Arm3P0','Cum1'},{'Ar','Cui','e'},2,[4.2e-15],'pen','Supposed',Reactionlist,'Pen');
[Reactionlist]=add_reaction({'Arm3P0','Cum2'},{'Ar','Cui','e'},2,[4.2e-15],'pen','Supposed',Reactionlist,'Pen');
%27
[Reactionlist]=add_reaction({'Arm3P2','Cu'},{'Ar','Cui','e'},2,[4.2e-15],'pen','Supposed',Reactionlist,'Pen');
[Reactionlist]=add_reaction({'Arm3P2','Cum1'},{'Ar','Cui','e'},2,[4.2e-15],'pen','Supposed',Reactionlist,'Pen');
[Reactionlist]=add_reaction({'Arm3P2','Cum2'},{'Ar','Cui','e'},2,[4.2e-15],'pen','Supposed',Reactionlist,'Pen');
end
end


% %% Cr
% 
% if ismember('Cr',Spe.PSpeciess)
% 
% % Ionisation
% % single ionization
% [Reactionlist]=add_reaction({'e','Cr'},{'Cri','e','e'},1,[8.95E-14 0.4682 7.0786],'ion','JTG',Reactionlist,'izcCr');
% [Reactionlist]=add_reaction({'eh','Cr'},{'Cri','eh','e'},8,[4.0586E-13 2.6729E-16],'ion','JTG',Reactionlist,'izhCr');
% % double ionization
% [Reactionlist]=add_reaction({'e','Cri'},{'Crii','e','e'},1,[9.2132-15 0.5702 14.3882],'ion','JTG',Reactionlist,'izcCri');
% [Reactionlist]=add_reaction({'eh','Cri'},{'Crii','eh','e'},8,[9.2457E-14 5.7450E-17],'ion','JTG',Reactionlist,'izhCri');
% % double ionization from ground state
% [Reactionlist]=add_reaction({'e','Cr'},{'Crii','e','e','e'},1,[2,9309-16 1.2029 20.8886],'ion','JTG',Reactionlist,'izcGSCri');
% [Reactionlist]=add_reaction({'eh','Cr'},{'Crii','eh','e','e'},8,[5.6848E-14 3.6485E-17],'ion','JTG',Reactionlist,'izhGSCri');
% 
% if ismember('Ar',Spe.PSpeciess)
%         [Reactionlist]=add_reaction({'Ari','Cr'},{'Ar','Cri'},2,[2e-16],'ch_trans','Supposed',Reactionlist,'chexAri'); 
%         [Reactionlist]=add_reaction({'Arm3P0','Cr'},{'Ar','Cri','e'},2,[5.3e-15],'pen','Supposed',Reactionlist,'Pen');
%         [Reactionlist]=add_reaction({'Arm3P2','Cr'},{'Ar','Cri','e'},2,[5.3e-15],'pen','Supposed',Reactionlist,'Pen');
% end
% end

%% Cr 

if ismember('Cr',Spe.PSpeciess)

% Ionisation
% single ionization
[Reactionlist]=add_reaction({'e','Cr'},{'Cri','e','e'},1,[8.95E-14 0.4682 7.0786],'ion','JTG',Reactionlist,'izcCr');
[Reactionlist]=add_reaction({'eh','Cr'},{'Cri','eh','e'},8,[4.0586E-13 2.6729E-16],'ion','JTG',Reactionlist,'izhCr');
% double ionization
[Reactionlist]=add_reaction({'e','Cri'},{'Crii','e','e'},1,[9.2132-15 0.5702 14.3882],'ion','JTG',Reactionlist,'izcCri');
[Reactionlist]=add_reaction({'eh','Cri'},{'Crii','eh','e'},8,[9.2457E-14 5.7450E-17],'ion','JTG',Reactionlist,'izhCri');
% double ionization from ground state DOESN'T WORK
%[Reactionlist]=add_reaction({'e','Cr'},{'Crii','e','e','e'},1,[2,9309-16 1.2029 20.8886],'ion','JTG',Reactionlist,'izcGSCri');
[Reactionlist]=add_reaction({'eh','Cr'},{'Crii','eh','e','e'},8,[5.6848E-14 3.6485E-17],'ion','JTG',Reactionlist,'izhGSCri');
    
if ismember('Ar',Spe.PSpeciess)
        %[Reactionlist]=add_reaction({'Ari','Cr'},{'Ar','Cri'},2,[2e-16],'ch_trans','Supposed',Reactionlist,'chexAri'); 
        %[Reactionlist]=add_reaction({'Arm3P0','Cr'},{'Ar','Cri','e'},2,[5.3e-15],'pen','Supposed',Reactionlist,'Pen');
        %[Reactionlist]=add_reaction({'Arm3P2','Cr'},{'Ar','Cri','e'},2,[5.3e-15],'pen','Supposed',Reactionlist,'Pen');

        [Reactionlist]=add_reaction({'Ari','Cr'},{'Ar','Cri'},2,[6.2e-16],'ch_trans','Supposed',Reactionlist,'chexAri'); 
        [Reactionlist]=add_reaction({'Arm3P0','Cr'},{'Ar','Cri','e'},2,[2.38e-16],'pen','Supposed',Reactionlist,'Pen');
        [Reactionlist]=add_reaction({'Arm3P2','Cr'},{'Ar','Cri','e'},2,[2.38e-16],'pen','Supposed',Reactionlist,'Pen');

        %[Reactionlist]=add_reaction({'Ari','Cr'},{'Ar','Cri'},2,[12.47e-15],'ch_trans','Supposed',Reactionlist,'chexAri'); 
        %[Reactionlist]=add_reaction({'Arm3P0','Cr'},{'Ar','Cri','e'},2,[2.38e-16],'pen','Supposed',Reactionlist,'Pen');
        %[Reactionlist]=add_reaction({'Arm3P2','Cr'},{'Ar','Cri','e'},2,[2.38e-16],'pen','Supposed',Reactionlist,'Pen');

end
end


%% Mo

if ismember('Mo',Spe.PSpeciess)

% Ionisation
% single ionization
[Reactionlist]=add_reaction({'e','Mo'},{'Moi','e','e'},1,[4.95E-14 0.7 7.6],'ion','JTG',Reactionlist,'izcMo');
[Reactionlist]=add_reaction({'eh','Mo'},{'Moi','eh','e'},8,[4.0134E-13 1.1436E-16],'ion','JTG',Reactionlist,'izhMo');
% doubly ionization
[Reactionlist]=add_reaction({'e','Moi'},{'Moii','e','e'},1,[2.91E-14 0.5 16.57],'ion','JTG',Reactionlist,'izcMoi');
[Reactionlist]=add_reaction({'eh','Moi'},{'Moii','eh','e'},8,[1.6688E-13 3.859E-17],'ion','JTG',Reactionlist,'izhMoi');

% > Excitation
% no excitation for Mo

% Ar interaction
if ismember('Ar',Spe.PSpeciess)
    [Reactionlist]=add_reaction({'Ari','Mo'},{'Ar','Moi'},2,[2e-16],'ch_trans','Supposed',Reactionlist,'chexAri'); 
    [Reactionlist]=add_reaction({'Arm3P0','Mo'},{'Ar','Moi','e'},2,[5.3e-15],'pen','Supposed',Reactionlist,'Pen');
    [Reactionlist]=add_reaction({'Arm3P2','Mo'},{'Ar','Moi','e'},2,[5.3e-15],'pen','Supposed',Reactionlist,'Pen');
end
if ismember('He',Spe.PSpeciess)
    [Reactionlist]=add_reaction({'Hei','Mo'},{'He','Moi'},2,[0],'ch_trans','K.L.Bell',Reactionlist,'chexHei');
    % [Reactionlist]=add_reaction({'Moi','He'},{'Mo','Hei'},2,[5.5e-16],'ch_trans','Supposed',Reactionlist,'chexMoi');
    [Reactionlist]=add_reaction({'Hem2S1','Mo'},{'He','Moi','e'},2,[2e-19],'pen','Supposed',Reactionlist,'Pen');
    [Reactionlist]=add_reaction({'Hem2S0','Mo'},{'He','Moi','e'},2,[0],'pen','Supposed',Reactionlist,'Pen2');
end
end

%% Al R9,10,15,16 huo17

if ismember("Al",Spe.PSpeciess)
    
% > Ionisation from grd state R9
[Reactionlist]=add_reaction({'e','Al'},{'Ali','e','e'},1,[1.3467e-13 0.3576 6.7829],'ion','huo17',Reactionlist,'izcAl');
% [Reactionlist]=add_reaction({'eh','Al'},{'Ali','eh','e'},3,[-0.074347 0.637867 -29.516747],'ion','huo17',Reactionlist,'izhAl'); rea 3 is not suported type
[Reactionlist]=add_reaction({'eh','Al'},{'Ali','eh','e'},8,[3.6186e-13 1.061e-15],'ion','huo17',Reactionlist,'izhAl');

% > Ionisation from ionised state R10
[Reactionlist]=add_reaction({'e','Ali'},{'Alii','e','e'},1,[2.34e-14 0.59 17.44],'ion','huo17',Reactionlist,'izcAli');
%[Reactionlist]=add_reaction({'eh','Ali'},{'Alii','eh','e'},3,[-0.1008
%1.2011 -34.5841],'ion','huo17',Reactionlist,'izhAli'); rea 3
[Reactionlist]=add_reaction({'eh','Ali'},{'Alii','eh','e'},8,[2.103e-14 5.3376e-17],'ion','huo17',Reactionlist,'izhAli');

% > Ar interaction R15, R16
if ismember("Ar",Spe.PSpeciess)
[Reactionlist]=add_reaction({'Ari','Al'},{'Ar','Ali'},2,[1e-15],'ch_trans','huo17',Reactionlist,'chexAri'); 
[Reactionlist]=add_reaction({'Arm3P0','Al'},{'Ar','Ali','e'},2,[2.95e-16],'pen','huo17',Reactionlist,'Pen'); %divided by 2 for 2 metastable levels
[Reactionlist]=add_reaction({'Arm3P2','Al'},{'Ar','Ali','e'},2,[2.95e-16],'pen','huo17',Reactionlist,'Pen'); %divided by 2 for 2 metastable levels
end
end

%% Zr

if ismember('Zr',Spe.PSpeciess)

% Ionisation
% single ionization
[Reactionlist]=add_reaction({'e','Zr'},{'Zri','e','e'},1,[1.69e-13 0.171 7.825],'ion','JTG',Reactionlist,'izcZr');
[Reactionlist]=add_reaction({'eh','Zr'},{'Zri','eh','e'},8,[3.04e-13 2.18e-16],'ion','JTG',Reactionlist,'izhZr');
% doubly ionization
[Reactionlist]=add_reaction({'e','Zri'},{'Zrii','e','e'},1,[3.06e-14 0.042 14.39],'ion','JTG',Reactionlist,'izcZri');
[Reactionlist]=add_reaction({'eh','Zri'},{'Zrii','eh','e'},8,[3.09e-14 2.21e-17],'ion','JTG',Reactionlist,'izhZri');

% > Excitation
% no excitation for zr
    % Ar interaction
    if ismember('Ar',Spe.PSpeciess)
        [Reactionlist]=add_reaction({'Ari','Zr'},{'Ar','Zri'},2,[2e-16],'ch_trans','Supposed',Reactionlist,'chexAri'); 
        [Reactionlist]=add_reaction({'Arm3P0','Zr'},{'Ar','Zri','e'},2,[5.3e-15],'pen','Supposed',Reactionlist,'Pen');
        [Reactionlist]=add_reaction({'Arm3P2','Zr'},{'Ar','Zri','e'},2,[5.3e-15],'pen','Supposed',Reactionlist,'Pen');
    end
end

%% N2

%% Converting of the icelandic RTs_N2 to compatible form of mine
if ismember('N2',Spe.PSpeciess)
    load('RTs_N2_icelandic.mat')
    lenN2=length(RTs_N2);
    % for each reaction do the following
    for k=1:lenN2
        % change the reaction type names to the ones I use
        if strcmp('Electron_reactions',RTs_N2(k).type) == 1
            nprod_e=sum(strcmp('e',RTs_N2(k).Prod))-sum(strcmp('e',RTs_N2(k).React));
            if nprod_e==0
                RTs_N2(k).type='exc';
            elseif nprod_e>0
                RTs_N2(k).type='ion';
            end
        elseif strcmp('Heavy_reactions',RTs_N2(k).type) == 1
            RTs_N2(k).type='Heavy';
        elseif strcmp('Photo_reactions',RTs_N2(k).type) == 1
            RTs_N2(k).type='Photo';        
        else
        end
        % add an extra field "tag" to it, give all of them some names
        RTs_N2(k).tag = sprintf('N2r%d',k); 
        RTs_N2(k).coef_type=4;
        N2v0_vec= strcmp('N2v0',RTs_N2(k).Prod);
        for i=1:length(N2v0_vec)
            if N2v0_vec(i)
                RTs_N2(k).Prod{i}='N2';
            end
        end
        N2v0_vec= strcmp('N2v0',RTs_N2(k).React);
        for i=1:length(N2v0_vec)
            if N2v0_vec(i)
                RTs_N2(k).React{i}='N2';
            end
        end
    end
    Reactionlist(end+1:end+lenN2)=RTs_N2;
end

%% Si Silicon

if ismember('Si',Spe.PSpeciess)

% Ionisation
% single ionization
[Reactionlist]=add_reaction({'e','Si'},{'Sii','e','e'},1,[5.14e-14 0.598 7.5716],'ion','Freund90',Reactionlist,'izcSi');
[Reactionlist]=add_reaction({'eh','Si'},{'Sii','eh','e'},8,[1.09e-13 1.06e-16],'ion','Freund90',Reactionlist,'izhSi');

% doubly ionization
[Reactionlist]=add_reaction({'e','Si'},{'Siii','e','e','e'},1,[9.79e-13 0.291 27.226],'ion','Freund90',Reactionlist,'izcGSSii');
[Reactionlist]=add_reaction({'eh','Si'},{'Siii','eh','e','e'},8,[5.44e-15 5.29e-18],'ion','Freund90',Reactionlist,'izhGSSii');

% doubly ionization #2  — from single 
[Reactionlist]=add_reaction({'e','Sii'},{'Siii','e','e'},1,[1.71e-17 0.736 25.884],'ion','Djuric93',Reactionlist,'izcSii');
[Reactionlist]=add_reaction({'eh','Sii'},{'Siii','eh','e'},8,[1.54e-14 9.50e-18],'ion','Djuric93',Reactionlist,'izhSii');

% Ar Interaction
if ismember("Ar",Spe.PSpeciess)
    [Reactionlist]=add_reaction({'Arm3P0','Si'},{'Ar','Sii','e'},2,[2.16e-16],'pen','Bogaerts07',Reactionlist,'Pen');
    [Reactionlist]=add_reaction({'Arm3P2','Si'},{'Ar','Sii','e'},2,[2.16e-16],'pen','Bogaerts07',Reactionlist,'Pen');
end

%% Creating Rea structure

Rea=create_Rea_new(Spe,Reactionlist);

if ismember('Ti',Spe.PSpeciess) && ismember('Ar',Spe.PSpeciess)
    save('Rea_ArTi','Rea');
elseif ismember('W',Spe.PSpeciess) && ismember('Ar',Spe.PSpeciess)
    save('Rea_ArW','Rea');
elseif ismember('C',Spe.PSpeciess) && ismember('Ar',Spe.PSpeciess) && ismember('Ne',Spe.PSpeciess)
    save('Rea_ArNeC','Rea');
elseif ismember('C',Spe.PSpeciess) && ismember('Ar',Spe.PSpeciess)
    save('Rea_ArC','Rea');
elseif ismember('Cu',Spe.PSpeciess) && ismember('Ar',Spe.PSpeciess)
    save('Rea_ArCu','Rea');
elseif ismember('Cr',Spe.PSpeciess) && ismember('Ar',Spe.PSpeciess)
    save('Rea_ArCr','Rea');
elseif ismember('Mo',Spe.PSpeciess) && ismember('Ar',Spe.PSpeciess)
    save('Rea_ArMo','Rea');
elseif ismember('Al',Spe.PSpeciess) && ismember('Ar',Spe.PSpeciess)
    save('Rea_ArAl','Rea');
elseif ismember('Zr',Spe.PSpeciess) && ismember('Ar',Spe.PSpeciess)
    save('Rea_ArZr','Rea');
elseif ismember('Mo',Spe.PSpeciess) && ismember('He',Spe.PSpeciess)
    save('Rea_HeMo','Rea');
elseif ismember('Si',Spe.PSpeciess) && ismember('Si',Spe.PSpeciess)
    save('Rea_ArSi','Rea');
end
end
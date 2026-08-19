function [dndt, out] = ODEfile(t, n, In)
% dndt(i): rate of each unknown n(i) at time t
% out: is the output sturcutrue. write "out.y=x" to save the value of
% quantity x at time t in the field named y.

util.ode.callCounter(2); % 2 -> update/increment call count

%% Preparation and importing data

% toggle output
additional_output = false;
if nargout > 1
    additional_output = true;
end

n = real(n); % FIXME !!!
if size(n,2) > 1 % FIXME !!!!
    n = n.';
end
% n(n<0) = 0;

% From the huge input structure, define:
Spe         = In.Spe;
Rea         = In.Rea;
Precal      = In.Precal;
disch       = In.disch;
Range       = In.Range;
Para        = In.Para;
reactive    = In.mode.reactive;



% Definition related to the solver and matrix formalism
s       = Spe.s;
ns      = length(Spe.Names); % nubmer of species (not including temperature)
s_Tec   = ns+1;
S       = zeros(ns,1); S(:) = n(1:ns); % S is species density vector, it is in m^-3
T_ec    = n(s_Tec);  % the cold electron is one of the variables in the dndt solver



% geometry
L       = Para.L;       % z-direction length of the ionization region
V_IR    = Para.V_IR ;% volumte of the ionization region
S_IR    = Para.S_IR ;% area of the ionization region
S_BP    = Para.S_BP ;% area of the ionization region facing the bulk plasma
S_RT    = Para.S_RT ;% area of the ionization region facing the race track

% fitting parameters:
f = Para.f; % fraction of potential in the ionization region
r = Para.r; % recapture probability
% MRu: beta is accounted for in panel_mode_single_run_... when Spe.B is
% overwritten (very complicated, but this is how it works) 

%MRu: add 2020-02-18 vor IRM v1.2
pulseLength = Para.pulseLength;
if isfield(disch,'t_pulse_end')
    % TODO : make this default and overwriteable by value in Para
    pulseLength = disch.t_pulse_end*1e-6;
end
pulse_on    = t <= pulseLength;
varf        = Para.varf;
% the following two variables always have a value, but the value is ignored if varf = 0
Bfield      = Para.Bfield;
hall        = Para.hall; % if varf = 1 -> hall replaces f as a fitting parameter!

% other parameters
F_Teh = Para.F_Teh;  % a parameter
U_htc = Para.U_htc;  % energy hot2cold

% constant
q = 1.602176634e-19; % elementary charge

% Defining simpler variables names
% for species
M = Spe.M.'; % mass of each species % TODO: this should be a column vector
T = Spe.T.'; % temperature of each species % TODO: this should be a column vector
Q = Spe.Q.'; % element charge of each species % TODO: this should be a column vector
% TODO : rename Q -> Z
B = Spe.B.'; % back attraction probability for each species % TODO: this should be a column vector
% MRu: B is overwritten in panel_mode_single_run with the beta value to 
% be used for this particular run 

% for reactions
Reactype = Rea.Reactype; % matrix Rea_ArTi is found in species_reactions
R = Rea.R;          % reactants: x times 10 matrix for x reactions and 10 species  : TODO : remove
                    % indicates which products take part in reaction 
P = Rea.P;          % products: x times 10 matrix % TODO : remove
                    % indicates (with 0, 1 or 2) which and how many species are produced in the reaction  
rn = Rea.rn;        % number of reaction together with name of reaction 
n_Rea = length(R);  % number of reactions 

%% Discharge current and voltage
if ~isfield(disch, 'U')
    disch.U = disch.V; % FIXME : this should be handled further up
end

% compute the current index in the T, U, I inputs
% FIXME : time scale should be handled in a better way (currently simulation uses seconds, and input uses microseconds)
vn = min(max(round((t*1e6-disch.T(1))/disch.dt) + 1, 1), length(disch.U));
Ud = max(abs(disch.U(vn)), 0.1); % NOTE : doesn't seem to like Ud = 0
% NOTE : would min(disch.U(vn), 0) be a better option?
Id = max(abs(disch.I(vn)), 0.1); % NOTE : maybe we should think about what negative voltage/current mean

Uir = f * Ud;
Ush = Ud - Uir;

%% Yields at the moment
Udn     = min(max(round(Ud)+1, 1), size(Precal.Y_eff, 3));

Y       = Precal.Y_eff(:,:,Udn);    % sput.-yield : Y(s.ion,s.sputtered)
gamma   = Precal.gamma_eff(:,Udn);  % 2ndary e-yield

%% Electron temperatures
T_ec = min(100, max(0.3, T_ec, 'omitnan')); % cold electron temperature
T_eh = max(2/3*F_Teh*Ud, 1); % hot electron temperature
Teff = Reactype.eH*T_eh+(Reactype.eH==0)*T_ec; % effective temperature

%% Effective costs of ionization
Tnc = min(max(round((T_ec-Precal.Ec.Tec_min)/Precal.Ec.dTec+1), 1), 9501);
Tnh = min(max(round((T_eh-Precal.Ec.Teh_min)/Precal.Ec.dTeh+1), 1), 9501);

Ecc = Precal.Ec.c(:,Tnc);
Ech = Precal.Ec.h(:,Tnh);

%% Volume reactions (usasge of matrix formalism)
% Rate = prod((S.').^Rea.R,2);
Rate = prod(S.^Rea.Rt,1).';

%ks = rate_coeffs(Teff, Rea.cfs); % TODO: replace with function call to rate_coeff
ks = max(...                        % What is this?
    (Rea.cfs(:,1)+Rea.cfs(:,2).*Teff.'+Rea.cfs(:,3).*(Teff.').^Rea.cfs(:,4)).*...
    exp(-Rea.cfs(:,5)./Teff.'), 0);
Rate = ks.*Rate;
dndt = Rea.deltaR*Rate;

%% Flux and Diffusion
h_ran = 1/2; % see Huo 2017, Eq. 7
% according to Huo 2017, this comes into play because we only consider
% species moving towards the boundary
% i.e. : the thermal (random) flux of particles through a boundary is not
% given by v*n, but 0.5*v*n, because half of the particles are moving
% in one direction and the other half in the opposite direction
% NOTE: the label is in reference to account for the difference in density
% at the sheath and centre in earlier global models for high-density
% discharges

if ~pulse_on %|| (t>t_cut)
    B = zeros(ns,1);  % B = beta !
end

if isfield(In.IP, 'ion_velocity') && strcmpi(In.IP.ion_velocity, 'Bohm')
    v_ion = bohm_velocity(T_ec, M, q);
else
    v_ion = ion_velocity(M, Q, Uir, q);
end
v_ran = random_velocity(T, M, q);


GAMMA_ion_RT = zeros(ns,1);
GAMMA_ion_BP = zeros(ns,1);

% FIXME : sigma_mAr should be in input structure and gas neutrals should be
% a range (e.g. parent is in refill and is neutral)
% FIXME N2 : need to think about how to handle this -> wait for new ideas
% by MRu and ignore for the time being
if ismember('Ar', In.Spe.Refill_gases)
    sigma_ArAr=1.4e-19;
    sigma_mAr = 2e-19;  % MRu: this should go into some input structure % FIXME
    % Source: Phelps, Greene, Burke, JPB: atomic, molecular and optical physics 33, 2965, 2000

    if ismember ('Cu',Spe.Names)
        sigma_mAr=0.3430e-18;
        n_CuAll=n(s.Cu)+n(s.Cui)+n(s.Cuii);
        s_metal=s.Cu;
    
    elseif ismember ('Al',Spe.Names)
        sigma_mAr=0.2644e-18;
        n_AlAll=n(s.Al)+n(s.Ali)+n(s.Alii);
        s_metal=s.Al;
    
    elseif ismember ('Ti',Spe.Names)
        sigma_mAr=0.4141e-18;
        n_TiAll=n(s.Ti)+n(s.Tii)+n(s.Tiii);
        s_metal=s.Ti;
    
    elseif ismember ('C', Spe.Names)
        sigma_mAr=0.1159e-18;
        n_CAll=n(s.C)+n(s.Ci)+n(s.Cii)+n(s.Cm1)++n(s.Cm2)++n(s.Cm3);
        s_metal=s.C;
        if ismember ('Ne', In.Spe.Refill_gases) % Source: Phelps, Greene, Burke, JPB: atomic, molecular and optical physics 33, 2965, 2000
            sigma_NeNe = 0.1045e-18; 
            sigma_ArNe = 0.2965e-18; 
            sigma_mNe=0.1159e-18; % ???
        end

    elseif ismember ('Cr',Spe.Names)
        sigma_mAr=0.3974e-18;
        n_CrAll=n(s.Cr)+n(s.Cri)+n(s.Crii);
        s_metal=s.Cr;    
        
    elseif ismember('W', Spe.Names)
        sigma_mAr=0.4023e-18;
        n_CAll=n(s.W)+n(s.Wi);
        s_metal=s.W;
        
    elseif ismember ('Zr',Spe.Names)
        sigma_mAr=0.4879e-18;
        n_ZrAll=n(s.Zr)+n(s.Zri)+n(s.Zrii);
        s_metal=s.Zr;

    elseif ismember ('Mo',Spe.Names)
        sigma_mAr=0.4232e-18;
        n_MoAll=n(s.Mo)+n(s.Moi)+n(s.Moii);
        s_metal=s.Mo;

    elseif ismember ('Si',Spe.Names)
        sigma_mAr=2.275e-19;
        n_SiAll=n(s.Si)+n(s.Sii)+n(s.Siii);
        s_metal=s.Si;
    end
    
    n_ArNeu = n(s.Ar)+n(s.Arm3P0)+n(s.Arm3P2)+n(s.ArH)+n(s.ArW);
    if ismember ('Ne', In.Spe.Refill_gases)
    n_NeNeu = n(s.Ne)+n(s.Nem2P0)+n(s.Nem2P2)+n(s.NeH)+n(s.NeW);
    end
  %  n_target = sum(n(Range.sput_metal));

    % the probability of a collisions inside the ionization region between metal and working gas
    F_coll_Ar = 1 - exp(- n_ArNeu * sigma_mAr * L); % NOTE : Is this even correct?
    F_coll =  F_coll_Ar;
    if ismember ('Ne', Spe.Names)
    F_coll_Ne = 1 - exp(- (n_NeNeu) * sigma_mNe * L);
    F_coll = 2 - exp(- (n_NeNeu) * sigma_mNe * L) - exp(- (n_ArNeu) * sigma_mAr * L);
    end

    F_coll_ArH=zeros(ns,1);
    F_coll_NeH=zeros(ns,1);
    F_coll_Me=zeros(ns,1);

elseif ismember('N2', In.Spe.Refill_gases)
    % Note : this is just temporary non-sense -> NEEDS FIXING
    sigma_mN2 = 2e-19;  % taken to be same as Ar % MRu: this should go into some input structure % FIXME
    n_N2Neu = sum(n(strcmp(In.Spe.PSpecies, 'N2') & In.Spe.Q == 0 & In.Spe.M > 4e-26 ));
    % the probability of a collisions inside the ionization region between metal and argon gas
    F_coll_N2 = 1 - exp(- n_N2Neu * sigma_mN2 * L); % NOTE : Is this even correct?
    F_coll =  F_coll_N2;
elseif ismember('He', In.Spe.Refill_gases)
    sigma_mHe = 4e-20;  % MRu: this should go into some input structure % FIXME
    n_HeNeu = n(s.He)+n(s.Hem2S0)+n(s.Hem2S1)+n(s.He2P012)+n(s.He2P1)+n(s.HeH)+n(s.HeW);
    % the probability of a collisions inside the ionization region between metal and He gas
    F_coll_He = 1 - exp(- n_HeNeu * sigma_mHe * L); % NOTE : Is this even correct?
    F_coll =  F_coll_He;
end

for i=Range.kickout % (from input file, typicaly = [3,4,5]=[ArC, Arm1, Arm2]) 
    F_coll_ArH(i) = 1 - exp(- (n(i)) * sigma_ArAr * L); %only works if sigma_ArAr=sigma_ArNe %the probability of a collisions inside the ionization region between ArH and kicked-out species
    F_coll_Me(i) = 1 - exp(- (n(i)) * sigma_mAr * L); %only works if sigma_ArAr=sigma_ArNe %the probability of a collisions inside the ionization region between metal and kicked-out species    
    if ismember ('Ne', Spe.Names)
    F_coll_NeH(i) = 1 - exp(- (n(i)) * sigma_NeNe * L); %only works if sigma_ArAr=sigma_ArNe
    %F_coll_MeAr(i) = 1 - exp(- (n(i)) * sigma_mAr * L); 
    %F_coll_MeNe(i) = 1 - exp(- (n(i)) * sigma_mNe * L);
    %F_coll_Me(i) = F_coll_MeAr(i) + F_coll_MeNe(i);
    end
end

n_target = sum(n(Range.sput_metal));

% NOTE: flux is scaled such that all ions either are back attracted or
% leave into the bulk plasma
if pulse_on
    GAMMA_ion_RT(Range.ion) = v_ion(Range.ion).*n(Range.ion);
    GAMMA_ion_BP(Range.ion) = (1 - B(Range.ion)).*GAMMA_ion_RT(Range.ion).*(S_RT/S_BP);
    GAMMA_ion_RT(Range.ion) =      B(Range.ion) .*GAMMA_ion_RT(Range.ion);
else
    GAMMA_ion_RT(Range.ion) = v_ran(Range.ion).*n(Range.ion);
    GAMMA_ion_BP(Range.ion) = (1 - B(Range.ion)).*GAMMA_ion_RT(Range.ion)*(S_RT/S_BP)*(1-F_coll); % NOTE : F_coll can be higher than beta, which means that the flux after the pulse end will be small than during the pulse!
    GAMMA_ion_RT(Range.ion) =      B(Range.ion) .*GAMMA_ion_RT(Range.ion);
end

diffrate = zeros(ns,1);

% neutral ground state process gas
diffrate(Range.refill) = (S_BP/V_IR)*h_ran*v_ran(Range.refill).*(n(Range.refill)-Spe.ID(Range.refill));
% sputtered metal neutral
diffrate(Range.sput_metal)= (1/L)*(1-F_coll_Ar)*v_ran(Range.sput_metal).*n(Range.sput_metal);
% sputtering gas neutrals
diffrate(Range.sput_gas) = (1/L)*v_ran(Range.sput_gas).*n(Range.sput_gas);
% metastables
diffrate(Range.meta) = h_ran*(S_IR/V_IR)*v_ran(Range.meta).*n(Range.meta); % NOTE ???: should this be taken into account for neutral ground state process gas
% ions
diffrate(Range.ion) = (GAMMA_ion_RT(Range.ion)*S_RT + GAMMA_ion_BP(Range.ion)*S_BP)/V_IR;

dndt = dndt - diffrate;

% %% Kick-outs
% kickout_freq = h_ran*v_ran(s.(Spe.Target{1}))/L*F_coll*...
%     n_target/sum(n(Range.kickout))*M(s.(Spe.Target{1}))/M(s.(Spe.Refill_gases{1}));
% % NOTE : should denominator be n_gas_neutral ??? % FIXME
% 
% kickout = zeros(ns,1);
% kickout(Range.kickout) = kickout_freq*n(Range.kickout);
% 
% % % in a reactive case, more kickout terms are considered
% % if reactive == 1
% %     n_N2Neu=sum(n(Range.kickout_r));
% %     sigma_mN = 2e-18;
% %     F_coll_N2 = 1 - exp(- n_N2Neu * sigma_mN * L);
% %     kickout_freq_N =  h_ran*v_ran(s.(Spe.Target{1}))/L*F_coll_N2*n_TiAll/n_N2Neu;
% %     for i=Range.kickout_r
% %         kickout(i) = kickout_freq_N*n(i);
% %     end
% % end
% 
% dndt = dndt - kickout;
% 
% %% Sputtering
% sputrate = (Y.')*GAMMA_ion_RT/L; % TODO : transpose Y in input % FIXME !!!
% 
% dndt = dndt + sputrate;

%% Sputtering
% consideration of degree of poisoned is in 
sputrate=zeros(ns,ns);
for j=1:ns
    if (t>pulseLength)
        sputrate(:,j)= 0;
    else
        sputrate(:,j)= (1/L) * GAMMA_ion_RT(:,1) .* Y(:,j);
    end

    %sputrate(:,j)= (1/L) * GAMMA_ion_RT(:,1) .* Y(:,j);
    % MR: L = V_IR/S_RT, see create_Para for definitions 
    %     then GAMMA_ion_RT * S_RT = number of ions incident on the
    %     racetrack per second; division by V_IR to obtain sputtered 
    %     atoms density; sputrate is in therefore in 1*s^-1*m^-3
    %     see also Huo et al. 2017
end

dndt = dndt + sum(sputrate)';
%out.sputrate = sputrate; %!!!!

%% Kick-outs
kickout=zeros(ns,1); 
kickoutAr=zeros(ns,1); 
kickoutM=zeros(ns,1);
%[ArH,M]->[ArC, Arm1, Arm2] kick-out scheme
for i=Range.kickout % (from input file, typicaly = [3,4,5]=[ArC, Arm1, Arm2]) 
    kickout_rate = (F_coll_Me(i)*sum(sputrate(:,s_metal))+F_coll_ArH(i)*sum(sputrate(:,s.ArH)));
    if ismember ('Ne', Spe.Names)
        kickout_rate = (F_coll_Me(i)*sum(sputrate(:,s_metal))+F_coll_ArH(i)*sum(sputrate(:,s.ArH))+F_coll_NeH(i)*sum(sputrate(:,s.NeH))); 
        kickout_rateNe = F_coll_NeH(i)*sum(sputrate(:,s.NeH)); 
        kickoutNe(i) = kickout_rateNe;
    end
    kickout_rateAr = F_coll_ArH(i)*sum(sputrate(:,s.ArH)); 
    kickout_rateM = F_coll_Me(i)*sum(sputrate(:,s_metal));
    kickout(i) = kickout_rate;
    kickoutAr(i) = kickout_rateAr;
    kickoutM(i) = kickout_rateM;
    
end

%% Kick-outs

out.kickoutAr = kickoutAr;
out.kickoutM = kickoutM; 
if ismember ('Ne', Spe.Names)
    out.kickoutNe = kickoutNe;
end
dndt = dndt - kickout;

%% Currents
I = zeros(ns,1);
I_se = zeros(ns,1);

I(Range.ion) = q*S_RT*Q(Range.ion).*GAMMA_ion_RT(Range.ion);
I_se(Range.ion) = (1-r)*gamma(Range.ion).*I(Range.ion)./Q(Range.ion);


%% Power equation

Id_p = Id;
if isfield(In.IP, 'consistent_current') && In.IP.consistent_current
    % NOTE: this is a bit of an experiment to make the model a bit more
    % believeable -- remove the discharge current from the input and use
    % the IRM current for the power equation instead
    Id_p = In.IP.consistent_current*sum(I(Range.ion)+I_se(Range.ion)) ...
        + (1-In.IP.consistent_current)*Id;
end

K1 = 1/2;
if isfield(In.IP, 'K1')
    K1 = In.IP.K1;
end
applied = K1*Uir*Id_p/q/V_IR; % eV/s/m3
Ohm_heat = sum(I_se(Range.ion).*Ush/q/V_IR); % eV/s/m3

Rtmp = Rea.R;
Rtmp(:,1:2) = false;
% reactant holds the index of the first massive (i.e. non-electron) reactant
% this is only used for electron impact reactions, so where this also
% corresponds to the only massive reactant
reactant = zeros([size(R, 1),1]); % TODO : precompute
for i = 1:size(R, 1)
    reactant(i) = find(Rtmp(i,:), 1, "first");
end

if ismember('Ar', Spe.Refill_gases)
    % FIXME / compatibility Ar
    Spe.Energy(Spe.s.Arm3P0) = 11.56;
    Spe.Energy(Spe.s.Arm3P2) = 11.56;
end

if ismember('He', Spe.Refill_gases)
    % FIXME / compatibility HeMo
    Spe.Energy(Spe.s.He2P012) = 20.69;
    Spe.Energy(Spe.s.He2P1) = 21.218;
end

n_prod_e = Rea.nprod_e.'; % FIXME : change orientation of nprod_e

msk = Rea.Range.ionC;
coll_loss = dot(Rate(msk), Ecc(reactant(msk)) + 3/2*n_prod_e(msk)*T_ec);

msk         = Rea.Range.ionH;
hot2cold    = sum(Rate(msk))*U_htc;

msk         = Rea.Range.ionH;
izh_cost    = dot(Rate(msk), Ech(reactant(msk)) + U_htc);

msk         = contains(Rea.tags, 'dexc'); % TODO : precompute
if strcmp('C', Spe.Target{1}) % FIXME
    % In carbon version, excitations are also included
    msk = Rea.Range.excC;
end
deex_c      = dot(Rate(msk), Spe.Energy(reactant(msk)));
% deex_c      = dot(Rate(msk), Rea.Vif(msk));

msk         = contains(Rea.tags, 'dexh'); % TODO : precompute
if strcmp('C', Spe.Target{1}) % FIXME
    % In carbon version, excitations are also included
    msk = Rea.Range.excH;
end
deex_h      = dot(Rate(msk), Spe.Energy(reactant(msk)));
% deex_h      = dot(Rate(msk), Rea.Vif(msk));

msk         = Rea.Range.penning;
% deex_P      = dot(Rate(msk), sum(Spe.Energy(Rtmp(msk,:)),2) - sum(Spe.Energy(Ptmp(msk,:)),2) - 3/2*T_ec);
deex_P      = dot(Rate(msk), -Rea.Vif(msk).' - 3/2*n_prod_e(msk)*T_ec); % FIXME : change orientation of Vif

if strcmp('Mo', Spe.Target{1}) % FIXME
    % FIXME / compatibility HeMo
    deex_P = 0;
    coll_loss = 40*coll_loss;
end

P_ec = applied + deex_c + deex_P + hot2cold - coll_loss;

dndt(s_Tec) = P_ec/(3/2*n(s.e));

P_eh = Ohm_heat + deex_h - izh_cost;

dndt(s.eh) = P_eh/(F_Teh*Ud);

%% Forcefully input quasi-neutrality for electrons
dndt(s.e) = dot(Q(Range.ion),dndt(Range.ion)) - dndt(s.eh); % conserves possible charge imbalance
% dndt(s.e) = dot(Q(Q~=0),n(Q~=0)) + dot(Q(Range.ion),dndt(Range.ion)) - dndt(s.eh); % forces quasi-neutrality

%% Additional output
    
if additional_output
    % Yields at the moment
    out.dis_Ud = Ud;
    out.dis_Id = Id;
    out.dis_Uir = Uir;
    out.dis_Ush = Ush;

    % Electron temperatures
    out.T_eh = T_eh;
    out.T_ec = T_ec;

    % Effective costs of ionization
    out.Ecc = Ecc;
    out.Ech = Ech;

    % Volume reactions
    out.Rate = Rate;
    out.Prod = Rea.Pt*Rate;
    out.React = Rea.Rt*Rate;
    out.Net = Rea.deltaR*Rate;

    % Fluxes and diffusion
    if exist('F_coll_Ar', 'var') % FIXME
        out.F_coll_Ar = F_coll_Ar;
    end
    if exist('F_coll_N2', 'var') % FIXME
        out.F_coll_N2 = F_coll_N2;
    end
    if exist('F_coll_He', 'var') % FIXME
        out.F_coll_He = F_coll_He;
    end
    out.GAMMA_ion_RT = GAMMA_ion_RT;
    out.GAMMA_ion_BP = GAMMA_ion_BP;
    out.Diffrate = diffrate;

    % Kick-out
    out.kickout = kickout;

    % Sputtering
    out.sputrate = sputrate;

    % Currents
    out.I = I;
    out.I_se = I_se;

    % Cold electron power balance
    out.P_ec = P_ec;
    out.P_ec_applied = applied;
    out.P_ec_deex_c = deex_c;
    out.P_ec_deex_P = deex_P;
    out.P_ec_hot2cold = hot2cold;
    out.P_ec_coll_loss = - coll_loss;

    % Hot electron power balance
    out.P_eh = P_eh;
    out.P_eh_ohm_heat = Ohm_heat;
    out.P_eh_deex_h   = deex_h;
    out.P_eh_izh_cost = - izh_cost;
end

end


function v = random_velocity(T,m,q) % FIXME: this is the thermal velocity in one direction -> name is misleading
    v = sqrt((2/pi)*(q*T./m));
end

function v = bohm_velocity(Te,m,q)
    v = sqrt(q*Te./m);
end

function v = ion_velocity(m,Z,Uir,q)
    v = sqrt(abs(Z).*q.*Uir./m);
    % NOTE : further consideration required when introducing negative ions
end
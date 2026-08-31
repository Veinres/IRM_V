function [filename, Yield] = create_Yield(Spe, name, generate_plots)
%CREATE_YIELD generate sputter yield tables
%==========================================================================
% Precomputes the energy dependent sputter yields (or rather sputter
% probabilities) and saves them to a matlab structure
% -------------------------------------------------------------------------
% PARAMETERS:
% - Spe            : structure containing species information
% - name           : name of .mat file to which structure will be saved
% - generate_plots : whether to generate plots (default=False)
% -------------------------------------------------------------------------
% USAGE EXAMPLE:
% create_Yield(Spe, 'Yield_ArTi')
%==========================================================================

%% NOTES ------------------------------------------------------------------
% TODO: fix PSpeciess stuff (kinda bothers me tbh, c.f. create_Ec)
% TODO: get better description of expected Spe parameter
% TODO: figure out if use of column or row matrices would be more
% appropriate
% TODO: add voltage range/resolution to function parameters in case there
% are cases where different values would be used (parameters shouldn't be
% changed in the source code of a function)
% TODO: clean up source code
% TODO: separate self-sputtering yields from Ar sputtering yields

% QUESTION: is there a reason not to include Arii in each case?

%% Read out parameters ----------------------------------------------------

% check for optional arguments
if nargin < 3
    generate_plots = false;
end

% defining some quantities
Names = Spe.Names; % names of the species
s = Spe.s; % indecies of the species

% MRu, PSpeciess is essentially the same es Names, I think. To avoid having
% to redefine the Spe matrix, I changed the following code line: 
% PSpeciess=Spe.PSpeciess;
% NOTE: PSpeciess is parent species
PSpeciess = Spe.Names;

nS = length(Names); % the number of species

%% Define voltage range and resolution ------------------------------------
% Define the matrix size and its resolution
% Valid range for the given sputter yield functions
Umin = 0;    % voltage max in volts
Umax = 1500; % voltage min in volts 
dU   = 1;    % voltage resolution between Umin to Umax

U = Umin:dU:Umax;  % the voltage vector 
nU = length(U); % length the of the voltage vector

%% Include hot/warm nitrogen?
include_HWN = false; % FIXME : include NW and NH?

%% Preallocation of yield data matrices and function cell arrays ----------

% create yield matrix
% (sputtering species, sputtered species, energy)
YieldC = zeros(nS,nS,nU); % clean
YieldD = zeros(nS,nS,nU); % dirty

% create the cell array for yield functions
% (sputtering species, sputtered species)
fYieldC = cell(nS,nS); % clean
fYieldD = cell(nS,nS); % dirty

%% Some preparation

% Produce plots of the sputtered rates and save them as well
% sputtering=[s.Ari, s.Tii, s.Tiii]; % supposed to be ions
% sputtered =[s.Ti, s.ArW, s.ArH]; % supposed to be metal
sputtering=[];
for ns=1:nS
    if Spe.Q(ns)>0
        sputtering(end+1)=ns; %supposed to positive ion indexes
    end
end

%sputteredmaterials contains a list of all materials that could be
%sputtered, but then it is checked if they are included as well.
sputteredmaterials ={'Ti', 'ArW', 'ArH','Cr', 'C', 'W', 'Cu', 'Mo','Al','Zr', 'HeW' , 'HeH','NeW','NeH', 'Si'};
if isfield(s,'NW') && isfield(s,'NH') && include_HWN
    sputteredmaterials{end+1} = 'NW';
    sputteredmaterials{end+1} = 'NH';
else
    sputteredmaterials{end+1} = 'NS';
end

sputtered=[];
sputterednames={};
for i=1:length(sputteredmaterials)
    if ismember(sputteredmaterials{i},Names)        
        sputtered(end+1)=s.(sputteredmaterials{i});
        sputterednames{end+1}=sputteredmaterials{i};
    end
end

%% Yield functions on CLEAN surface ---------------------------------------
% Define yield functions FROM sputtering species TO sputtered species:

if ismember('Ar', PSpeciess)
    % To sputter ArH, ArW (general case, could be adjusted by target material)
    xi_pulse = 1; xi = 1/2;
    fYieldC{s.Ari,s.ArH} = @(Ud) xi_pulse*xi;
    fYieldC{s.Ari,s.ArW} = @(Ud) xi_pulse*(1-xi);
    if ismember('Arii', Names)
        fYieldC{s.Arii,s.ArH} = @(Ud) xi_pulse*xi ;
        fYieldC{s.Arii,s.ArW} = @(Ud) xi_pulse*(1-xi);
    end
end

if ismember('Ne', PSpeciess)
    % To sputter NeH, NeW 
    xi_pulse = 1; xi = 1/2;
    fYieldC{s.Nei,s.NeH} = @(Ud) xi_pulse*xi;
    fYieldC{s.Nei,s.NeW} = @(Ud) xi_pulse*(1-xi);
    if ismember('Neii', Names)
        fYieldC{s.Neii,s.NeH} = @(Ud) xi_pulse*xi ;
        fYieldC{s.Neii,s.NeW} = @(Ud) xi_pulse*(1-xi);
    end
end

if ismember('N2', PSpeciess)
    % NOTE : should we introduce hot N/N2 for backscattered ions
    xi_pulse = 1; xi = 1/2;
    if isfield(s,'NW') && isfield(s,'NH') && include_HWN
        fYieldC{s.Ni,s.NH} = @(Ud) xi_pulse*xi; % ??? : does this make sense?
        fYieldC{s.N2i,s.NH} = @(Ud) 2*fYieldC{s.Ni,s.NH}(Ud/2);
        fYieldC{s.Ni,s.NW} = @(Ud) xi_pulse*(1-xi); % ??? : does this make sense?
        fYieldC{s.N2i,s.NW} = @(Ud) 2*fYieldC{s.Ni,s.NH}(Ud/2);
    else
        fYieldC{s.Ni,s.NS} = @(Ud) xi_pulse; % ??? : does this make sense?
        fYieldC{s.N2i,s.NS} = @(Ud) 2*fYieldC{s.Ni,s.NS}(Ud/2);
    end
    fYieldC{s.N2i,s.N2} = @(Ud) 0; % ??? : does this make sense?
    % NOTE : the idea here is, that in the clean part no nitrogen remains
    % part of the target -> everything must come back
    % SO : in this case returning N and N2 1:1 to the IRM should be fine
end

if ismember('He', PSpeciess)
    xi_pulse = 1; xi = 1/2;
    fYieldC{s.Hei,s.HeH} = @(Ud) xi_pulse*xi;
    fYieldC{s.Hei,s.HeW} = @(Ud) xi_pulse*(1-xi);
end

if ismember('N2',PSpeciess) && ...
   ismember('Ti',sputterednames)
    fYieldC{s.Ni,s.Ti} = @(Ud) max(0, 3.231*(1e-3*Ud).^0.0788 - 2.489); % from TRIM
    fYieldC{s.N2i,s.Ti} = @(Ud) 2*fYieldC{s.Ni,s.Ti}(Ud/2); % ~ energy equally split on two N atoms
end

if ismember('Ti', sputterednames)
    fYieldC{s.Tii,s.Ti} = @(Ud) (-1.402e-14*Ud.^4 + 1.461e-10*Ud.^3 -5.865e-07*Ud.^2 + 0.00129*Ud + 0.02205)*1; % original yields from IRM, not TRIM
    % fYieldC{s.Tii,s.Ti} = @(Ud) max(1.105*(1e-3*Ud).^0.4675 - 0.2729, 0); % from TRIM
    fYieldC{s.Tiii,s.Ti}= @(Ud) fYieldC{s.Tii,s.Ti}(2*Ud);
    if ismember('Ar', PSpeciess) 
        fYieldC{s.Ari,s.Ti} = @(Ud) (Ud > 30).*(-5e-07*Ud.^2 + 0.0013*Ud - 0.0384); % original yields from IRM, not TRIM   % may be incorect plot against anders10_783
    % fYieldC{s.Ari,s.Ti} = @(Ud) max(1.257*(1e-3*Ud).^0.4232 - 0.3009, 0); % from TRIM
    %    fYieldC{s.Arii,s.Ti} = @(Ud) (Ud > 30).*2*(-5e-07*Ud.^2 + 0.0013*Ud - 0.0384); % may be incorect plot against anders10_783
        fYieldC{s.Arii,s.Ti} = @(Ud) (Ud > 30).*(-5e-07*(Ud*2).^2 + 0.0013*Ud - 0.0384); %fixed from 2*fYieldC{Ud} to fYieldC{2*Ud}
    end
end

if ismember('W',sputterednames) 
    fYieldC{s.Wi,s.W} = @(Ud) 0.0066.*(Ud).^0.770;
    fYieldC{s.Wii,s.W}= @(Ud) fYieldC{s.Wi,s.W}(2*Ud);
    if ismember('Ar', PSpeciess)
        fYieldC{s.Ari,s.W} = @(Ud) 0.0429.*(Ud).^0.521;
    %    fYieldC{s.Arii,s.W} = @(Ud) 2*(0.0429.*(Ud).^0.521);
        fYieldC{s.Arii,s.W} = @(Ud) (0.0429.*(2*Ud).^0.521);  %fixed from 2*fYieldC{Ud} to fYieldC{2*Ud}
    end
end

if  ismember('Cu',sputterednames)
    fYieldC{s.Cui,s.Cu} = @(Ud) 0.0691.*Ud.^(0.556);
    fYieldC{s.Cuii,s.Cu} = @(Ud) 0.0691.*(2*Ud).^(0.556);
    if ismember('Ar',PSpeciess) 
        fYieldC{s.Ari,s.Cu} = @(Ud) 0.1421.*Ud.^(0.468);
        fYieldC{s.Arii,s.Cu} = @(Ud) 0.1421.*(2*Ud).^(0.468); %correct
    end
end

  

if  ismember('Cr',sputterednames) % using TU Wien for singly ions, anders for doubly ions
    fileCrCr=load("Cr_Cr_23.92eV.m");
    CrCr_wi=fileCrCr(:,2).';
    fYieldC{s.Cri,s.Cr} = @(Ud) fileCrCr(round(Ud+1),2).';
    fYieldC{s.Crii,s.Cr} = @(Ud) 0.0458.*(2*Ud).^(0.531);
    if ismember('Ar',PSpeciess) 
        fileCrAr=load("Cr_Ar_20.52eV.m");
        CrAr_wi=fileCrAr(:,2).';
        fYieldC{s.Ari,s.Cr} = @(Ud) fileCrCr(round(Ud+1),2).';
        fYieldC{s.Arii,s.Cr} = @(Ud) 0.0861.*(2*Ud).^(0.457); 
    end
end

%if  ismember('Cr',sputterednames) % using Anders10_783 fit
%    fYieldC{s.Cri,s.Cr} = @(Ud) 0.0458.*Ud.^(0.531);
%    fYieldC{s.Crii,s.Cr} = @(Ud) 0.0458.*(2*Ud).^(0.531);
%    if ismember('Ar',PSpeciess) 
%        fYieldC{s.Ari,s.Cr} = @(Ud) 0.0861.*Ud.^(0.457);
%        fYieldC{s.Arii,s.Cr} = @(Ud) 0.0861.*(2*Ud).^(0.457); 
%    end
%end

if ismember('Mo',sputterednames)
    fYieldC{s.Moi,s.Mo} = @(Ud) 0.0097.*Ud.^(0.628);
    fYieldC{s.Moii,s.Mo} = @(Ud) 2*(0.0097.*Ud.^(0.628));
    if ismember('Ar',PSpeciess)
        fYieldC{s.Ari,s.Mo} = @(Ud) 0.137.*Ud.^(0.628);
        %fYieldC{s.Arii,s.Mo} = @(Ud) 2*(0.137.*Ud.^(0.628));
        fYieldC{s.Arii,s.Mo} = @(Ud) (0.137.*(2*Ud).^(0.628)); %fixed from 2*fYieldC{Ud} to fYieldC{2*Ud}
    end
end

if ismember('Zr',sputterednames)
    fYieldC{s.Zri,s.Zr} = @(Ud) 0.001896.*Ud.^(0.9316);
    fYieldC{s.Zrii,s.Zr} = @(Ud) 2*(0.001896.*Ud.^(0.9316));
    if ismember('Ar',PSpeciess) 
        fYieldC{s.Ari,s.Zr} = @(Ud) 0.003538.*Ud.^(0.7936);
        % fYieldC{s.Arii,s.Zr} = @(Ud) 2*(0.003538.*Ud.^(0.7936));
        fYieldC{s.Arii,s.Zr} = @(Ud) (0.003538.*(2*Ud).^(0.7936)); %fixed from 2*fYieldC{Ud} to fYieldC{2*Ud}
    end
end

if ismember('Al', sputterednames)
    fYieldC{s.Ali,s.Al} = @(Ud) 0.1042.*(Ud).^0.370;
    fYieldC{s.Alii,s.Al}= @(Ud) fYieldC{s.Ali,s.Al}(2*Ud);
    if ismember('Ar', PSpeciess) 
        fYieldC{s.Ari,s.Al} = @(Ud) 0.0296.*(Ud).^0.521;  %table 1 anders10 783 correct
        %fYieldC{s.Ari,s.Al} = @(Ud) 2*(0.0296.*(Ud).^0.521);
        fYieldC{s.Ari,s.Al} = @(Ud) (0.0296.*(2*Ud).^0.521); %fixed from 2*fYieldC{Ud} to fYieldC{2*Ud}
    end
%     fYieldC{s.Ari,s.Al} = @(Ud) 0.0104.*(Ud).^0.699;  %mahne22
%     fYieldC{s.Ali,s.Al} = @(Ud) 0.0042.*(Ud).^0.699;
%     fYieldC{s.Alii,s.Al}= @(Ud) fYieldC{s.Ali,s.Al}(2*Ud);
end

% if ismember('Ar',PSpeciess) && ...
%    ismember('C',sputterednames)
%     fYieldC{s.Ari,s.C} = @(Ud) 0.0021.*Ud.^(0.687);
%     if ismember('Arii', Names)
%         fYieldC{s.Arii,s.C} = @(Ud) 0.0021.*(2*Ud).^(0.687);
%     end
% end

% Note : separate all target materials into separate blocks like this?
%if ismember('C',sputterednames)
%    fYieldC{s.Ci,s.C} = @(Ud) 0.0562.*Ud.^(0.224)*1; % QUESTION Is it supposed be this low?
%    fYieldC{s.Cii,s.C} = @(Ud) 0.0562.*(2*Ud).^(0.224)*1; %
%    if ismember('Ar', PSpeciess)
%        fYieldC{s.Ari,s.C} = @(Ud) 0.0021.*Ud.^(0.687);   %change to the onec in Ne paper
%        fYieldC{s.Arii,s.C} = @(Ud) 0.0021.*(2*Ud).^(0.687);
%    end
%end

if ismember('C',sputterednames)                    % new the data measured by Hechtl et al. gives a = 0.03761 and b = 0.294
    fYieldC{s.Ci,s.C} = @(Ud)0.03761.*Ud.^(0.294)*1;
    fYieldD{s.Cii,s.C} = @(Ud)0.03761.*(2*Ud).^(0.294)*1;
    if ismember('Ar',PSpeciess)
        fYieldC{s.Ari,s.C} = @(Ud) 0.01424.*Ud.^(0.4799); 
        fYieldC{s.Arii,s.C} = @(Ud) 0.01424.*(2*Ud).^(0.4799);
    end
    if ismember('Ne',PSpeciess)
        fYieldC{s.Nei,s.C} = @(Ud) 0.01978.*Ud.^(0.422);          %   Hechtl et al. [66, 67] and Oyarzabal et al. [68] a = 0.01978 and b = 0.422
        %fYieldC{s.Neii,s.NeH} = @(Ud) xi_pulse*xi;
        %fYieldC{s.Neii,s.NeW} = @(Ud) xi_pulse*(1-xi);
        fYieldC{s.Neii,s.C} = @(Ud) 0.01978.*(2*Ud).^(0.422);
    end
end

if ismember('He',PSpeciess) && ...
   ismember('Mo',sputterednames)
    fYieldC{s.Hei,s.Mo} = @(Ud) 2.405393351550965e-10.*Ud.^(3)-5.715410919719532e-07.*Ud.^(2)+4.935141793380290e-04.*Ud-0.028585039661763;
%     fYieldC{s.Moi,s.Mo} = @(Ud) 0.0117.*Ud.^(0.6826);
    fYieldC{s.Moi,s.Mo} = @(Ud) 9.369898599762020e-10.*Ud.^(3)-2.497993346352989e-06.*Ud.^(2)+0.002818594240576.*Ud-0.105973938537696;
    fYieldC{s.Moii,s.Mo} = @(Ud) 9.369898599762020e-10.*(2.*Ud).^(3)-2.497993346352989e-06.*(2.*Ud).^(2)+0.002818594240576.*(2.*Ud)-0.105973938537696;
end


if ismember('Si',sputterednames)    
    fileSiSii=load("Si_Si.m"); % Silicon using TU Wien
    fYieldC{s.Sii,s.Si}  = @(Ud) fileSiSii(round(Ud+1),2).';
    fYieldC{s.Siii,s.Si} = @(Ud) fileSiSii(round(2*Ud+1),2).';
    if ismember('Ar',PSpeciess)
        fileSiAri=load("Si_Ar.m");
        fYieldC{s.Ari,s.Si}  = @(Ud) fileSiAri(round(Ud+1),2).';
        fYieldC{s.Arii,s.Si} = @(Ud) fileSiAri(round(2*Ud+1),2).';
    end
end


%% Yield functions on DIRTY surface ---------------------------------------
% Define yield functions FROM sputtering species TO sputtered species:

if ismember('Ar', PSpeciess)
    xi_pulse = 1; xi = 1/2;
    fYieldD{s.Ari,s.ArH} = @(Ud) xi_pulse*xi;
    fYieldD{s.Ari,s.ArW} = @(Ud) xi_pulse*(1-xi);
    if ismember('Arii', Names)
        fYieldD{s.Arii,s.ArH} = @(Ud) xi_pulse*xi ;
        fYieldD{s.Arii,s.ArW} = @(Ud) xi_pulse*(1-xi);
    end
end

if ismember('N2', PSpeciess)
    % NOTE : should we introduce hot N/N2 for backscattered ions
    xi_pulse = 1; xi = 1/2;
    if isfield(s,'NW') && isfield(s,'NH') && include_HWN
        fYieldD{s.Ni,s.NH} = @(Ud) xi_pulse*xi; % ??? : does this make sense?
        fYieldD{s.N2i,s.NH} = @(Ud) 2*fYieldDs{Ni,s.NH}(Ud/2);
        fYieldD{s.Ni,s.NW} = @(Ud) xi_pulse*(1-xi); % ??? : does this make sense?
        fYieldD{s.N2i,s.NW} = @(Ud) 2*fYieldDs{Ni,s.NW}(Ud/2);
    else
        fYieldC{s.Ni,s.NS} = @(Ud) xi_pulse; % ??? : does this make sense?
        fYieldD{s.N2i,s.N2} = @(Ud) 2*fYieldC{s.Ni,s.NS}(Ud/2); % ??? : does this make sense?
    end
    fYieldD{s.N2i,s.N2} = @(Ud) 0; % ??? : does this make sense?
    % NOTE : assuming a seady state, the nitrogen balance should again be 0
    % however, here it get's a bit more comlicated:
    %
    % 1. (and this also holds for the clean case) since the target is not
    % sputtered most of the time, and compound porbably to a large part
    % forms between the pulses, there should be a net flux of nitrogen from
    % the target to the IRM during the pulse
    % 2. unlike for Ar, thermal neutral nitrogen going to the target does
    % not necessarily return - i.e. there is a nitrogen pumping effect -
    % especially for the highly reactive Ti that is contiuously being
    % uncovered at the target surface
    % 3. if we just consider the sputter rate calculated using TRIM, then
    % the amount of nitrogen we "sputter" is actually going to be lower
    % than for the clean case if the voltage is below 700V, which doesn't
    % make sense.
    %
    % CONCLUSION:
    % I believe the best way would be to also include NH and NW
    % this would allow the separation of the back-scattering/sputtering
    % subplanted N from the sputtering of actual compound N. The next
    % problem would then however be, that since N actually bonds to the
    % target, NW and N coming from the target would in practice be the same
    % thing. Since the energy of the N sputtered from the compound is going
    % to be much higher than the thermal N, only NW should be sputtered
    % instead. However, then we're again at the original problem, namely
    % that if we simply replace the sputtered species and use the TRIM
    % yield, the amount of sputtered N is going to be less than in the
    % clean case for the most part (at least in the pure N2 case).
    % Adding \xi to the yield doesn't necessarily make sense, but leaving
    % it at the pure "sputtered" rate maybe also not.
    % It's a bit of a conundrum.
    % Maybe work by the Depla group on RSD could be helpfull here.
    %
    % PROPOSED SOLUTION:
    % 1. Use N, NW, NH, (and N2H?) populations
    %       N : atomic nitrogen from refill gas / gas phase reactions (next question, is refill being N2 only realistic? Probably somewhat reasonable...)
    %       NH: back-scattered atomic nitrogen
    %       NW: sputtered nitrogen
    % 2. Handle the clean case exactly like the Argon case, i.e.
    %       x_pulse = 1 (all nitrogen ions going to the target will return)
    %       xi = 0.5 (no idea what's reasonable here. Could use backscattering calculated by trim? Maybe not even that important anyway)
    % 3. For the dirty case, use x_pulse*xi for NH and TRIM sputter yield
    %       for NW.
    % 4. Add negative diffusion term for atomic N species corresponding to
    %       thermal flux times target facing IRM surface times some
    %       sticking/pumping coefficient.
end


if ismember('Ar',PSpeciess) && ... % ??? : does this make sense?
   ismember('Ti',sputterednames)
    fYieldD{s.Ari,s.Ti} = @(Ud) fYieldC{s.Ari,s.Ti}(Ud)/3; % note: this is never actually used
    % fYieldD{s.Arii,s.Ti} = @(Ud) fYieldC{s.Arii,s.Ti}(Ud)/3; % note: this is never actually used

    fYieldD{s.Tii,s.Ti} = @(Ud) fYieldC{s.Tii,s.Ti}(Ud)/3; % note: this is never actually used
    fYieldD{s.Tiii,s.Ti} = @(Ud) fYieldC{s.Tiii,s.Ti}(Ud)/3; % note: this is never actually used
    if ismember('N2', PSpeciess)
        % These are all calculated using TRIM
        fYieldD{s.Ari,s.Ti} = @(Ud) max(0.9141*(1e-3*Ud).^0.4425 - 0.2235, 0); % from TRIM
        fYieldD{s.Arii,s.Ti} = @(Ud) fYieldD{s.Ari,s.Ti}(2*Ud);
    
        if isfield(s,'NW') && isfield(s,'NH') && include_HWN
            fYieldD{s.Ari,s.NW} = @(Ud) max(1.930*(1e-3*Ud).^0.4060 - 0.4997, 0); % from TRIM
            fYieldD{s.Arii,s.NW} = @(Ud) fYieldD{s.Ari,s.NS}(2*Ud);
        else
            fYieldD{s.Ari,s.NS} = @(Ud) max(1.930*(1e-3*Ud).^0.4060 - 0.4997, 0); % from TRIM
            fYieldD{s.Arii,s.NS} = @(Ud) fYieldD{s.Ari,s.NS}(2*Ud);
        end
    end
end

if ismember('N2', PSpeciess) && ...
   ismember('Ti',sputterednames)
    fYieldD{s.Tii,s.Ti} = @(Ud) max(0.7820*(1e-3*Ud).^0.5270 - 0.1741, 0); % from TRIM
    fYieldD{s.Ni,s.Ti} = @(Ud) max(2.309*(1e-3*Ud).^0.09466 - 1.694, 0); % from TRIM
    fYieldD{s.Tiii,s.Ti} = @(Ud) fYieldD{s.Tii,s.Ti}(2*Ud);
    fYieldD{s.N2i,s.Ti} = @(Ud) 2*fYieldD{s.Ni,s.Ti}(Ud/2);

    if isfield(s,'NW') && isfield(s,'NH') && include_HWN
        fYieldD{s.Tii,s.NW} = @(Ud) max(1.737*(1e-3*Ud).^0.4658 - 0.3955, 0); % from TRIM
        fYieldD{s.Ni,s.NW} = @(Ud) max(4.999*(1e-3*Ud).^0.07734 - 3.861, 0); % from TRIM % ??? : does this make sense? This requires attention! !!!
        fYieldD{s.Tiii,s.NW} = @(Ud) fYieldD{s.Tii,s.NW}(2*Ud);
        fYieldD{s.N2i,s.NS} = @(Ud) 2*fYieldD{s.Ni,s.NW}(Ud/2);
    else
        fYieldD{s.Tii,s.NS} = @(Ud) max(1.737*(1e-3*Ud).^0.4658 - 0.3955, 0); % from TRIM
        fYieldD{s.Ni,s.NS} = @(Ud) max(4.999*(1e-3*Ud).^0.07734 - 3.861, 0); % from TRIM % ??? : does this make sense? This requires attention! !!!
        fYieldD{s.Tiii,s.NS} = @(Ud) fYieldD{s.Tii,s.NS}(2*Ud);
        % NOTE: fYieldD{s.Ni,s.NS} is determined by trim in this case, but
        fYieldD{s.N2i,s.NS} = @(Ud) 2*fYieldD{s.Ni,s.NS}(Ud/2);
        % does not include the backscattered nitrogen
    end
    % NOTE : s.N2i should also be able to sputter ...
end

%if ismember('Ar',PSpeciess) && ... % ??? : does this make sense?
%   ismember('C',sputterednames)
%    fYieldD{s.Ari,s.C} = @(Ud)0.0021.*Ud.^(0.687)/3;
%end
%
%if ismember('C',sputterednames) % ??? : does this make sense?
%    fYieldD{s.Ci,s.C} = @(Ud)0.0562.*Ud.^(0.224)/3;
%end

if ismember('Ar',PSpeciess) && ... % ??? : does this make sense?
   ismember('Cu',sputterednames)
    fYieldD{s.Ari,s.Cu} = @(Ud) fYieldC{s.Ari,s.Cu}(Ud)/3;
    fYieldD{s.Cui,s.Cu} = @(Ud) fYieldC{s.Cui,s.Cu}(Ud)/3;
    fYieldD{s.Cuii,s.Cu}= @(Ud) fYieldC{s.Cuii,s.Cu}(Ud)/3;
end

if ismember('Ar',PSpeciess) && ...  % mahne 22
   ismember('Al',sputterednames)
    % To sputter Ti for Al from Ti
%     fYieldD{s.Ari,s.Al} = @(Ud) 0.0104.*(Ud).^0.699; %table 2
%     fYieldD{s.Ali,s.Al} = @(Ud) 0.0184.*(Ud).^0.7248; %table 4
%     fYieldD{s.Alii,s.Al}= @(Ud) fYieldD{s.Ali,s.Al}(2*Ud);
    fYieldD{s.Ari,s.Al} = @(Ud) 0;
    fYieldD{s.Ali,s.Al} = @(Ud) 0;
    fYieldD{s.Alii,s.Al}= @(Ud) 0;
end

%{ 
if ismember('Ar',PSpeciess) && ...
   ismember('Zr',sputterednames)
    % To sputter Cu
    fYieldD{s.Ari,s.Zr} = @(Ud) fYieldC{s.Ari,s.Zr}(Ud)/3;
    fYieldD{s.Zri,s.Zr} = @(Ud) fYieldC{s.Zri,s.Zr}(Ud)/3;
    fYieldD{s.Zrii,s.Zr}= @(Ud) fYieldC{s.Zrii,s.Zr}(Ud)/3;
end
%} 

%% Precalculate sputter yield matrices ------------------------------------

% clean
for i = 1:nS
    for j = 1:nS
        if isempty(fYieldC{i,j})
            YieldC(i,j,:) = 0.;
        else
            YieldC(i,j,:) = fYieldC{i,j}(U);
        end
    end
end

% dirty
for i = 1:nS
    for j = 1:nS
        if isempty(fYieldD{i,j})
            YieldD(i,j,:) = 0.;
        else
            YieldD(i,j,:) = fYieldD{i,j}(U);
        end
    end
end

%% Plot sputter yields ----------------------------------------------------

if generate_plots
    
    [file_path,base_name,~] = fileparts(name);
    
    % clean
    for j = 1:length(sputtered)
        figure;
        fn=sprintf('Sputter yield of %s, clean mode', Names{sputtered(j)});
        for i = 1:length(sputtering)
            hold on;
            plot(U, squeeze(YieldC(sputtering(i),sputtered(j),:)));
            hold off;
        end
        title(fn);
        legend(Names(sputtering));
        ylabel('sputter yield');
        xlabel('discharge voltage Ud (volts)');
        saveas(gcf, fn, 'png');
        saveas(gcf, fullfile(file_path,strcat(base_name,'_',Names{sputtered(j)},'_clean')), 'png');
    end
    % dirty 
    for j = 1:length(sputtered)
        figure;
        fn=sprintf('Sputter yield of %s, dirty mode', Names{sputtered(j)});
        for i = 1:length(sputtering)
            hold on;
            plot(U, squeeze(YieldD(sputtering(i),sputtered(j),:)));
            hold off;
        end
        title(fn);
        legend(Names(sputtering));
        ylabel('sputter yield');
        xlabel('discharge voltage Ud (volts)');
        saveas(gcf, fullfile(file_path,strcat(base_name,'_',Names{sputtered(j)},'_dirty')), 'png');
    end
end

%% Export structure -------------------------------------------------------

Yield.C = YieldC;
Yield.D = YieldD;

if exist('name', 'var') && ~isempty(name)
    save(name, 'Yield');
    filename = fullfile(pwd(),name);
else
    filename = "";
end

end

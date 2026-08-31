function [filename, Ec] = create_Ec(Spe, name, generate_plots)
%CREATE_EC generate cost of ionization tables
%==========================================================================
% Precomputes effective ionization cost and saves the in a matlab structure
% -------------------------------------------------------------------------
% PARAMETERS:
% - Spe            : structure containing species information
% - name           : name of .mat file to which structure will be saved
% - generate_plots : whether to generate plots (default=False)
% -------------------------------------------------------------------------
% USAGE EXAMPLE:
% create_Ec(Spe, 'Ec_ArTi')
%==========================================================================

%% NOTES ------------------------------------------------------------------
% This is a modified version of create_Ec that was written by M.J.
% Adriaans. Parameters (such as those for the electron temperature vector) 
% are transferred from the old code. See Martin's file for differences

% TODO: get better description of expected Spe parameter
% TODO: figure out if use of collumn or row matrices would be more
% appropriate
% TODO: clean up source code
% TODO: if possible fix Cu and N2 mess
% TODO: find out what species 9 is and fix it

%% Read out parameters ----------------------------------------------------

% check for optional arguments
if nargin < 3
    generate_plots = false;
end

% defining some quantities
Names = Spe.Names; % names of the species
s = Spe.s; % indecies of the species

nS = length(Names); % the number of species

%% Define temperature range and resolution --------------------------------
% Define the array size and its resolution

% cold electron temperature vector 
Tec_min = 0.5; % temperature min in eV
Tec_max = 10;  % temperature max in eV
if isfield(s, 'He') && isfield(s, 'Mo') % NOTE : @Zakaria what is the reason for the different range? /joel
    Tec_max = 15;  % temperature max in eV
end

%if isfield(s, 'Ar') && isfield(s, 'Si') 
%    Tec_max = 16;  % temperature max in eV
%end
dTec = 1e-3;   % temperature resolution between Tec_min and Tec_max

Tec = Tec_min:dTec:Tec_max;

% hot electron temperature vector
Teh_min = 10;   % temperature min in eV
if isfield(s, 'He') && isfield(s, 'Mo') % NOTE : @Zakaria what is the reason for the different range? /joel
    Teh_min = 200;   % temperature min in eV
end
if isfield(s, 'Ar') && isfield(s, 'Si') 
    Teh_min = 16;  % temperature min in eV
end
Teh_max = 1000; % temperature max in eV
dTeh = 1e-1;    % temperature resolution between Teh_min and Teh_max

Teh = Teh_min:dTeh:Teh_max; % the temperature vector

%% Preallocation of cost data matrices and function cell arrays -----------

% cold
Ec.c = zeros(nS,length(Tec));
Ec.Tec_min = Tec_min;
Ec.Tec_max = Tec_max;
Ec.dTec = dTec;

% hot
Ec.h = zeros(nS,length(Teh));
Ec.Teh_min = Teh_min;
Ec.Teh_max = Teh_max;
Ec.dTeh = dTeh;

% create the cell array for cost functions
fEc.c = cell(nS,1); % cold
fEc.h = cell(nS,1); % hot

%% Cost functions ---------------------------------------------------------

if ismember("Ar", Spe.Names)
    
    % exitation/ionization energies
    EexAr = 11.56;
    EizAr = 15.76;
    E_ex_iz = EizAr - EexAr;
    
    % cold
    fEc.c{s.Ar} = @(T) Ecc_Cal_Ar(T);
    fEc.c{s.ArW} = @(T) fEc.c{s.Ar}(T);
    fEc.c{s.ArH} = @(T) fEc.c{s.Ar}(T);
    fEc.c{s.Arm3P0} = @(T) E_ex_iz;
    fEc.c{s.Arm3P2} = @(T) E_ex_iz;
    
    % hot
    EchAr   = 21.95; %

    fEc.h{s.Ar} = @(T) EchAr;
    fEc.h{s.ArW} = @(T) EchAr;
    fEc.h{s.ArH} = @(T) EchAr;
    fEc.h{s.Arm3P0} = @(T) fEc.c{s.Arm3P0}(T);
    fEc.h{s.Arm3P2} = @(T) fEc.c{s.Arm3P2}(T);
end

if ismember("Ne", Spe.Names)
    
    % exitation/ionization energies
    EexNe = 16.62;
    EizNe = 21.56;
    E_ex_iz = EizNe - EexNe;
    %newpath = "/home/kateryna/ArNe/irm-dev-ne/pre-cal/Ec/neon";
   % userpath(newpath)
    % cold
    fEc.c{s.Ne} = @(T) neonx(T,Tec_min,dTec,Tec_max);
    fEc.c{s.NeW} = @(T) fEc.c{s.Ne}(T);
    fEc.c{s.NeH} = @(T) fEc.c{s.Ne}(T);
    fEc.c{s.Nem2P0} = @(T) E_ex_iz;
    fEc.c{s.Nem2P2} = @(T) E_ex_iz;
    
    % hot
    fEc.h{s.Ne} = @(T) neonx(T,Teh_min,dTeh,Teh_max); % exp(polyval([ -0.0004    0.0118   -0.1421    0.8854   -2.8789    7.0901 ],log(T)));
    fEc.h{s.NeW} = @(T) fEc.h{s.Ne}(T);
    fEc.h{s.NeH} = @(T) fEc.h{s.Ne}(T);
    fEc.h{s.Nem2P0} = @(T) fEc.c{s.Nem2P0}(T);
    fEc.h{s.Nem2P2} = @(T) fEc.c{s.Nem2P2}(T);
end

if ismember("He", Spe.Names)
    
    % exitation/ionization energies
    EexHem2S1 = 19.82;
%     EexHem2S0 = 20.62;
    EizHe = 24.58; %first
    E_ex_iz = EizHe - EexHem2S1;

    % cold
    fEc.c{s.He} = @(T) Ecc_Cal_He(T);
    fEc.c{s.HeW} = @(T) fEc.c{s.He}(T);
    fEc.c{s.HeH} = @(T) fEc.c{s.He}(T);
    fEc.c{s.Hem2S1} = @(T) E_ex_iz;
    
    
    % hot
    fEc.h{s.He} = @(T) Ech_Cal_He(T);
    fEc.h{s.HeW} = @(T) fEc.h{s.He}(T);
    fEc.h{s.HeH} = @(T) fEc.h{s.He}(T);
    fEc.h{s.Hem2S1} = @(T) E_ex_iz;
end

if ismember("Mo", Spe.Names)
    % exitation/ionization energies
    EizMoi = 16.16; %second ioniz energy
    
    % cold
    fEc.c{s.Mo} = @(T) exp(0.0436 .*  (log(T)).^4  -0.5429  .*  (log(T)).^3 +  2.6490  .*  (log(T)).^2 -6.1981 .*  (log(T)) +  8.1849);
    fEc.c{s.Moi} = @(T) EizMoi;

    % hot
    EchMo = 7.0924;
    
    fEc.h{s.Mo} = @(T) exp(-0.0179 * log(T) +  2.1507);
    fEc.h{s.Moi} = @(T) EizMoi;
    
    % sEcC = [s.Ti]; % QUESTION: what's this?   Good Question! 
end

if ismember("Zr", Spe.Names)
    % exitation/ionization energies
    EizZri = 13.13; %second
    
    % cold
    fEc.c{s.Zr} = @(T) exp(polyval([0.1244 -1.2059 4.3160 -6.8329 6.0525],log(T)));
    fEc.c{s.Zri} = @(T) EizZri;

    % hot
    %EchMo = 7.0924;
    
    fEc.h{s.Zr} = @(T) exp(polyval([0.0150 1.8170],log(T)));
    fEc.h{s.Zri} = @(T) EizZri;
    
    % sEcC = [s.Ti]; % QUESTION: what's this?   Good Question! 
end

if ismember("Ti", Spe.Names)
    
    % exitation/ionization energies
    EizTii = 13.58; %second
    
    % cold
    fEc.c{s.Ti} = @(T) exp(polyval([0.093 -0.9623 3.7747 -6.8443 7.1135],log(T)));
    fEc.c{s.Tii} = @(T) EizTii;

    % hot
    EchTi = 7.15;
    
    fEc.h{s.Ti} = @(T) EchTi;
    fEc.h{s.Tii} = @(T) EizTii;
    
    sEcC = [s.Ti]; % QUESTION: what's this? 
end

if ismember('W', Spe.Names)
    
    % exitation/ionization energies
    EizWi=16.100;  %second
    
    % cold
    fEc.c{s.W}=@(T) exp(polyval([0.093 -0.9623 3.7747 -6.8443 7.1135],log(T))); % QUESTION: Is this actually suppposed to be the same as Ti?
    fEc.c{s.Wi}=@(T) EizWi;

    % hot
    EchW   = 7.15; % QUESTION: Is this actually suppposed to be the same as Ti?

    fEc.h{s.W}=@(T) EchW;
    fEc.h{s.Wi}=@(T) EizWi;
    
    sEcC = [s.W]; % QUESTION: what's this?
end

if ismember('Cu', Spe.Names)
    
    % exitation/ionization energies
    EizCui = 7.73; %first
    EizCuii = 20.29;  %second
    EexCum1 = 1.39;
    EexCum2 = 1.64;
    EexCum3 = 3.79;
    EchCu   = EizCui - EexCum1;

    % cold
    fEc.c{s.Cu} = @(T) exp(polyval([-0.0037 0.0728 -0.5460 2.0721 -4.2465 6.6845],log(T)));
    fEc.c{s.Cum1} = @(T) EexCum1;
    fEc.c{s.Cum2} = @(T) EexCum2;
    fEc.c{s.Cum3} = @(T) EexCum3;
    fEc.c{s.Cui} = @(T) EizCuii;
    % fEc.c{s.Cuii} = @(T) EizCuii;

    % hot

    %fEc.h{s.Cu}=@(T) EchCu;
    fEc.h{s.Cu} = @(T) exp(polyval([-0.0037 0.0728 -0.5460 2.0721 -4.2465 6.6845],log(T)));
    fEc.h{s.Cum1} = @(T) EexCum1;
    fEc.h{s.Cum2} = @(T) EexCum2;
    fEc.h{s.Cum3} = @(T) EexCum3;
    fEc.h{s.Cui} = @(T) EizCuii;
   % fEc.h{s.Cuii} = @(T) EizCuii;
    
    sEcC=[s.Cu]; % QUESTION: what's this?
end

if ismember("Cr", Spe.Names)
    
    % exitation/ionization energies
    EizCri = 16.4857;  %second
    
    % cold
    fEc.c{s.Cr} = @(T) exp(polyval([1.0316 -3.8503 6.0172],log(T)));  % Ec = exp(6.0172 - 3.8503 x (log(Te)) + 1.0316 x (log(Te))^2    1 < Te < 7 eV
    fEc.c{s.Cri} = @(T) EizCri;

    % hot
    fEc.h{s.Cr} = @(T) 7.0384+1.894e-4*T; % Ec = 7.0384 + 1.894E-4 x Te   200 < Te < 1000 eV
    fEc.h{s.Cri} = @(T) EizCri;
    
   % sEcC = [s.Ti]; % QUESTION: what's this? 
end

if ismember('Al', Spe.Names)
    
%     % exitation/ionization energies
     EizAli = 5.98577; %first ioniz potential for Al
     EizAlii = 18.82856; %second ioniz potential for Al

% 
%     % cold
     fEc.c{s.Al} = @(T) exp(polyval([0.0771 -0.2784 -0.6508 4.7010],log(T))); %from mail 23.01.23
     fEc.c{s.Ali} = @(T) EizAlii;
% 
%     % hot
     fEc.h{s.Al} = @(T) exp(polyval([-0.0025 2.0496],log(T))); %from mail 23.01.23
     fEc.h{s.Ali} = @(T) EizAlii;

end

if ismember("N2",Spe.Names)
    
    % exitation/ionization energies
    % TODO : get these directly from Spe structure
    EizN2 = 15.581;
    EizN = 14.534;
    EexN2_N2A = 6.168;
    EexN_ND = 2.383;
    EexN_NP = 3.575;

    % cold
    fEc.c{s.N2A}=@(T) EizN2 - EexN2_N2A;
    fEc.c{s.ND}=@(T) EizN - EexN_ND;
    fEc.c{s.NP}=@(T) EizN - EexN_NP;
    % fEc.c{s.N2}=@(T) % these two are calculated directly from the
    fEc.c{s.N2}=@(T) EizN2;
    % icelandic % TODO: find proper value/function (c.f. further down in this file)
    % fEc.c{s.N}=@(T) % TODO: find proper value/function (c.f. further down in this file)
    fEc.c{s.NS}=@(T) EizN;
    
    % hot
    EchN2 = 15.58; % this value is chosen for Ec at 200eV % TODO: get this from N2 volume code
    EchN = 17.46; % TODO: get this from N2 volume code

    fEc.h{s.N2} = @(T) EchN2;
    fEc.h{s.NS} = @(T) EchN;
    if ismember('NW', Spe.Names) && ismember('NH', Spe.Names) 
        fEc.h{s.NW} = @(T) EchN;
        fEc.h{s.NH} = @(T) EchN;
    end
    fEc.h{s.N2A} = fEc.c{s.N2A};
    fEc.h{s.ND} = fEc.c{s.ND};
    fEc.h{s.NP} = fEc.c{s.NP};
end

if ismember("Si", Spe.Names)
    
    % exitation/ionization energies
    EizSi = 8.15 ;
    
    % cold
    fEc.c{s.Si} = @(T) sixx(T,Tec_min,dTec,Tec_max);
    fEc.c{s.Sii} = @(T) EizSi;
    
    % hot
    fEc.h{s.Si} = @(T) sixx(T,Teh_min,dTeh,Teh_max);
    fEc.h{s.Sii} = @(T) EizSi;
    
end

if ismember("C", Spe.Names)
            
    % load carbon data
    load("../carbon/carbon_C_Rea.mat", 'carbon_C_Rea'); % TODO: use fullfile
    
    % masses
    Me = 9.10938e-31;
    MC = 1.9944235e-26;
    
    % exitation/ionization energies
    EizC = 11.26030; %first ionization energy
    EizCm1 = EizC - carbon_C_Rea.Evec(2);
    EizCm2 = EizC - carbon_C_Rea.Evec(3);
    EizCm3 = EizC - carbon_C_Rea.Evec(4);
    
    EizCvec = [EizC, EizCm1, EizCm2, EizCm3];
    sEcC = [s.C, s.Cm1, s.Cm2, s.Cm3];
    kizC = @(T) 3.692e-15*T.^(1.182).*exp(-9.332./T);
    PolyelasC = [-0.139566512526511,-0.026868892246868,-43.068445976703046]; % PhysRevA.87.012704
    KelC = @(T) exp(polyval(PolyelasC,T));
    % NOTE: no idea what's going on here, just gonna assume it's correct...
    for rea1 = 1:4
        kizCc = @(T) kizC(T)*carbon_C_Rea.Relative_K_iz.c(rea1);
        kizCh = @(T) kizC(T)*carbon_C_Rea.Relative_K_iz.h(rea1);
        fEc.c{sEcC(rea1)} = @(T) T.*KelC(T)./kizCc(T)*3*Me/MC + EizCvec(rea1);
        fEc.h{sEcC(rea1)} = @(T) T.*KelC(T)./kizCh(T)*3*Me/MC + EizCvec(rea1);        
        for rea2 = 5:22
            if rea1 ~= rea2
                equation = carbon_C_Rea.table(rea1,rea2);
                if not(ismember(equation, carbon_C_Rea.ForbiddenRea)) && equation ~= 0
                    fEc.c{sEcC(rea1)} = @(T) fEc.c{sEcC(rea1)}(T) + ...
                                        carbon_C_Rea.Vif(equation).*exp(polyval(carbon_C_Rea.Polynome{equation},log(T)))./kizCc(T);
                    fEc.h{sEcC(rea1)} = @(T) fEc.c{sEcC(rea1)}(T) + ...
                                        carbon_C_Rea.Vif(equation).*exp(polyval(carbon_C_Rea.Polynome{equation},log(T)))./kizCh(T);
                end
            end
        end
    end
    
end

%% Precalculate ionization cost matrices ----------------------------------

% cold
for j=1:nS
    if ~isempty(fEc.c{j})
        Ec.c(j,:) = fEc.c{j}(Tec);
    end
end

% hot
for j=1:nS    
    if ~isempty(fEc.h{j})
        Ec.h(j,:) = fEc.h{j}(Teh);
    end
end

if ismember("C", Spe.Names) % NOTE: this is new
    % NOTE: this is from the Carbon version, seems to be atomic Carbon
    % TODO: check with JT if species 9 is really supposed to be Carbon
    %JTfit = @(T) exp(6.8635 - 5.8878*log(T) + 3.3510* (log(T)).^2  - 1.0333*(log(T)).^3 + 0.175699*(log(T)).^4 -0.015482*(log(T)).^5 + (5.5243E-4)*(log(T)).^6);
    JTfit = @(T) exp(6.8385 - 5.7683*log(T) + 3.3952* (log(T)).^2  - 1.0681*(log(T)).^3 + 0.184423*(log(T)).^4 -0.016474*(log(T)).^5 + (5.9551e-04)*(log(T)).^6);
    %Ec.c(s.C,:) = JTfit(Tec); % FIXME ALERT
    %Ec.h(s.C,:) = JTfit(Teh); % FIXME ALERT
    Ec.c(s.C,:) = JTfit(Tec); % QUESTION is this right ?
    Ec.h(s.C,:) = JTfit(Teh); % QUESTION is this right ?
end % NOTE: this is new

%% N2 is precalculated, from a different file

% % TODO: put this in the proper place (if possible)
% if ismember("N2",Spe.Names)
%     %N2->this does not work yet. Part of older code
% 
%     % As for N2: they are stolen from the Icelandic code
%     % From the energyloss reaction set saved in \User\Energyloss.mat
%     % In \misc\Ec, the function EcCalc(Te) calculates the Ec of N2 and N for a
%     % given Te-vector.
%     % Go to that directory and run the file 'stealing_EcN2.m' to obtain this
%     % file that was copied back to here:
%     % For both N2 and N, I saved one from 0.5~10eV with high resolution and one
%     % from 10~1000eV with low resolution.
%     load('../N2/stealing_EcN2.mat') % FIXME NOTE: there are lots of variables in this file.
%     Ec.c(s.N2,:) = Ecc_N2;
%     Ec.c(s.NS,:) = Ecc_N;
% end

%% Plot sputter yields ----------------------------------------------------

if generate_plots
    
    [file_path,base_name,~] = fileparts(name);
    
    figName = 'E_c_values';
    fig = figure('Name',figName);
    %semilogy(Tec,Ec.c(sEcC,:))
    loglog(Teh, Ec.h(sEcC,:), 'LineWidth', 1)
    %xlim([1,15]);
    xlabel('$T_{e_h}$', 'Interpreter', 'latex')
    ylabel('$\mathcal{E}_{\mathrm{c}}$(eV)', 'Interpreter', 'latex')
    hleg = legend(Spe.Names(sEcC));
    hleg.Location = 'northeast';
    saveas(gcf, fullfile(file_path,base_name), 'png');
end

%% Export structure -------------------------------------------------------

if exist('name', 'var') && ~isempty(name)
    save(name,'Ec');
    filename = fullfile(pwd(),name);
else
    filename = "";
end

end






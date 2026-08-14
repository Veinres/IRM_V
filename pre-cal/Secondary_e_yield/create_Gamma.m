function [filename, gamma] = create_Gamma(Spe, name, generate_plots)
%CREATE_GAMMA generate secondary e- yield tables
%==========================================================================
% Precomputes the energy dependent secondary electron emission
% probabilities for different sputtering species and different target
% conditions (clean/dirty) and saves them into a Matlab structure
% -------------------------------------------------------------------------
% PARAMETERS:
% - Spe            : structure containing species information
% - name           : name of .mat file to which structure will be saved
% - generate_plots : whether to generate plots (default=False)
% -------------------------------------------------------------------------
% USAGE EXAMPLE:
% create_Gamma(Spe, 'gamma_ArTi')
%==========================================================================

%% NOTES ------------------------------------------------------------------
% TODO: get better description of expected Spe parameter
% TODO: figure out if use of collumn or row matrices would be more
% appropriate
% TODO: add voltage range/resolution to function parameters in case there
% are cases where different values would be used (parameters shouldn't be
% changed in the source code of a function)
% TODO: clean up source code
% TODO: add some messages so one can be sure it's doing something

%=======
% TODO: check sputtering species & sputtered species pairs for each case
%=======

% QUESTION: is there a reason not to include Arii in each case?

%% Read out parameters ----------------------------------------------------

% check for optional arguments
if nargin < 3
    generate_plots = false;
end

% defining some quantities
Names = Spe.Names; % names of the species
s = Spe.s; % indecies of the species

nS = length(Names); % number of species

%% Define voltage range and resolution ------------------------------------
% Define the matrix size and its resolution
% Valid range for the given sputter yield functions
Umin = 0;    % voltage min in volts
Umax = 2000; % voltage max in volts 
dU   = 1;    % voltage resolution between Umin to Umax

U = Umin:dU:Umax ; % the voltage vector
nU = length(U); % length the of the voltage vector

%% Preallocation of yield data matrices and function cell arrays ----------

% create yield matrix
% (sputtering species, energy)
gamma.C = zeros(nS,nU); % clean
gamma.D = zeros(nS,nU); % dirty

% create the cell array for yield functions
% (sputtering species)
fGamma.C = cell(nS,1); % clean % JF: added ,1 , as creating a 2D array was probably done by mistake
fGamma.D = cell(nS,1); % dirty % JF: added ,1 , as creating a 2D array was probably done by mistake

%% Energy-dependent secondary electron yields for Argon on metals ---------

% The following secondary electron yields are taken from:
% "Cold-cathode discharges and breakdown in argon: surface and gas phase
% production of secondary electrons", Plasma Sources Sci. Technol. 8(1999),
% R21, A V Phelps and Z Lj Petrovic
% eqs. B10, B12, B15 and B17
% with corrections to B15 from the footnote in "Use of secondary-electron
% yields determined from breakdown data in cathode-fall models for Ar",
% Plasma Sources Sci. Technol. 8(1999),
% A V Phelps, L C Pitchford, CPedoussat and Z Donko
%
% (Sputtering by netruals isn't taken into account,
% so B12 and B17 aren't actually needed)
%
% For the ions: E~=Q*Ud
%
% The Phelps fit is used for metallic targets in case no better value is
% known (either through measurement or different literature).

gamma_clean_metal_Ar  = @(E) 1e-5*(E > 500).*(E - 500).^(1.2)./(1 + (E/70000).^(0.7)); % B12
%gamma_clean_metal_Ari = @(E) 0.07 + gamma_clean_metal_Ar(E); % B10 Phelps
gamma_clean_metal_Ari = @(E) 0.032*(0.78*27.63 - 2*4.73); % Baragiola
gamma_dirty_metal_Ar  = @(E) 1e-4*(E > 90).*(E - 90).^(1.2)./(1 + (E/8000).^(1.5))...
                          + 7e-5*(E > 32).*(E - 32).^(1.2)./(1 + (E/2800).^(1.5)); % B17
gamma_dirty_metal_Ari = @(E) 6e-3*E./(1 + (E/10))...
                          + 1.05e-4*(E > 80).*(E - 80).^(1.2)./((1 + (E/8000)).^(1.5)); % B15

%% Other 2ndary e- yields
                      
% Ionization energies
Eiz_Ar = 15.7596;
Eiz_C  = 11.26;
Eiz_Ci = 24.38;
Eiz_Moii = 16.16;
Eiz_Si = 8.15;

% Base functions for yields
base_gamma_clean = @(Ud) 0.0255 + 1.4609e-5*Ud;  %0.0246 + 1.661e-5*Ud
base_gamma_dirty = @(Ud) 0.0001;

%Ne 
base_gamma_clean_Ne = @(Ud) 0.1216 + 4.8688e-5*Ud;  %γsee,Ne+ = 0.1216 + 4.8688 × 10−5Ei 

%% Yield functions on CLEAN surface ---------------------------------------
% Define yield functions FROM sputtering species TO sputtered species:

if ismember('Ar',Names)
    % NOTE: These are the values to be used for metallic targets if no better estimate/measurement is present
    fGamma.C{s.Ari}  = @(Ud) gamma_clean_metal_Ari(Ud);% JF: added on 27.08.21 after discussion with JTG and MR
    if ismember('Arii',Names)
        fGamma.C{s.Arii} = @(Ud) gamma_clean_metal_Ari(2*Ud);% JF: added on 30.08.21 (doesn't work for the current Spe) % instead do 4.3*fGamma.C{s.Ari}
    end
end

if ismember('He',Names)
    % NOTE: These are the values to be used for metallic targets if no better estimate/measurement is present
    fGamma.C{s.Hei}  = @(Ud) 1;% JF: 
end

if ismember('Ti', Names)
    fGamma.C{s.Tii}  = @(Ud) 0.;
    fGamma.C{s.Tiii} = @(Ud) 0.0617; % 0.032*(0.78*13.5755-2*4.33) = 0.0617
    %fGamma.C{s.Ari} = @(Ud) 0.032*(0.78*Eiz_Ar-2*4.5); % previously used yield (wrong) %TODO : remove
end

if ismember('Zr', Names)
    fGamma.C{s.Zri}  = @(Ud) 0;
    fGamma.C{s.Zrii} = @(Ud) 0.0685; % FIXME 0.032*(0.78*13.13-2*4.05); = 0.0685 second ionization energy for Zr 13.13 eV, work function 4.05 eV from Wikipedia
end

if ismember('C', Names)
    %Value is not from literature or experiment, but simply copied from
    %Argon
    fGamma.C{s.Ari}  = @(Ud) base_gamma_clean(Ud); % Ar 2ndary e- yield is different on non-metals
    fGamma.C{s.Ci}   = @(Ud) 0.714*base_gamma_clean(Ud); % NOTE: This is from the C version
    % if ismember('Arii', Names)
    fGamma.C{s.Arii} = @(Ud) base_gamma_clean(2*Ud); % Ar 2ndary e- yield is different on non-metals
    % end
    % if ismember('Cii', Names)
    fGamma.C{s.Cii}  = @(Ud) 0.032*(0.78*Eiz_Ci-2*4.62); % = 0.3128  NOTE: This is from the C version
    % end
    if ismember('Ne',Names) %added Ne to ArC
    fGamma.C{s.Nei}  = @(Ud) base_gamma_clean_Ne(Ud);
    fGamma.C{s.Neii} = @(Ud) 3.1*base_gamma_clean_Ne(Ud); % 0.032*(0.78*62.52-2*4.62);
    end
end

if ismember('W', Names)
    fGamma.C{s.Wi}  = @(Ud) 0.;
    fGamma.C{s.Wii} = @(Ud) 0.1582; % FIXME % 0.032*(0.78*17.619-2*4.4) = 0.1582
    fGamma.C{s.Ari}= @(Ud) 0.094; % We're not using Phelps fit for Tungsten (we have got a measurement) 
                                    
end

if ismember('Cr', Names)
    fGamma.C{s.Cri}  = @(Ud) 0.;
    fGamma.C{s.Crii} = @(Ud) 0.23; % Cr IRM paper
end

if ismember('Mo', Names)
    fGamma.C{s.Moi}  = @(Ud) 0.;
    fGamma.C{s.Moii} = @(Ud) 0.1154; %0.032*(0.78*Eiz_Moii -2*4.5); %= 0.1154
end


% No secondary emission for Cu at first ionisation
if ismember('Cu', Names)
    %fGamma.C{s.Ari} = @(Ud)  base_GammafuncC(Ud); % previously used yield (wrong) % TODO: remove
    %fGamma.C{s.Arii} = @(Ud) base_GammafuncC2(Ud); % previsously used yield % TODO: check and remove
    fGamma.C{s.Cui}  = @(Ud) 0.;
    fGamma.C{s.Cuii} = @(Ud) 0.2121; % FIXME 0.032*(0.78*20.29240 -2*4.6); = 0.2121
end

if ismember('Al',Names) 
    fGamma.C{s.Ali}  = @(Ud) 0.; 
    % if ismember('Alii',Names)
    fGamma.C{s.Alii} = @(Ud) 0.2076; % % FIXME  0.032*(0.78*18.82856 -2*4.1); = 0.2076
    %end
end

if ismember('N2', Names)
    fGamma.C{s.Ni}  = @(Ud) gamma_clean_metal_Ari(Ud); % Here the idea is, that electronically TiN is similar to a metal and the ionisation energy of Ni is close to that of Ari
    fGamma.C{s.N2i} = @(Ud) gamma_clean_metal_Ari(Ud); % Same here - it should probably be expected that molecules act a bit different though
    if ismember('N3i', Names); fGamma.C{s.N3i} = @(Ud) 0.; end % not included ATM
    if ismember('N3i', Names); fGamma.C{s.N4i} = @(Ud) 0.; end % not included ATM
end

if ismember('Si', Names) % # silicon line #
    fGamma.C{s.Sii}  = @(Ud) 0;
    fGamma.C{s.Siii} = @(Ud) 0.105376; % 0.032(0.78*16.35-2*4.73); 
end

%% Yield functions on DIRTY surface ---------------------------------------
% Define yield functions FROM sputtering species TO sputtered species:

if ismember('Ar', Names)
    % NOTE: These are the values to be used for metallic targets if no better estimate/measurement is present
    fGamma.D{s.Ari}  = @(Ud) gamma_dirty_metal_Ari(Ud); % JF: added on 27.08.21 after discussion with JTG and MR
    if ismember('Arii', Names)
        fGamma.D{s.Arii} = @(Ud) gamma_dirty_metal_Ari(2*Ud); % JF: added on 30.08.21 % TODO: check valid and necessary
    end
end

if ismember('He',Names)
    % NOTE: These are the values to be used for metallic targets if no better estimate/measurement is present
   fGamma.D{s.Hei}  = @(Ud) 1; % JF: added on 27.08.21 after discussion with JTG and MR
end

% FIXME: should Ari yield be different for non-metals (i.e. C) in the dirty
% case as well?

if ismember('Ti', Names)
    fGamma.D{s.Tii}  = @(Ud) 0.;
    fGamma.D{s.Tiii} = @(Ud) 0.062;
end

if ismember('Al', Names)
    fGamma.D{s.Ali}  = @(Ud) 0.;
    fGamma.D{s.Alii} = @(Ud) 0.;
end

if ismember('C', Names) % does this even make sense???
    fGamma.D{s.Ci} = @(Ud) base_gamma_dirty(Ud);
    
    %fGamma.D{s.Ari} = @(Ud) base_gamma_dirty(Ud); % NOTE: this was used in Cu version
    fGamma.D{s.Ari} = @(Ud) 0.; % previously there wasn't any yield in this case % FIXME: check if this is actually correct
    if ismember('Arii', Names)
        fGamma.D{s.Arii} = @(Ud) 0.; % previously there wasn't any yield in this case % FIXME: check if this is actually correct
    end
end

if ismember('W', Names) % does this even make sense???
    fGamma.D{s.Wi}  = @(Ud) 0.;
    fGamma.D{s.Wii} = @(Ud) 0.;
end

if ismember('Cr', Names)
    fGamma.D{s.Cri}  = @(Ud) 0.;
    fGamma.D{s.Crii} = @(Ud) 0.23; % Cr IRM paper
end

if ismember('Zr', Names)
    fGamma.D{s.Zri}  = @(Ud) 0.;
    fGamma.D{s.Zrii} = @(Ud) 0.;
end

if ismember('Cu', Names) % does this even make sense???
    fGamma.D{s.Cui}  = @(Ud) base_gamma_dirty(Ud)*2;
    fGamma.D{s.Cuii} = @(Ud) base_gamma_dirty(Ud)*3;
end

if ismember('N2', Names)
    fGamma.D{s.Ni}  = @(Ud) gamma_dirty_metal_Ari(Ud); % Here the idea is, that electronically TiN is similar to a metal and the ionisation energy of Ni is close to that of Ari
    fGamma.D{s.N2i} = @(Ud) gamma_dirty_metal_Ari(Ud); % Same here - it should probably be expected that molecules act a bit different though
    if ismember('N3i', Names); fGamma.D{s.N3i} = @(Ud) 0.; end % not included ATM
    if ismember('N3i', Names); fGamma.D{s.N4i} = @(Ud) 0.; end % not included ATM
end

if ismember('Mo', Names) % does this even make sense???
    fGamma.D{s.Moi}  = @(Ud) 0;
    fGamma.C{s.Moii} = @(Ud) 0.032*(0.78*Eiz_Moii -2*4.5);    
end

%% Precalculate secondary electron yield matrices -------------------------

% clean
for i = 1:nS
    if ~isempty(fGamma.C{i})
        gamma.C(i,:) = fGamma.C{i}(U);
    end
end

% dirty
for i = 1:nS
    if ~isempty(fGamma.D{i})
        gamma.D(i,:) = fGamma.D{i}(U);
    end
end

%% Plot secondary electron yields -----------------------------------------

if generate_plots
    
    range_ions = arrayfun(@(x) x > 0, Spe.Q);


    [file_path,base_name,~] = fileparts(name);
    
    % clean
    figure;
    plot(U, gamma.C(range_ions,:));
    title('Secondary e yield clean mode');
    legend(Names(range_ions), 'Location', 'northwest');
    ylabel('secondary electron yeild $\gamma$');
    xlabel('discharge voltage $U_d$ (volts)');
    set(gca, 'XScale', 'linear')
    saveas(gcf, fullfile(file_path,strcat(base_name, '_clean')), 'png');

    % dirty
    figure;
    plot(U, gamma.D(range_ions,:));
    title('Secondary e yield dirty mode');
    legend(Names(range_ions), 'Location', 'northwest');
    ylabel('secondary electron yeild $\gamma$');
    xlabel('discharge voltage $U_d$ (volts)');
    set(gca, 'XScale', 'linear')
    saveas(gcf, fullfile(file_path,strcat(base_name, '_dirty')), 'png');
end

%% Export structure -------------------------------------------------------

if exist('name', 'var') && ~isempty(name)
    save(name, 'gamma');
    filename = fullfile(pwd(),name);
else
    filename = "";
end

end


% DEPRECATED : TODO switch
function create_Para(discharge)
% Parameters and constants
% Important parameters:

f = 0.099; % important parameters : ignored down the line
r = 0.86; % important parameters : ignored down the line
beta = 0.89; % important parameters : ignored down the line

% degree of poisoned
deg_poi = 0;

% hot electron related
F_Teh = 1/2; % a parameter
U_htc = 10 ; % energy hot2cold

% Constants and geometry

cu_original_disch = {'ArCu/original/ArCu_HiPSTER',...
                    'ArCu/original/ArCu_HiPSTER_20A',...
                    'ArCu/original/ArCu_Sinex2_27Pa',...
                    'ArCu/original/ArCu_Sinex2_04Pa',...
                    'ArCu/original/ArCu_Sinex1'};

cu_paper_disch = {'ArCu/irm/ArCu_HiPSTER_40us_0.5Pa_130A',...
                'ArCu/irm/ArCu_HiPSTER_40us_0.5Pa_165A',...
                'ArCu/irm/ArCu_HiPSTER_40us_0.5Pa_180A',...
                'ArCu/irm/ArCu_HiPSTER_40us_0.5Pa_200A',...
                'ArCu/irm/ArCu_HiPSTER_40us_0.5Pa_235A',...
                'ArCu/irm/ArCu_HiPSTER_40us_0.5Pa_360A',...
                ...
                'ArCu/irm/ArCu_HiPSTER_80us_2.7Pa_130A',...
                'ArCu/irm/ArCu_HiPSTER_80us_2.7Pa_165A',...
                'ArCu/irm/ArCu_HiPSTER_80us_2.7Pa_200A',...
                'ArCu/irm/ArCu_HiPSTER_80us_2.7Pa_235A',...
                'ArCu/irm/ArCu_HiPSTER_80us_2.7Pa_360A',...
                ...
                'ArCu/irm/ArCu_HiPSTER_80us_0.4Pa_130A',...
                'ArCu/irm/ArCu_HiPSTER_80us_0.4Pa_165A',...
                'ArCu/irm/ArCu_HiPSTER_80us_0.4Pa_200A',...
                'ArCu/irm/ArCu_HiPSTER_80us_0.4Pa_235A',...
                'ArCu/irm/ArCu_HiPSTER_80us_0.4Pa_360A'...
                };

cu_follow_up_disch = {dir(fullfile("discharge","Cu_FollowUp","ArCu_*")).name};

other_disch = horzcat(cu_paper_disch, cu_follow_up_disch);

if exist('discharge','var')
    switch discharge
        case 'ArCu HiPSTER'
            r1 = 6e-3;
            r2 = 20e-3;
            z1 = 2e-3;
            z2 = 28e-3;
        case 'ArCu HiPSTER 20A'
            r1 = 6e-3;
            r2 = 20e-3;
            z1 = 2e-3;
            z2 = 28e-3;
        case 'ArCu Sinex2 27Pa'
            r1 = 12e-3;
            r2 = 57e-3;
            z1 = 2e-3;
            %z2 = 50e-3;
            z2 = 33e-3;
        case 'ArCu Sinex2 04Pa'
            r1 = 12e-3;
            r2 = 57e-3;
            z1 = 2e-3;
            %z2 = 80e-3;
            z2 = 33e-3;
        case 'ArCu Sinex1'
            r1 = 12e-3;
            %r2 = 40e-3;
            r2 = 57e-3;
            z1 = 2e-3;
            %z2 = 80e-3;
            z2 = 33e-3;
        otherwise
            if any(strcmp(discharge, other_disch))
                r1 = 12e-3;
                r2 = 57e-3;
                z1 = 2e-3;
                if contains(discharge,'2.7Pa')
                    %z2 = 50e-3;
                    z2 = 33e-3;
                elseif contains(discharge,'0.5Pa') || contains(discharge,'0.4Pa')
                    %z2 = 80e-3;
                    z2 = 33e-3;
                else
                    z2 = 28e-3;
                end
            else
            % FIXME MERGE: make this the same for all discharges or let it be chosen outside
            % of the source file (manually setting different paramters in a function
            % body is not clean and a great way to introduce mistakes)
            % ===================
            % > Cu HiPSTER
            warning("Using default values for IRM dimenions.")
            r1 = 6e-3 ; r2 = 20e-3 ; z1 = 2e-3 ; z2 = 28e-3; %%% system size
            % -------------------
            % > Cu Sinex1
            %r1 = 12e-3 ; r2 = 40e-3 ; z1 = 2e-3 ; z2 = 80e-3; %%% system size
            % -------------------
            % > Cu Sinex2 4Pa
            %r1 = 12e-3 ; r2 = 57e-3 ; z1 = 2e-3 ; z2 = 80e-3; %%% system size
            % -------------------
            % > Cu Sinex2 27Pa
            %r1 = 12e-3 ; r2 = 57e-3 ; z1 = 2e-3 ; z2 = 50e-3; %%% system size
            % ===================
            end
    end
else
    warning("Please supply a the discharge argument. Defaulting to Cu HiPSTER.");
    %r1 = 7e-3 ; r2 = 19e-3 ; z1 = 1e-3 ; z2 = 20e-3; %%% system size
    %r1 = 11e-3 ; r2 = 39e-3 ; z1 = 2e-3 ; z2 = 25e-3; %%% system size z2 was 39E-3
    %r1 = 9.5e-3 ; r2 = 15.5e-3 ; z1 = 1e-3 ; z2 = 15e-3; %%% system size

    % FIXME MERGE: make this the same for all discharges or let it be chosen outside
    % of the source file (manually setting different paramters in a function
    % body is not clean and a great way to introduce mistakes)
    % ===================
    % > Cu HiPSTER
    r1 = 6e-3 ; r2 = 20e-3 ; z1 = 2e-3 ; z2 = 28e-3; %%% system size
    % -------------------
    % > Cu Sinex1
    %r1 = 12e-3 ; r2 = 40e-3 ; z1 = 2e-3 ; z2 = 80e-3; %%% system size
    % -------------------
    % > Cu Sinex2 4Pa
    %r1 = 12e-3 ; r2 = 57e-3 ; z1 = 2e-3 ; z2 = 80e-3; %%% system size
    % -------------------
    % > Cu Sinex2 27Pa
    %r1 = 12e-3 ; r2 = 57e-3 ; z1 = 2e-3 ; z2 = 50e-3; %%% system size
    % -------------------
    % > C ?
    %%r1 = 6e-3 ; r2 = 19e-3 ; z1 = 2e-3 ; z2 = 18e-3; %20 A %40 A
    %%r1 = 6e-3 ; r2 = 19e-3 ; z1 = 2e-3 ; z2 = 13e-3; %20 A %40 A
    %r1 = 6e-3 ; r2 = 19e-3 ; z1 = 2e-3 ; z2 = 13e-3; %20 A %40 A tw %z2 =16E-3; <----------- USE THIS ONE ?!
    %%r1 = 6e-3 ; r2 = 19e-3 ; z1 = 2e-4 ; z2 = 6e-3; %%% from daniel
    %%r1 = 7e-3 ; r2 = 19e-3 ; z1 = 2e-3 ; z2 = 20e-3; %%% Test values from Martin
    % ===================
end

%% system size

L = z2-z1;
rr = r2-r1;
V_IR = pi*rr*(r2+r1)*L;
S_IR = 2*pi*(r2+r1)*(L+rr);
S_BP = pi*(r2+r1)*(2*L+rr); % area of the ionization region facing the bulk plasma
S_RT = (r2+r1)*rr*pi; % area of the ionization region facing the race track 
% clear r1 r2 z1 z2 rr
clear available_discharges

fieldnames=who;
for i=1:length(fieldnames)
    Para.(fieldnames{i})=eval(fieldnames{i}); % FIXME eval should be avoided and this just seems lazy.
end

save('Para.mat','Para') % NOTE: this means one has to be careful with deleting unused variables!!

end

function create_Para_new(r1,r2,z1,z2,l1,options)
arguments
    r1 (1,1) double {mustBeNonnegative}
    r2 (1,1) double {mustBeNonnegative, mustBeGreaterThan(r2,r1)}
    z1 (1,1) double {mustBeNonnegative}
    z2 (1,1) double {mustBeNonnegative, mustBeGreaterThan(z2,z1)}
    l1 (1,1) double {mustBeNonnegative}
    options.Path char = ''
    options.CompoundFraction (1,1) double {mustBeNonnegative} = 0
end

% Fitting parameters - these values are not used
Para.f = 0.121;
Para.r = 0.86;
Para.beta = 0.9;

% Degree of poisoned - only relevant in the reactive case
Para.deg_poi = options.CompoundFraction;

% Hot electron related stuff
Para.F_Teh = 1/2; % a parameter
Para.U_htc = 15.8 ; % energy hot2cold

%% system geometry

% NOTE : The ionizationr region (IR) is approximated as a hollow cylinder
% (a torus with rectangular crosssection)
Para.r1 = r1;
Para.r2 = r2;
Para.z1 = z1;
Para.z2 = z2;
Para.l1 = l1;

Para.L = Para.z2-z1; % height of the IR
Para.rr = r2-r1; % width of the IR
Para.V_IR = pi*Para.rr*(r2+r1)*Para.L; % volume of the IR
Para.S_IR = 2*pi*(r2+r1)*(Para.L+Para.rr); % total surface area of the IR
Para.S_BP = pi*(r2+r1)*(2*Para.L+Para.rr); % surface area of the IR facing the bulk plasma (BP)
Para.S_RT = (r2+r1)*Para.rr*pi; % surface area of the IR facing the race track (RT)

if l1 > 0
    Para.V_IR = (pi*Para.rr*(r2+r1)+2*Para.rr*Para.l1)*Para.L; % volume of the IR
    Para.S_IR = 2*pi*(r2+r1)*(Para.L+Para.rr)+4*Para.l1*(Para.L+Para.rr); % total surface area of the IR
    Para.S_BP = pi*(r2+r1)*(2*Para.L+Para.rr)+2*Para.l1*(2*Para.L+Para.rr); % surface area of the IR facing the bulk plasma (BP)
    Para.S_RT = (r2+r1)*Para.rr*pi+2*Para.rr*Para.l1; % surface area of the IR facing the race track (RT)
end

save(fullfile(options.Path,'Para.mat'),'Para')

end

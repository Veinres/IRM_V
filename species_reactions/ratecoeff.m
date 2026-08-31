

Te = 1:0.1: 12

%    Gudmundsson and Thorsteinsson PSST 16 (2007) 399
%
k3991 = 5E-15 .* exp(-12.64./Te);     %  meta
k3992 = 4E-15 .* exp(-12.42./Te);     % meta
k3993 = 1.9E-15 .* exp(-12.6./Te);    % rad
k3994 = 2.7E-16 .* exp(-12.14./Te);   % rad 

%    Lee et al. PHYSICS OF PLASMAS 13, 053502 2006
% 
klee = 2.5E-15 .* Te.^(0.74) .* exp(-11.56./Te);


%  I suggest using
%  based on L.L. Alves, ''The IST-Lisbon database on LXCat'' J. Phys. Conf. Series 2014, 565, 1
%  A. Yanguas-Gil, J. Cotrino and L.L. Alves ''An update of argon inelastic cross sections for plasma discharges'' 
% 2005 J.   Phys. D: Appl. Phys. 38 1588-1598
%
kar1P1 = 3.7452e-15 .* Te.^(0.0785) .* exp(-12.9189./Te);    % 11.828   rad
kar3P0 = 2.8603e-15 .* Te.^(-0.8572) .* exp(-14.6219./Te);   % 11.723   meta
kar3P1 = 2.9666e-15 .* Te.^(-0.2405) .* exp(-12.6478./Te);   % 11.623   rad
kar3P2 = 1.6170e-14 .* Te.^(-0.8238) .* exp(-14.1256./Te);   % 11.548   meta


figure(1)
semilogy(Te,k3991,'r--',Te,k3992,'r--',Te,k3993,'r-',Te,k3994,'r-',Te,klee,'g-.');
hold on
semilogy(Te,kar1P1,'m-',Te,kar3P0,'m--',Te,kar3P1,'m-',Te,kar3P2,'m--')


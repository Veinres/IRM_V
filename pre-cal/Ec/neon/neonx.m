function [Ecc]=neonx(T,T_min,dT,T_max)

%
%
%          A MATLAB script
%
%     A global model of argon discharge to investigate the variation of
%     plasma parameters with EEDF
%
%
%          Jon Tomas Gudmundsson,
%
%          2.  march 2000 revised for H and H2 29. November 2014
%
           
           plot_on = 0;
           plot_ona = 0;
%
%          Set constants
%
           c = 3e8;
           e= 1.6022e-19;
           epsilon =8.854e-12;
           me =9.1095e-31;
           MMH = 20.1797 * 1.6726e-27;
           MMH2 = 2 * 1.6726e-27;

x=1.0;
%x = 1:1:2;  % x = 1 Maxwell, x = 2 Druyvesteyn
 

Tel= T_min:dT:T_max;
% Tec = Tec_min:dTec:Tec_max;
% Tec_min = 0.5; % temperature min in eV
% Tec_max = 10;  % temperature max in eV
% dTec = 1e-3;

 
%
%          Rate coefficients Argon
%
%
%
%          Ionization cross section taken from
%          Straub H C, Renault P, Lindsay B G, Smith K A and
%          Stebbings R F 1995 Phys. Rev. A 52 1115
%
           load ionization
	   Eniz = ionization(:,1);
	   sigiz = ionization(:,2);	  

%
%          Elastic scattering cross section taken from
%          Hayashi M 2003 A set of electron-Ar cross sections with 25
%          excited states 
%   http://jilawww.colorado.edu/∼avp/collision data/electronneutral/hayashi.txt
% 
%
           load elastic
	   Enel = elastic(:,1);
	   sigel = elastic(:,2);

           load Ne1S2_16_848eV
	   Enex1 = Ne1S2_16_848eV(:,1);
	   sigex1 = Ne1S2_16_848eV(:,2);

           load Ne1S3_16_715eV
	   Enex2 = Ne1S3_16_715eV(:,1);
	   sigex2 = Ne1S3_16_715eV(:,2);

           load Ne1S4_16_671eV
	   Enex3 = Ne1S4_16_671eV(:,1);
	   sigex3 = Ne1S4_16_671eV(:,2);
	  
           load Ne1S5_16_61907eV
	   Enex4 = Ne1S5_16_61907eV(:,1);
	   sigex4 = Ne1S5_16_61907eV(:,2);

           load Ne2P1_18_966eV
	   Enex5 = Ne2P1_18_966eV(:,1);
	   sigex5 = Ne2P1_18_966eV(:,2) ;

           load Ne2P2_18_726eV
	   Enex6 = Ne2P2_18_726eV(:,1);
	   sigex6 = Ne2P2_18_726eV(:,2);

           load Ne2P3_18_711eV
	   Enex7 = Ne2P3_18_711eV(:,1);
	   sigex7 = Ne2P3_18_711eV(:,2);
	  
           load Ne2P4_18_704eV
	   Enex8 = Ne2P4_18_704eV(:,1);
	   sigex8 = Ne2P4_18_704eV(:,2);

           load Ne2P5_18_693eV
	   Enex9 = Ne2P5_18_693eV(:,1);
	   sigex9 = Ne2P5_18_693eV(:,2) ;

           load Ne2P6_18_637eV
	   Enex10 = Ne2P6_18_637eV(:,1);
	   sigex10 = Ne2P6_18_637eV(:,2) ;

           load Ne2P7_18_613eV
	   Enex11 = Ne2P7_18_613eV(:,1);
	   sigex11 = Ne2P7_18_613eV(:,2) ;

           load Ne2P9_18_555eV
	   Enex12 = Ne2P9_18_555eV(:,1);
	   sigex12 = Ne2P9_18_555eV(:,2) ;

           load Ne2P10_18_382eV 
	   Enex13 = Ne2P10_18_382eV(:,1);
	   sigex13 = Ne2P10_18_382eV(:,2) ;
	  
           load Ne2S2_19_779eV
	   Enex14 = Ne2S2_19_779eV(:,1);
	   sigex14 = Ne2S2_19_779eV(:,2);

           load Ne2S3_19_761eV
	   Enex15 = Ne2S3_19_761eV(:,1);
	   sigex15 = Ne2S3_19_761eV(:,2);

           load Ne2S4_19_688eV
	   Enex16 = Ne2S4_19_688eV(:,1);
	   sigex16 = Ne2S4_19_688eV(:,2);

           load Ne2S5_19_664eV
	   Enex17 = Ne2S5_19_664eV(:,1);
	   sigex17 = Ne2S5_19_664eV(:,2);
	  
         

 
%
%          Rate coefficients argon
%
%

           for ii=1:1:max(size(Tel))
                         Kel(ii)=ratex(Enel,Tel(ii),sigel,x);
			 Kiz(ii)=ratex(Eniz, Tel(ii),sigiz,x);
			 Kex1(ii)=ratex(Enex1, Tel(ii),sigex1,x);
                         Kex2(ii)=ratex(Enex2, Tel(ii),sigex2,x);
	                 Kex3(ii)=ratex(Enex3, Tel(ii),sigex3,x);
                         Kex4(ii)=ratex(Enex4, Tel(ii),sigex4,x);
                         Kex5(ii)=ratex(Enex5, Tel(ii),sigex5,x);
                         Kex6(ii)=ratex(Enex6, Tel(ii),sigex6,x);
	                 Kex7(ii)=ratex(Enex7, Tel(ii),sigex7,x);
                         Kex8(ii)=ratex(Enex8, Tel(ii),sigex8,x);
                         Kex9(ii)=ratex(Enex9, Tel(ii),sigex9,x);
                         Kex10(ii)=ratex(Enex10, Tel(ii),sigex10,x);
                         Kex11(ii)=ratex(Enex11, Tel(ii),sigex11,x);
                         Kex12(ii)=ratex(Enex12, Tel(ii),sigex12,x);
	                 Kex13(ii)=ratex(Enex13, Tel(ii),sigex13,x);
                         Kex14(ii)=ratex(Enex14, Tel(ii),sigex14,x);
                         Kex15(ii)=ratex(Enex15, Tel(ii),sigex15,x);
                         Kex16(ii)=ratex(Enex16, Tel(ii),sigex16,x);
	                 Kex17(ii)=ratex(Enex17, Tel(ii),sigex17,x);
                       
           end


	   EcAr = 21.56  + Kel .* Kiz.^(-1) .* 3 * me/MMH .* Tel + (16.848 *  Kex1 + 16.715 * Kex2 +  16.671 * Kex3 +  16.61907 * Kex4 +  18.966* Kex5 + 18.726 * Kex6 + 18.711 * Kex7 + 18.704 * Kex8 + 18.693 * Kex9 + 18.637 * Kex10 + 18.613 * Kex11 + 18.555 * Kex12 +  18.382* Kex13 + 19.779 * Kex14 + 19.761* Kex15 + 19.688 * Kex16 +  19.664* Kex17 ) .*  Kiz.^(-1);



% f=polyfit(log(Tel(:)),log(EcAr(:)),4); % -0.0050    0.1161   -1.0453    4.5688   -9.8266   11.7964 hot
                                       % -0.1180    0.8305   -4.1073 12.4315  -18.2398   14.1833 cold
f=polyfit((Tel(:)),(EcAr(:)),1);
disp(f);

figure(1)
plot(Tel,EcAr,'-')
% hold on
% plot(Tel,polyval([-22.9735  226.3209],Tel),':','LineWidth',3)

xlabel('$\mathrm{T}_\mathrm{e}  [\mathrm{V}]$','Interpreter','latex')
ylabel('$\mathcal{E}_\mathrm{c}  [\mathrm{V}]$','Interpreter','latex')
legend('Ne','fit')
% axis([ 0.7 101 10 100000])
FormatFig;

% fid = fopen('TelEc','w');
% for ii = 1:+1:(max(size(Tel))),
%      fprintf(fid,' %12.8f  %12.8f\n',Tel(ii),EcAr(ii));
% end
save TelEc.mat Tel EcAr
Ecc=EcAr;
end


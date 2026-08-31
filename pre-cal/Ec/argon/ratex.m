function [K]=ratex(Energy, Tel,sig,x);


%          Set constants

           c = 3e8;
           e= 1.6022e-19;
           epsilon =8.854e-12;
           me =9.1095e-31;  

	   nefnull = (2 * e .* Energy /me).^(1/2) .* sig;
	   xi1 = 3 ./ ( 2 .* x);
	   xi2 = 5 ./ (2 .* x);
	   Em = 1.5 * Tel;
	   c1 = Em.^(-3/2) * (gamma(xi2))^(3/2) ./ (gamma(xi1))^(5/2) * x;
	   c2 = Em^(-x) * (gamma(xi1))^(-x) ./ (gamma(xi2))^(-x);
      
           q0 = nefnull .* Energy.^0.5 .* c1 .* exp(-c2 .* Energy.^x);
           qq=0;qqq=0;
           for ii=1:1:max(size(Energy))-1
                         qq = (q0(ii) + q0(ii+1)) .* (Energy(ii+1) - Energy(ii))/2;
                         qqq = qq + qqq;
           end
           K =  qqq;



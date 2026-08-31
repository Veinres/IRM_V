function [Ecc] = sixx(T, T_min, dT, T_max)

    load TelEcSi_half
    Tel = TelEcSi_half(:,1);
    EcSi = TelEcSi_half(:,2);

    T_range = T_min:dT:T_max;
    Ecc = interp1(Tel, EcSi, T_range);

end
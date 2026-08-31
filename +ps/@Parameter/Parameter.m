classdef Parameter < uint32
    enumeration
        beta  (1)   % back-attraction probability [0,1] [-]
        f     (2)   % IR potential drop fraction [0,1] [-]
        r     (3)   % recapture probability [0,1] [-]
        idi   (4)   % working gas initial degree of ionization ]0,1[ [-]
        z2    (5)   % IR vertical extent ]0,infty[ [mm]
        p     (6)   % process pressure [Pa]
    end
end


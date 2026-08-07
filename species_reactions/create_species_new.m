function create_species_new(Refill_gases,Target)
% example: create_species_new("Ar","Mo")  create_species_new({'Ar'},{'Al'})
% create_species_new( ["Ar", "Ne"],"C")
PSpecies=[Refill_gases,Target];
% All info of  species is here, add species and select your species group to output to a structure. 
% masses
mAr = 6.334e-26;
mNe = 3.3509e-26;
mHe = 6.404e-27;
me  = 9.109e-31;
mTi = 7.948e-26;
mN  = 2.325e-26;
mC  = 1.9944235e-26;
mW  = 3.0527348e-25;
mCu = 1.0552061e-25;
mCr = 8.6341548e-26;
mMo = 1.6048807E-25;
mZr = 1.51481e-25;
mAl = 4.4803831e-26;
mSi = 4.6637066e-26


% temperatures
Tg  = 0.0431;
Tgi = 1;
Tm  = 8.15;
Tmi = 2;
TArW = 0.1;
TArH = 2;
TNeW = 0.1 ;
TNeH = 2 ;
TW = 13.35;
TCu = 5.235;
TCr = 4.10*3/2;
TC = 11.055;
TCi = 11.055;
TMo = 6.82*3/2;
TZr = 9.375;
TAl = 5.085;  %3.39 cohesive energy eV/atom *3/2
TSi = 4.63*3/2

% others
fdnames={'PSpecies','Names','List','M','Q','T','state','Energy','B','ID'};
% There is a list of species below, but they are only included in the end
% if they are part of PSpecies

%spe_prelist{i}= {'Parent Species','Name'  ,'List'          ,mass , q, Temp,  ,state, Energy,beta,ID}

if ismember('He', Refill_gases) && strcmp('Mo', Target)
spe_prelist{1}     = {'e'     ,'e'     ,'e'             ,me   , -1, Tg,   'e'   , 0 , 0  ,  1E20}; % NOTE : @Zakaria why this high value ? Doesn't matter anyway since it will be set by quasi-neutrality /joel
spe_prelist{end+1} = {'e'     ,'eh'    ,'e$^h$'         ,me   , -1, Tg,   'e'   , 0 , 0  ,  1E7}; % TODO : @joel implement better way to modify this
else
spe_prelist{1}     = {'e'     ,'e'     ,'e'             ,me   , -1, Tg,   'e'   , 0 , 0  ,  1e17};
spe_prelist{end+1} = {'e'     ,'eh'    ,'e$^h$'         ,me   , -1, Tg,   'e'   , 0 , 0  ,  1e3};
end

% old Ar^met level, now replaced by two levels
% spe_prelist{end+1} = {'Ar'    ,'Arm'   ,'Ar$^m$', mAr, 0, Tg, 'exm', 11.56, 0,  0};
% Ar metastable were corrected later to those from L.L. Alves, ''The IST-Lisbon database on LXCat'' J. Phys. Conf. Series 2014, 565, 1
%  A. Yanguas-Gil, J. Cotrino and L.L. Alves ''An update of argon inelastic cross sections for plasma discharges'' 
% 2005 J.   Phys. D: Appl. Phys. 38 1588-1598
spe_prelist{end+1} = {'Ar'    ,'Ar'    ,'Ar(3p$^6$)'    ,mAr  , 0 , Tg,   'grd' , 0, 0  ,  1.449E20};
spe_prelist{end+1} = {'Ar'    ,'Arm3P0'   ,'Ar(4s[3/2]$_0$)'     ,mAr  , 0 , Tg,    'exm' , 11.723, 0  ,  0};
spe_prelist{end+1} = {'Ar'    ,'Arm3P2'   ,'Ar(4s[3/2]$_2$)'     ,mAr  , 0 , Tg,    'exm' , 11.548, 0  ,  0};
spe_prelist{end+1} = {'Ar'    ,'Ari'   ,'Ar$^+$'        ,mAr  , +1, Tgi,   'ion' , 15.75962, 0.9,  1e17};
spe_prelist{end+1} = {'Ar'    ,'Arii'  ,'Ar$^{2+}$'    ,mAr  , +2, Tgi,   'ion' ,27.63 , 0.9,  0};
spe_prelist{end+1} = {'Ar'    ,'ArW'   ,'Ar$^W$(3p$^6$)'        ,mAr  , 0 , TArW,  'thr' , 0, 0  ,  0  };
spe_prelist{end+1} = {'Ar'    ,'ArH'   ,'Ar$^H$(3p$^6$)'        ,mAr  , 0 , TArH,  'thr' , 0, 0  ,  0  };

spe_prelist{end+1} = {'Ne'    ,'Ne'    ,'Ne(2p$^6$)'             ,mNe  , 0 , Tg,   'grd' , 0, 0  ,  1.449E20};
spe_prelist{end+1} = {'Ne'    ,'Nem2P0'   ,'Ne(3s[3/2]$_0$)'     ,  mNe , 0 , Tg,    'exm' , 16.71 , 0  ,  0};
spe_prelist{end+1} = {'Ne'    ,'Nem2P2'   ,'Ne(3s[3/2]$_2$)'     ,mNe  , 0 , Tg,    'exm' , 16.62 , 0  ,  0};
spe_prelist{end+1} = {'Ne'    ,'Nei'   ,'Ne$^+$'                 ,mNe  , +1, Tgi,   'ion' ,  21.56, 0.9,  1e17};
spe_prelist{end+1} = {'Ne'    ,'Neii'  ,'Ne$^{2+}$'              ,mNe  , +2, Tgi,   'ion' , 40.96, 0.9,  0};
spe_prelist{end+1} = {'Ne'    ,'NeW'   ,'Ne$^W$(3p$^6$)'         ,mNe  , 0 , TNeW,  'thr' , 0, 0  ,  0  };
spe_prelist{end+1} = {'Ne'    ,'NeH'   ,'Ne$^H$(3p$^6$)'         ,mNe  , 0 , TNeH,  'thr' , 0, 0  ,  0  };

spe_prelist{end+1} = {'Ti'    ,'Ti'    ,'Ti'            ,mTi  , 0 , Tm,    'grd' , 0, 0  ,  1e12};
spe_prelist{end+1} = {'Ti'    ,'Tii'   ,'Ti$^+$'        ,mTi  , +1, Tm,    'ion' , 6.8281, 0.9,  1e3};
spe_prelist{end+1} = {'Ti'    ,'Tiii'  ,'Ti$^{2+}$'     ,mTi  , +2, Tm,    'ion' , 13.5755, 0.9,  1e1};

spe_prelist{end+1} = {'N2'    ,'N2'    ,'N$_2$'         ,2*mN , 0 , Tg,    'grd' , 0, 0  ,  1e16};
spe_prelist{end+1} = {'N2'    ,'N2v1'  ,'N$_2(X,v=1)$'  ,2*mN , 0 , Tg,    'vib' , 0, 0  ,  0};
spe_prelist{end+1} = {'N2'    ,'N2v2'  ,'N$_2(X,v=2)$'  ,2*mN , 0 , Tg,    'vib' , 0, 0  ,  0};
spe_prelist{end+1} = {'N2'    ,'N2v3'  ,'N$_2(X,v=3)$'  ,2*mN , 0 , Tg,    'vib' , 0, 0  ,  0};
spe_prelist{end+1} = {'N2'    ,'N2v4'  ,'N$_2(X,v=4)$'  ,2*mN , 0 , Tg,    'vib' , 0, 0  ,  0};
spe_prelist{end+1} = {'N2'    ,'N2v5'  ,'N$_2(X,v=5)$'  ,2*mN , 0 , Tg,    'vib' , 0, 0  ,  0};
spe_prelist{end+1} = {'N2'    ,'N2v6'  ,'N$_2(X,v=6)$'  ,2*mN , 0 , Tg,    'vib' , 0, 0  ,  0};
spe_prelist{end+1} = {'N2'    ,'N2A'   ,'N$_2(A)$'      ,2*mN , 0 , Tg,    'exm' , 0, 0  ,  0};
spe_prelist{end+1} = {'N2'    ,'NS'    ,'N(S)'          ,mN   , 0 , Tg,    'grd' , 0, 0  ,  1e3};
spe_prelist{end+1} = {'N2'    ,'ND'    ,'N(D)'          ,mN   , 0 , Tg,    'exm' , 0, 0  ,  0};
spe_prelist{end+1} = {'N2'    ,'NP'    ,'N(P)'          ,mN   , 0 , Tg,    'exm' , 0, 0  ,  0};
spe_prelist{end+1} = {'N2'    ,'Ni'    ,'N$^+$'         ,mN   ,+1 , Tgi,   'ion' , 14.53414, 0.9,  1e3};
spe_prelist{end+1} = {'N2'    ,'N2i'   ,'N$_2^+$'       ,2*mN ,+2 , Tgi,   'ion' , 29.6013, 0.9,  1e15};
spe_prelist{end+1} = {'N2'    ,'N3i'   ,'N$_3^+$'       ,3*mN ,+3 , Tgi,   'ion' , 47.44924, 0.9,  0};
spe_prelist{end+1} = {'N2'    ,'N4i'   ,'N$_4^+$'       ,4*mN ,+4 , Tgi,   'ion' , 77.4735, 0.9,  0};

spe_prelist{end+1} = {'C'     ,'C'     ,'C'             ,mC   , 0  , TC,   'grd' , 0, 0,  1E12};
spe_prelist{end+1} = {'C'     ,'Cm1'   ,'C$^m_1$'      ,mC   , 0  , Tg,    'exm' ,1.2601, 0,  0};
spe_prelist{end+1} = {'C'     ,'Cm2'   ,'C$^m_2$'      ,mC   , 0  , Tg,    'exm' ,2.68034 , 0,  0};
spe_prelist{end+1} = {'C'     ,'Cm3'   ,'C$^m_3$'      ,mC   , 0  , Tg,    'exm' , 4.17896, 0,  0};
spe_prelist{end+1} = {'C'     ,'Ci'    ,'C$^+$'         ,mC   , +1  , TCi, 'exm' , 11.26030, 0.9,  1E3};
spe_prelist{end+1} = {'C'     ,'Cii'    ,'C$^{2+}$'         ,mC   , +2  , Tgi, 'exm' , 24.38, 0.9,  1E1};

spe_prelist{end+1} = {'W'     ,'W'    ,'W'            ,mW  , 0 , TW,    'grd' , 0, 0  ,  1e12};
spe_prelist{end+1} = {'W'     ,'Wi'   ,'W$^+$'        ,mW  , +1, TW,    'ion' , 7.8640, 0.9,  1e3};
spe_prelist{end+1} = {'W'     ,'Wii'  ,'W$^{2+}$'     ,mW  , +2, TW,    'ion' , 16.100, 0.9,  1e1};

spe_prelist{end+1} = {'Cu'    ,'Cu'    ,'Cu(3d$^{10}$4s $^2$S$_{1/2}$)'         ,mCu   , 0  , TCu, 'grd' , 0, 0,  1e13};
spe_prelist{end+1} = {'Cu'     ,'Cum1'    ,'Cu(3d$^{9}$4s$^2$ $^2$D$_{5/2}$)'         ,mCu   , 0  , TCu, 'exm' , 1.39, 0,  0};
spe_prelist{end+1} = {'Cu'     ,'Cum2'    ,'Cu(3d$^{9}$4s$^2$ $^2$D$_{3/2}$)'         ,mCu   , 0  , TCu, 'exm' , 1.64, 0,  0};
spe_prelist{end+1} = {'Cu'    ,'Cum3'    ,'Cu(3d$^{10}$4p $^2$P$_{1/2,3/2}$)'         ,mCu   , 0  , TCu, 'exm' , 3.79, 0,  0};
spe_prelist{end+1} = {'Cu'    ,'Cui'    ,'Cu$^+$'         ,mCu   , +1  , TCu, 'ion' , 7.73, 0.9,  1e3};
spe_prelist{end+1} = {'Cu'    ,'Cuii'    ,'Cu$^{2+}$'         ,mCu   , +2  , TCu, 'ion' , 20.29, 0.9,  1e1};

spe_prelist{end+1} = {'Cr'    ,'Cr'    ,'Cr'         ,mCr  ,            0  ,    TCr, 'grd' ,    0,      0,  1e12};
spe_prelist{end+1} = {'Cr'    ,'Cri'    ,'Cr$^+$'         ,mCr   ,      +1  , TCr, 'ion' ,      6.7665, 0.9,  1e3};
spe_prelist{end+1} = {'Cr'    ,'Crii'    ,'Cr$^{2+}$'         ,mCr   ,  +2  , TCr, 'ion' ,      16.4857, 0.9,  1e1};

spe_prelist{end+1} = {'Mo'    ,'Mo'    ,'Mo(GS)'         ,mMo   , 0  , TMo, 'grd' , 0, 0,  1e12};
spe_prelist{end+1} = {'Mo'    ,'Moi'    ,'Mo$^+$'         ,mMo   , +1  , TMo, 'ion' , 7.0924, 0.9,  1e3};
spe_prelist{end+1} = {'Mo'    ,'Moii'    ,'Mo$^{2+}$'         ,mMo   , +2  , TMo, 'ion' , 16.16, 0.9,  1e1};

spe_prelist{end+1} = {'Zr'    ,'Zr'    ,'Zr'            ,mZr  , 0 , TZr,    'grd' , 0, 0  ,  1e12};% try Mo
spe_prelist{end+1} = {'Zr'    ,'Zri'   ,'Zr$^+$'        ,mZr  , +1, TZr,    'ion' , 6.6341, 0.9,  1e3};
spe_prelist{end+1} = {'Zr'    ,'Zrii'  ,'Zr$^{2+}$'     ,mZr  , +2, TZr,    'ion' , 13.13, 0.9,  1e1};

spe_prelist{end+1} = {'Si'    ,'Si'    ,'Si'            ,mSi  , 0 , TSi,    'grd' , 0, 0  ,  1e12};
spe_prelist{end+1} = {'Si'    ,'Sii'   ,'Si$^+$'        ,mSi  , +1, TSi,    'ion' , 8.15168, 0.9,  1e3};
spe_prelist{end+1} = {'Si'    ,'Siii'  ,'Si$^{2+}$'     ,mSi  , +2, TSi,    'ion' , 16.34584 , 0.9,  1e1};

spe_prelist{end+1} = {'Al'     ,'Al'    ,'Al'            ,mAl  , 0 , TAl,    'grd' , 0, 0  ,  1e12};
spe_prelist{end+1} = {'Al'     ,'Ali'   ,'Al$^+$'        ,mAl  , +1, TAl,    'ion' , 5.98577, 0.9,  1e3};
spe_prelist{end+1} = {'Al'     ,'Alii'  ,'Al$^{2+}$'     ,mAl  , +2, TAl,    'ion' , 18.82856, 0.9,  1e1};

spe_prelist{end+1} = {'He'    ,'He'    ,'He(1s$^0$)'    ,mHe  , 0 , Tg,   'grd' , 0, 0  ,  1.449E20};

spe_prelist{end+1} = {'He'    ,'Hem2S1'   ,'He(2s$_1$)'     ,mHe  , 0 , Tg,    'exm' , 19.82, 0  ,  0};
spe_prelist{end+1} = {'He'    ,'Hem2S0'   ,'He(2s$_0$)'     ,mHe  , 0 , Tg,    'exm' , 20.62, 0  ,  0};
spe_prelist{end+1} = {'He'    ,'He2P012'  ,'He(2p$_{0,1,2}$)'     ,mHe  , 0 , Tg,    'exm' , 20.92, 0  ,  0};
spe_prelist{end+1} = {'He'    ,'He2P1'    ,'He(2p$_1$)'     ,mHe  , 0 , Tg,    'exm' , 21.07, 0  ,  0};
spe_prelist{end+1} = {'He'    ,'Hei'   ,'He$^+$'        ,mHe  , +1, Tgi,   'ion' , 24.58, 0.9,  1e16};
spe_prelist{end+1} = {'He'    ,'HeW'   ,'He$^W$(1s$^0$)'        ,mHe  , 0 , TArW,  'thr' , 0, 0  ,  0  };
spe_prelist{end+1} = {'He'    ,'HeH'   ,'He$^H$(1s$^0$)'        ,mHe  , 0 , TArH,  'thr' , 0, 0  ,  0  };

spe{1}=spe_prelist{1}; %normal (cold) electrons are always included
spe{end+1} = spe_prelist{2}; 
for i=1:length(spe_prelist)
    if ismember(char(spe_prelist{1,i}{1,1}),PSpecies)
        spe{end+1}=spe_prelist{1,i};        
    end
end
PSpecies=['e',PSpecies];
% select species and create the species structure
% for ArTi

create_Spe_new(spe,fdnames,Refill_gases,Target);
end

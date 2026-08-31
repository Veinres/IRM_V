% Si self-sputter, singly charged (Si+ → Si)
%M = readmatrix('vienna_SiSi.csv');
%writematrix(M, 'Si_Sii.m', 'FileType', 'text');

% Si self-sputter, doubly charged (Si2+ → Si)
%M = readmatrix('vienna_SiSi2+.csv');
%writematrix(M, 'Si_Siii.m', 'FileType', 'text');

% Ar+ sputtering Si (Ar+ → Si)
M = readmatrix('Si_Ar.csv');
writematrix(M, 'Si_Ar.m', 'FileType', 'text');
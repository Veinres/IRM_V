function change_ArCu_seed_density(sd)

load(fullfile('species_reactions','Spe_ArCu.mat'));
Spe.ID(1) = sd;
Spe.ID(6) = sd;
clear sd;
save(fullfile('species_reactions','Spe_ArCu.mat'),'Spe');
clear variables;
load(fullfile('species_reactions','Spe_ArCu.mat'));
disp(Spe.Names{1});
disp(Spe.ID(1));
disp(Spe.Names{6});
disp(Spe.ID(6));

end
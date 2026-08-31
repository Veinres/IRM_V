function run_precal(suffix)
%RUN_PRECAL calculate and gather all the precalculated matrices
%==========================================================================
% This is just a temporary function.
% TODO: include in create_Precal.m
% TODO: clean up
%==========================================================================

names = {'ArTi','ArCu','ArC','ArW','ArMo','ArAl','ArW','ArZr','HeMo'}; % ,'ArTiN'

types = {'Ec','Yield','gamma'};
folders = {'Ec','Sputter_yield','Secondary_e_yield'};

for name_cell=names
    
    name = name_cell{1};
    Spe = load(fullfile('..','species_reactions',strcat('Spe_',name,'.mat'))).Spe;

    for i=1:3
        type = types{i};
        folder = folders{i};
        cd(folder);
        switch i
            case 1 % Ec
                create_Ec(Spe, strcat(type,'_',name,suffix,'.mat'), true);
                Precal.Ec = load(strcat(type,'_',name,suffix,'.mat')).Ec;
            case 2 % Yield
                create_Yield(Spe, strcat(type,'_',name,suffix,'.mat'), true);
                Precal.Yield = load(strcat(type,'_',name,suffix,'.mat')).Yield;
            case 3 % Gamma
                create_Gamma(Spe, strcat(type,'_',name,suffix,'.mat'), true);
                Precal.gamma = load(strcat(type,'_',name,suffix,'.mat')).gamma;
        end
        cd('..');
    end
end

save(strcat('Precal','_',name,suffix,'.mat'),'Precal');

end
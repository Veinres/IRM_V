%% set up species combinations
combs = cell([]);
combs{end+1} = {{'Ar'},{'Ti'}};
combs{end+1} = {{'N2'},{'Ti'}};
combs{end+1} = {{'Ar','N2'},{'Ti'}};

%% create pre-cal for each combination

for i_comb = 1:length(combs)
    name = strcat(strcat(combs{i_comb}{1}{:}), combs{i_comb}{2}{:});
    [loc, spe] = material.species(combs{i_comb}{1},combs{i_comb}{2}, ...
        'Filename', fullfile('species_reactions', strcat('Spe_', name)));
    fprintf('Created %s struct for %s at %s\n', 'Spe', name, loc);
    [loc, rea] = material.reactions(spe, ...
        'Filename', fullfile('species_reactions', strcat('Rea_', name)));
    fprintf('Created %s struct for %s at %s\n', 'Rea', name, loc);

    cd pre-cal/Ec/
    loc_Ec = create_Ec(spe, strcat('Ec_', name));
    fprintf('Created %s struct for %s at %s\n', 'Ec', name, loc_Ec);
    cd ../Sputter_yield
    loc_Yield = create_Yield(spe, strcat('Yield_', name));
    fprintf('Created %s struct for %s at %s\n', 'Yield', name, loc_Yield);
    cd ../Secondary_e_yield
    loc_gamma = create_Gamma(spe, strcat('gamma_', name));
    fprintf('Created %s struct for %s at %s\n', 'gamma', name, loc_gamma);
    cd ../..

    Precal.Ec = load(loc_Ec).Ec;
    Precal.Yield = load(loc_Yield).Yield;
    Precal.gamma = load(loc_gamma).gamma;
    save(fullfile('pre-cal', strcat('Precal_',name)), 'Precal')
    fprintf('Created %s struct for %s at %s\n', 'Precal', name, fullfile('pre-cal', strcat('Precal_',name)));
end

%% clean up

clear i_comb combs name loc spe rea loc_Ec loc_Yield loc_gamma Precal; 

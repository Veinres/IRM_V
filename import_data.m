function [Spe, Rea, Precal, disch, Para] = import_data(path_to_disch_mat,disch_mat,type)
% NOTE: this is only a temporary fix and should be replaced at some point
% TODO: replace
switch lower(type)
    case 'arti'
        fn_species   = 'Spe_ArTi';       % species structure: all species' info (ex: charge, mass..)
        fn_reactions = 'Rea_ArTi';       % reaction structure: chemistry reaction set and other vectors.
        fn_precal    = 'Precal_ArTi';    % pre-calculated matrices (ex: Ec, Sput, rates)
    case 'arw'
        fn_species   = 'Spe_ArW';       % species structure: all species' info (ex: charge, mass..)
        fn_reactions = 'Rea_ArW';       % reaction structure: chemistry reaction set and other vectors.
        fn_precal    = 'Precal_ArW';    % pre-calculated matrices (ex: Ec, Sput, rates)
    case 'arnec'
        fn_species   = 'Spe_ArNeC';       % species structure: all species' info (ex: charge, mass..)
        fn_reactions = 'Rea_ArNeC';       % reaction structure: chemistry reaction set and other vectors.
        fn_precal    = 'Precal_ArNeC';    % pre-calculated matrices (ex: Ec, Sput, rates)
    case 'arcu'
        fn_species   = 'Spe_ArCu';      % species structure: all species' info (ex: charge, mass..)
        fn_reactions = 'Rea_ArCu';      % reaction structure: chemistry reaction set and other vectors.
        fn_precal    = 'Precal_ArCu';   % pre-calculated matrices (ex: Ec, Sput, rates)
    case 'arc' 
        fn_species   = 'Spe_ArC';       % species structure: all species' info (ex: charge, mass..)
        fn_reactions = 'Rea_ArC';       % reaction structure: chemistry reaction set and other vectors.
        fn_precal    = 'Precal_ArC';    % pre-calculated matrices (ex: Ec, Sput, rates)
    case 'aral'
        fn_species   = 'Spe_ArAl';       % species structure: all species' info (ex: charge, mass..)
        fn_reactions = 'Rea_ArAl';       % reaction structure: chemistry reaction set and other vectors.
        fn_precal    = 'Precal_ArAl';    % pre-calculated matrices (ex: Ec, Sput, rates)
    case 'arzr'
        fn_species   = 'Spe_ArZr';       % species structure: all species' info (ex: charge, mass..)
        fn_reactions = 'Rea_ArZr';       % reaction structure: chemistry reaction set and other vectors.
        fn_precal    = 'Precal_ArZr';    % pre-calculated matrices (ex: Ec, Sput, rates)
    case 'arcr'
        fn_species   = 'Spe_ArCr';       % species structure: all species' info (ex: charge, mass..)
        fn_reactions = 'Rea_ArCr';       % reaction structure: chemistry reaction set and other vectors.
        fn_precal    = 'Precal_ArCr';    % pre-calculated matrices (ex: Ec, Sput, rates)
    case 'n2ti'
        fn_species   = 'Spe_N2Ti';    % species structure: all species' info (ex: charge, mass..)
        fn_reactions = 'Rea_N2Ti';    % reaction structure: chemistry reaction set and other vectors.
        fn_precal    = 'Precal_N2Ti'; % pre-calculated matrices (ex: Ec, Sput, rates)
    case 'arn2ti'
        fn_species   = 'Spe_ArN2Ti';    % species structure: all species' info (ex: charge, mass..)
        fn_reactions = 'Rea_ArN2Ti';    % reaction structure: chemistry reaction set and other vectors.
        fn_precal    = 'Precal_ArN2Ti'; % pre-calculated matrices (ex: Ec, Sput, rates)
    case 'armo'
        fn_species   = 'Spe_ArMo';       % species structure: all species' info (ex: charge, mass..)
        fn_reactions = 'Rea_ArMo';       % reaction structure: chemistry reaction set and other vectors.
        fn_precal    = 'Precal_ArMo';    % pre-calculated matrices (ex: Ec, Sput, rates)
    case 'hemo'
        fn_species   = 'Spe_HeMo';       % species structure: all species' info (ex: charge, mass..)
        fn_reactions = 'Rea_HeMo';       % reaction structure: chemistry reaction set and other vectors.
        fn_precal    = 'Precal_HeMo';    % pre-calculated matrices (ex: Ec, Sput, rates)

    case 'arsi'
        fn_species   = 'Spe_ArSi';       % species structure: all species' info (ex: charge, mass..)
        fn_reactions = 'Rea_ArSi';       % reaction structure: chemistry reaction set and other vectors.
        fn_precal    = 'Precal_ArSi';    % pre-calculated matrices (ex: Ec, Sput, rates)
    
end
fn_discharge = fullfile(path_to_disch_mat,disch_mat);

Spe = load(fullfile('species_reactions', fn_species), 'Spe').Spe;
Rea = load(fullfile('species_reactions', fn_reactions), 'Rea').Rea;
Precal = load(fullfile('pre-cal', fn_precal), 'Precal').Precal;
disch = load(fullfile('discharge', fn_discharge), 'disch').disch;
Para = load(fullfile('parameters', 'Para'), 'Para').Para;

end

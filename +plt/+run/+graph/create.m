function [g] = create(input)
%CREATE create a directed graph representing the modelled system
% =========================================================================
% The created directed graph has one node per species plus nodes for the
% bulk plasma/diffusion reagion, race track/target, and gas supply,
% and at least one edge per reaction as well as the other terms that affect
% species densites such as sputtering, diffusion, or kickout.
%
% See also plt.run.graph.update, plt.run.graph.plot
% See also plt.run.graph.plotIntegrated
%
% ARGUMENTS ---------------------------------------------------------------
%
%   input       (struct), the input used for the simulation run
%
% RETURN ------------------------------------------------------------------
%
%   g           (digraph), the created directed graph
%
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ NOTE ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This function requires Matlab 2019b or later.
% =========================================================================

%% NOTES: -----------------------------------------------------------------
% -------------------------------------------------------------------------

%% Argument parsing and validation
arguments
    input
end

%% Nodes (species and "regions")

n_species = size(input.Spe.Names, 2);
n_nodes = n_species + 3;

variableNames = {'ID', 'Name', 'Label', 'Type', 'n', 'Ind'};
variableTypes = {'double', 'cell', 'cell', 'categorical', 'double', 'double'};
Nodes = table('Size', [n_nodes,length(variableNames)], ...
    'VariableNames', variableNames, 'VariableTypes', variableTypes);

% species
Nodes.ID(1:n_species) = 1:n_species;
Nodes.Name(1:n_species) = input.Names;
Nodes.Label(1:n_species) = input.List;
Nodes.Type(1:n_species) = repmat({'species'}, [1,n_species]);
Nodes.Ind(1:n_species) = 1:n_species;

% regions
Nodes.ID(n_species+1:end) = [-1,-2,-2];
Nodes.Name(n_species+1:end) = {'RT', 'BP', 'GS'};
Nodes.Label(n_species+1:end) = {'race track', 'bulk plasma', 'gas supply'};
Nodes.Type(n_species+1:end) = {'region', 'region', 'region'};

%% Edges (reactions, diffusion, sputtering and kickout)

variableNames = {'EndNodes','ID', 'Name', 'Label', 'Type', 'R', 'Weight', 'Ind'};
variableTypes = {'cell', 'double', 'cell', 'cell', 'categorical', 'double', 'double', 'double'};
Edges = table('Size', [1,length(variableNames)], ...
    'VariableNames', variableNames, 'VariableTypes', variableTypes);

% reactions
i_e = 1;
warning('off','MATLAB:table:RowsAddedExistingVars');
for i_r = 1:length(input.Rea.reactions)
    % The links are built in the following way:
    % 1. remove all electrons from both the rhs and the lhs (we don't care
    % about them here, since they don't get generatead / lost though
    % reactions in code)
    % 2. If the species struc contains composition information, 
    %   a) use that composition information to match species on the lhs
    %   with those on the rhs and create directed edges accordingly
    % else,
    %   b) use the parent species information to group species on the lhs
    %   and rhs and then for each group create directed links from
    %   each contained species to each species in the corresponding group
    %   on the rhs
    
    lhs = input.Rea.reactions(i_r).React;
    rhs = input.Rea.reactions(i_r).Prod;
    reastr = material.util.reactions.equationReps(lhs, rhs, input.Spe, ...
        "Reduce", true, "Style", "latex");

    % 1. remove electrons
    lhs = lhs(~ismember(lhs, {'e','eh'}));
    rhs = rhs(~ismember(rhs, {'e','eh'}));

    % 2. match species
    % NOTE : currently, this disregards composition and defaults to 2 b) % FIXME
    lhs_parents = cellfun(@(spe) input.Spe.PSpecies{input.Spe.s.(spe)}, ...
        lhs, 'UniformOutput', false);
    rhs_parents = cellfun(@(spe) input.Spe.PSpecies{input.Spe.s.(spe)}, ...
        rhs, 'UniformOutput', false);

    for i_s = 1:length(lhs)
        matches = rhs(strcmp(rhs_parents, lhs_parents{i_s}));
        for i_t = 1:length(matches)
            Edges.ID(i_e) = i_r;
            Edges.Name{i_e} = input.Rea.reactions(i_r).tag;
            Edges.Label{i_e} = reastr;
            Edges.Type(i_e) = input.Rea.reactions(i_r).type;
            Edges.EndNodes(i_e,1:2) = {lhs{i_s}, matches{i_t}};
            Edges.Ind(i_e) = i_r;
            i_e = i_e + 1;
        end
    end
end

% ions
ions = input.Range.ion;
for i_s = 1:length(ions)
    ind = ions(i_s);
    name = input.Spe.Names{ind};

    Edges.ID(i_e) = -1;
    Edges.Name{i_e} = sprintf('ifRT_%s', name);
    Edges.Label{i_e} = sprintf('%s to RT', input.Spe.List{ind});
    Edges.Type(i_e) = 'ionfluxRT';
    Edges.EndNodes(i_e,1:2) = {name, 'RT'};
    Edges.Ind(i_e) = ind;
    i_e = i_e + 1;

    Edges.ID(i_e) = -2;
    Edges.Name{i_e} = sprintf('ifBP_%s', name);
    Edges.Label{i_e} = sprintf('%s to BP', input.Spe.List{ind});
    Edges.Type(i_e) = 'ionfluxBP';
    Edges.EndNodes(i_e,1:2) = {name, 'BP'};
    Edges.Ind(i_e) = ind;
    i_e = i_e + 1;
end

% diffusion
neutrals = 1:n_species;
neutrals = neutrals(input.Spe.Q == 0);
for i_s = 1:length(neutrals)
    ind = neutrals(i_s);
    name = input.Spe.Names{ind};
    
    Edges.ID(i_e) = -3;
    Edges.Name{i_e} = sprintf('diff_%s', name);
    Edges.Label{i_e} = sprintf('%s diffusion', input.Spe.List{ind});
    Edges.Type(i_e) = 'diff';
    if ismember(ind, input.Range.refill)
        Edges.EndNodes(i_e,1:2) = {'GS', name};
    else
        Edges.EndNodes(i_e,1:2) = {name, 'BP'};
    end
    Edges.Ind(i_e) = ind;
    i_e = i_e + 1;
end

% sputtering
sputtered = [input.Range.sput_metal, input.Range.sput_gas];
for i_s = 1:length(sputtered)
    ind = sputtered(i_s);
    name = input.Spe.Names{ind};
    
    Edges.ID(i_e) = -4;
    Edges.Name{i_e} = sprintf('sput_%s', name);
    Edges.Label{i_e} = sprintf('%s sputtering', input.Spe.List{ind});
    Edges.Type(i_e) = 'sput';
    Edges.EndNodes(i_e,1:2) = {'RT', name};
    Edges.Ind(i_e) = ind;
    i_e = i_e + 1;
end

% kickout
kickedout = input.Range.kickout;
for i_s = 1:length(kickedout)
    ind = sputtered(i_s);
    name = input.Spe.Names{ind};
    
    Edges.ID(i_e) = -5;
    Edges.Name{i_e} = sprintf('kick_%s', name);
    Edges.Label{i_e} = sprintf('%s kickout', input.Spe.List{ind});
    Edges.Type(i_e) = 'kick';
    Edges.EndNodes(i_e,1:2) = {name, 'BP'};
    Edges.Ind(i_e) = ind;
    i_e = i_e + 1;
end
warning('on','MATLAB:table:RowsAddedExistingVars');

g = digraph(Edges, Nodes);

end

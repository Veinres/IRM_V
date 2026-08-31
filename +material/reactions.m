function [filename, output] = reactions(species, options)
%REACTIONS generate table of refill gas and target material species
% =========================================================================
% Generate a table containing relevant gas and target material reactions and
% save it to a .mat file.
%
% ARGUMENTS ---------------------------------------------------------------
%
%   species     (table/struct), species table
%                   A table containing species information as produced by
%                   the material.species function. A legacy species
%                   struct compatible with IRM v1.2 is also supported.
%
% Name-Value --------------------------------------------------------------
%
%   Output      (string, optional, default: 'legacy'), Output type
%                   Possible options are:
%                       - 'default' default output structure % FIXME
%                       - 'table'   table output
%                                   (NOTE: this is intended for easy
%                                   inspection and not for computationally
%                                   heavy tasks, as tables in matlab are
%                                   slow)
%                       - 'legacy'  legacy output structure compatible with
%                                   IRM v1.2
%
%   Filename    (string, optional), Output file path (relative to irm root
%                   directory or absolute)
%                   By default, the output is written to
%                   '+material/reactions/<gas><target>.mat' where <gas> and
%                   <target> are the element symbols of the working gas and
%                   target material respectively. For lagacy output, the
%                   prefix 'Rea_' is added to the default filename.
%
%   Padding     (logical, optional, default=false) Whether to pad variables
%                   with multiple entries to have the same number of
%                   entries for all reactions. This can be usefull together
%                   with the 'table' output format, since it makes visual
%                   inspection easier.
%
% Return ------------------------------------------------------------------
%
%   filename    (string), Output file path
%
%   output      (struct/table), generated output. Struct or table depending
%                   on output option.
%
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ NOTE ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This function requires Matlab R2020b or later.
% =========================================================================

%% NOTES: -----------------------------------------------------------------
% TODO : generate one output and create compatibility wrapper
% TODO : rework update output structure
% TODO : add additional info to table output (should be as complete as
% legacy output
% -------------------------------------------------------------------------

%% Argument parsing and validation
arguments
    % positional arguments
    species     {material.util.valid.mustBeValidSpeciesInfo}
    % optional name-value pairs
    options.Output char {mustBeMember(options.Output,{...
                                'default',...       % default output structure
                                'legacy',...        % legacy output structure
                                'table'...          % table output for visual inspection
                                })} = 'legacy' % FIXME !!!
    options.Filename {mustBeTextScalar(options.Filename)} = ''
    options.Padding logical = false
end

%% Collect species --------------------------------------------------------

[refill_gas, target_material, n_species, s, Eiz] = material.util.getSpeciesInfo(species);

%% Collect reactions ------------------------------------------------------

% gas reactions
n_gases = length(refill_gas);
refill_reactions = cell([1,n_gases]);
for i_gas = 1:n_gases
    refill_reactions{i_gas} = material.gas.(refill_gas{i_gas}).reactions();
end
% extract variable names before conversion to cell
var_names = refill_reactions{1}.Properties.VariableNames;
% convert to cell to avoid issues with concatenation
for i_gas = 1:n_gases
    refill_reactions{i_gas} = table2cell(refill_reactions{i_gas});
end
% target reactions
target_reactions{1} = table2cell(material.target.(target_material{1}).reactions());
% gas-target and  gas-gas interaction reactions
interactions = cell([1,n_gases + (n_gases*(n_gases-1))/2]);
ind = 1;
for i_gas = 1:n_gases
    interactions{ind} = table2cell(material.gas.(refill_gas{i_gas}).(target_material{1}).reactions());
    ind = ind + 1;
    for j_gas = (i_gas+1):n_gases
        interactions{ind} = table2cell(material.gas.(refill_gas{i_gas}).(refill_gas{j_gas}).reactions());
        ind = ind + 1;
    end
end
reactions = [vertcat(refill_reactions{:}); vertcat(target_reactions{:}); vertcat(interactions{:})];
n_reactions = height(reactions);

if options.Padding
    reactions = util.base.padColumns(reactions,[3,5]);
end

reactions = cell2table(reactions, 'VariableNames', var_names); % this will unnest cell arrays if possible

%% Extract additional info ------------------------------------------------

% Additional table properties
reactions.Properties.DimensionNames = {'Reactions','Variables'};
%reactions.Properties.RowNames = reactions.name;

% Table info
info.creation_date = datetime('now','Format','yyyy-MM-dd_hhmm');
info.refill = string(refill_gas);
info.target = string(target_material);
info.name = string(strcat(strcat(info.refill{:}), info.target));
reactions.Properties.Description = sprintf("Reactions for %s discharge", info.name{1});

reactions.Properties.UserData = info;

%% Export

if isempty(options.Filename)
    % default filename
    if ~exist('+material/reactions','dir')
        mkdir('+material/reactions');
    end
    if strcmp(options.Output, 'legacy')
        filename = sprintf("+material/reactions/Rea_%s", info.name);
    else
        filename = sprintf("+material/reactions/%s", info.name);
    end
else
    % costum filename
    filename = options.Filename;
end

switch options.Output
    case 'table' % fancy output for inspection
        save(filename, 'reactions');
        output = reactions;
    case 'legacy' % legacy output for compatibility
        
        % Reorder and rename variables
        % Original variable order: 'name','reactants','products','eq_type','coeffs','type','source'
        reactions = movevars(reactions,'name','After','source');
        reactions = movevars(reactions,'source','After','products');
        reactions.Properties.VariableNames = {'React','Prod','Ref','coef_type','coeffs','type','tag'};
        reactions = table2struct(reactions,'ToScalar',true);
        if size(reactions.React,2) > 1
            tmp = reactions.React;
            reactions.React = cell([n_reactions,1]);
            for i_r = 1:n_reactions
                reactions.React{i_r} = tmp(i_r,:);
            end
        end
        
        % Prepare sub-structs
        Range = struct('penning',[],...
                       'excC',[],...
                       'excH',[],...
                       'ionC',[],...
                       'ionH',[],...
                       'ehtype',[],...
                       'ectype',[],...
                       'ionparent',zeros([1,n_reactions]));
                       %'chex',[]
        
        Reactype.eH = zeros([1,n_reactions]);
        Reactype.eC = zeros([1,n_reactions]);
        
        R = zeros([n_reactions,n_species]);
        P = zeros([n_reactions,n_species]);
        
        tags = reactions.tag;
        rn = util.base.enumStruct(tags, 'Dir', 'last');
        if size(reactions.React,2) == 1 % nested cell array
            Rcell = reactions.React;
        else % unnested cell array
            Rcell = cell([n_reactions,1]);
            for i_r = 1:n_reactions
                Rcell{i_r} = reactions.React(i_r,:);
            end
        end
        if size(reactions.Prod,2) == 1 % nested cell array
            Pcell = reactions.Prod;
        else % unnested cell array
            Pcell = cell([n_reactions,1]);
            for i_r = 1:n_reactions
                Pcell{i_r} = reactions.Prod(i_r,:);
            end
        end
        if options.Padding % remove padding if neccessary
            for i_r = 1:n_reactions
                Rcell{i_r} = Rcell{i_r}{~isempty(Rcell{i_r})};
                Pcell{i_r} = Pcell{i_r}{~isempty(Pcell{i_r})};
            end
        end
        nprod_e = zeros([1,n_reactions]);
        
        % Fill structs
        for i_r = 1:n_reactions
            % R matrix
            for i_react=1:length(Rcell{i_r})
                R(i_r,s.(Rcell{i_r}{i_react})) = R(i_r,s.(Rcell{i_r}{i_react})) + 1;
            end
            % P matrix
            for i_prod=1:length(Pcell{i_r})
                P(i_r,s.(Pcell{i_r}{i_prod})) = P(i_r,s.(Pcell{i_r}{i_prod})) + 1;
            end
            % electron type
            if ismember('eh',reactions.React{i_r}) || ismember('eh',reactions.Prod{i_r})
                Reactype.eH(i_r) = 1;
                Range.ehtype(end+1) = i_r;
            elseif ismember('e',reactions.React{i_r}) || ismember('e',reactions.Prod{i_r})
                Reactype.eC(i_r) = 1;
                Range.ectype(end+1) = i_r;
            else
                % NOTE : this doesn't make any sense, but it doesn't matter
                % in the end (it's not used currently)
                % It's still here so that the legacy output really
                % corresponds to the legacy version
                % NOTE : with the addition of N2, there are reactions that
                % do not involve electrons ! is this an issue?
                % NOTE : ATM, Reactype.eC is not used, only Reactype.eH
                Reactype.eC(i_r) = 1;
                Range.ectype(end+1) = i_r;
            end
            % reaction type
            switch reactions.type{i_r}
                case 'ion'
                    if Reactype.eH(i_r)
                        Range.ionH(end+1) = i_r;
                    else
                        Range.ionC(end+1) = i_r;
                    end
                    % parent species of ion
                    tmp = Rcell{i_r};
                    tmp = tmp(~strcmp('eh',tmp));
                    tmp = tmp(~strcmp('e',tmp));
                    Range.ionparent(i_r) = s.(tmp{1});
                case 'exc'
                    if Reactype.eH(i_r)
                        Range.excH(end+1) = i_r;
                    else
                        Range.excC(end+1) = i_r;
                    end
                case 'pen'
                    Range.penning(end+1) = i_r;
                    % NOTE : this also produces electrons/ionizes
                    % FIXME : should this also have an entry in ionparent
                    % for effective cost of ionization?
                % case 'chex'
                %     Range.chex(end+1) = i_r;
                % NOTE : there's also a charge transfer type which is
                % ignored here
                % FIXME : find out if this is intended
            end
            % effective number of produced (cold) electrons
            nprod_e(i_r) = sum(strcmp('e',Pcell{i_r}))...
                         - sum(strcmp('e',Rcell{i_r}));
            % NOTE : eh should always be the same on both sides
            if sum(strcmp('eh',Pcell{i_r})) ~= sum(strcmp('eh',Rcell{i_r}))
                error('Number of hot electrons not conserved');
            end
        end
        if size(Eiz,2) > size(Eiz,1) % this is a matrix product -> orientation matters
            Vif = (P-R)*Eiz.';
        else
            Vif = (P-R)*Eiz;
        end
        
        % assemble struct
        Rea.Range = Range;
        Rea.Reactype = Reactype;
        Rea.R = R;
        Rea.P = P;
        Rea.tags = tags;
        Rea.rn = rn;
        Rea.reactions = util.struct.soa2aos(reactions);
        Rea.Rcell = Rcell;
        Rea.Pcell = Pcell;
        for i_r = 1:n_reactions
            Rea.reactions(i_r).React = Rcell{i_r};
            Rea.reactions(i_r).Prod = Pcell{i_r};
            if iscell(Rea.reactions(i_r).coeffs)
                Rea.reactions(i_r).coeffs = Rea.reactions(i_r).coeffs{1};
            end
        end
        Rea.nprod_e = nprod_e;
        Rea.Vif = transpose(Vif);

        % Fix some minor things so that the output is identical to the
        % legacy output
        Rea.reactions = transpose(Rea.reactions);
        for i_r = 1:n_reactions
            Rea.reactions(i_r).Ref = Rea.reactions(i_r).Ref{1};
            Rea.reactions(i_r).tag = Rea.reactions(i_r).tag{1};
            Rea.reactions(i_r).type = Rea.reactions(i_r).type{1};
        end
        
        % export struct
        save(filename, 'Rea');
        output = Rea;
    otherwise % new output
        % TODO : IMPLEMENT!!!
        % Take into consideration how it will be used and adapt for most efficient way!!!
        warning("The new output structure has not been designed yet. Saving table instead.")
        save(filename, 'reactions');
        output = reactions;
end

end

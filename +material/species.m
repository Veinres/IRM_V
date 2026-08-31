function [filename, output] = species(refill, target, T_g, T_gi, options)
%SPECIES generate table of refill gas and target material species
% =========================================================================
% Generate a table containing relevant gas and target material species and
% save it to a .mat file.
%
% ARGUMENTS ---------------------------------------------------------------
%
%   refill      (string, (1,:)), The refill gas
%
%   target      (string), The target material
%
%   T_g         (numeric, optional, default=0.0431), The temperature of the
%                   working gas in eV.
%
%   T_gi        (numeric, optional, default=1), The temperature of working
%                   gas ions in eV.
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
%                   '+material/species/<gas><target>.mat' where <gas> and
%                   <target> are the element symbols of the working gas and
%                   target material respectively. For lagacy output, the
%                   prefix 'Spe_' is added to the default filename.
%
% Return ------------------------------------------------------------------
%
%   filename    (string), Output file path
%
%   output      (struct/table), generated output. Struct or table depending
%                   on output option.
%
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ NOTE ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This function requires Matlab 2020b or later.
% =========================================================================

%% NOTES: -----------------------------------------------------------------
% TODO : verify species temperatures. Target material species temperatures
% are asigned inconsistently, with metastables sometimes having the same
% temperature as the refill gas and sometimes the same as the sputtered
% material
% TODO : rework update output structure
% TODO : generate one output and create compatibility wrapper
% -------------------------------------------------------------------------

%% Argument parsing and validation
arguments
    % positional arguments
    refill      (1,:) string
    target      string {mustBeTextScalar}
    % optional positional arguments
    T_g         double {mustBeNumeric, mustBeReal, mustBeScalarOrEmpty} = 0.0431
    T_gi        double {mustBeNumeric, mustBeReal, mustBeScalarOrEmpty} = 1
    % optional name-value pairs
    options.Output char {mustBeMember(options.Output,{...
                                'default',...       % default output structure
                                'legacy',...        % legacy output structure
                                'table'...          % table output for visual inspection
                                })} = 'legacy' % FIXME !!!
    options.Filename char {mustBeTextScalar(options.Filename)} = ''
end

refill_gas = refill;
target_material = target;

n_gases = length(refill_gas);

avail_gases = material.util.listAvailable('gas');
for i_gas = 1:n_gases
    if ~ismember(refill_gas(i_gas), avail_gases)
        error("<%s> is not available as refill gas. Check spelling and available gases.\n", refill_gas(i_gas));
    end
end
if ~contains(material.util.listAvailable('target'), target_material)
    error("<%s> is not available as target material. Check spelling and available materials.\n", target_material);
end

%% Collect species --------------------------------------------------------
electron_species = material.electron.species(T_g, T_gi);
gas_species = cell([1,n_gases]);
for i_gas = 1:n_gases
    gas_species{i_gas} = material.gas.(refill_gas(i_gas)).species(T_g, T_gi);
end
target_species = material.target.(target_material).species(T_g, T_gi);

species = [electron_species; vertcat(gas_species{:}); target_species];

% Additional table properties
species.Properties.DimensionNames = {'Species','Variables'};
species.Properties.RowNames = species.name;
gas_names = cellfun(@(gas) gas.parent{1}, gas_species, 'UniformOutput', false);
info.name = strcat(gas_names{:}, target_species.parent{1});
species.Properties.Description = sprintf("Species information for %s discharge", info.name);
info.creation_date = datetime('now','Format','yyyy-MM-dd_hhmm');
info.refill = gas_names;
info.target = target_species.parent{1};
% TODO: add species ranges
species.Properties.UserData = info;

%% Export

if isempty(options.Filename)
    % default filename
    if ~exist('+material/species','dir')
        mkdir('+material/species');
    end
    if strcmp(options.Output, 'legacy')
        filename = sprintf("+material/species/Spe_%s", info.name);
    else
        filename = sprintf("+material/species/%s", info.name);
    end
else
    % costum filename
    filename = options.Filename;
end

switch options.Output
    case 'table' % fancy output for inspection
        save(filename, 'species');
        output = species;
    case 'legacy' % legacy output for compatibility
        species = species(:,{'parent','name','label','M','Q','T','state','E','beta','n0'});
        species.Properties.VariableNames = {'PSpecies','Names','List','M','Q','T','state','Energy','B','ID'};
        Spe = table2struct(species,'ToScalar',true);
        Spe.s = util.base.enumStruct(species.Names);
        enum = 1:length(species.Names);
        for i_gas = 1:n_gases
            Spe.ss.(info.refill{i_gas}) = enum(strcmp(species.PSpecies,info.refill{i_gas}));
        end
        Spe.ss.(info.target) = enum(strcmp(species.PSpecies,info.target));
        Spe.ss.Targetgroup = enum(strcmp(species.PSpecies,info.target));
        Spe.ss.Refill_gasesgroup = enum(ismember(species.PSpecies,info.refill));
        Spe.PSpeciess = [info.refill(:)', {info.target}];
        Spe.Refill_gases = info.refill;
        Spe.Target = {info.target};
        % correct array orientations
        flds = fields(Spe);
        for i_f = 1:length(flds)
            sz = size(Spe.(flds{i_f}));
            if sz(1) > sz(2) && min(sz) == 1
                Spe.(flds{i_f}) = Spe.(flds{i_f}).';
            end
        end
        save(filename, 'Spe');
        output = Spe;
    otherwise % new output
        % TODO : IMPLEMENT!!!
        % Take into consideration how it will be used and adapt for most efficient way!!!
        warning("The new output structure has not been designed yet. Saving table instead.")
        save(filename, 'species');
        output = species;
end

end

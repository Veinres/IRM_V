function setup(refill, target, T_g, T_gi, options)
%SETUP Setup all required material specific data.
% =========================================================================
% Generate a tables containing species, reactions, secondary electron and
% sputter yields as well as effective cost of ionization.
%
% ARGUMENTS ---------------------------------------------------------------
%
%   refill      (char/cell), The refill gas(es)
%
%   target      (char/cell), The target material
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
%                   '+material/<species|reactions|se_yield|sp_yield|ec_ion>
%                   /<gas><target>.mat' where <gas> and <target> are the
%                   element symbols of the working gas and target materials
%                   respectively. If a filename '<dir>/<file>.mat' is
%                   specified, the outputfiles will be placed in at
%                   '<dir>/<species|reactions|se_yield|sp_yield|ec_ion>
%                   /<file>.mat' without any format dependent prefix.
%
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ NOTE ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This function requires Matlab 2020b or later.
% =========================================================================

%% NOTES: -----------------------------------------------------------------
% TODO : implement custom path
% TODO : rename material package (name collides with a matlab function)
% -------------------------------------------------------------------------

%% Argument parsing and validation
arguments
    % positional arguments
    refill      cell {mustBeText}
    target      cell {mustBeText}
    % optional positional arguments
    T_g         double {mustBeNumeric, mustBeReal, mustBeScalarOrEmpty} = 0.0431 % 500K
    T_gi        double {mustBeNumeric, mustBeReal, mustBeScalarOrEmpty} = 1
    % optional name-value pairs
    options.Output char {mustBeMember(options.Output,{...
                                'default',...       % default output structure
                                'legacy',...        % legacy output structure
                                'table'...
                                })} = 'legacy' % FIXME !!!
    options.Filename char {mustBeTextScalar(options.Filename)} = ''
    options.ExportLegacy logical = true
end

if ~isempty(options.Filename)
    filename = options.Filename;
    [fdir,fname,~] = fileparts(filename);
else
    filename = '';
    fdir = '';
    fname = '';
end
if isempty(fname)
    fname = string(join(horzcat(refill, target), ''));
end

%% Setup material specific data

% Generate species
filename = prepDir(filename, fdir, fname, 'species');
[fn_spe, species] = material.species(refill, target, T_g, T_gi,...
                                     'Output', options.Output,...
                                     'Filename', filename);

% Generate reactions
filename = prepDir(filename, fdir, fname, 'reactions');
[fn_rea, reactions] = material.reactions(species,...
                                 'Output', options.Output,...
                                 'Filename', filename);

% Generate secondary electorn yields
filename = prepDir(filename, fdir, fname, 'se_yields');
[fn_se, se_yields] = material.secondaryElectronYield(species,...
                                 'Output', options.Output,...
                                 'Filename', filename);

% Generate sputter yields
filename = prepDir(filename, fdir, fname, 'sp_yields');
[fn_sp, sp_yields] = material.sputterYield(species,...
                                 'Output', options.Output,...
                                 'Filename', filename);

% Generate effective cost of ionization
filename = prepDir(filename, fdir, fname, 'ec_ion');
[fn_eci, ec_ion] = material.effectiveCost(species,...
                                 'Output', options.Output,...
                                 'Filename', filename);

% Save Pre-Cal struct % FIXME
if strcmpi(options.Output, 'legacy') && options.ExportLegacy
    Precal.Ec = ec_ion;
    Precal.Yield = sp_yields;
    Precal.gamma = se_yields;
    filename = fullfile('pre-cal/', sprintf('Precal_%s.mat', fname));
    save(filename, 'Precal');
    fprintf("Exported legacy Precal struct to %s\n", filename);

    Spe = species;
    filename = fullfile('species_reactions/', sprintf('Spe_%s.mat', fname));
    save(filename, 'Spe');
    fprintf("Exported legacy Spe struct to %s\n", filename);

    Rea = reactions;
    filename = fullfile('species_reactions/', sprintf('Rea_%s.mat', fname));
    save(filename, 'Rea');
    fprintf("Exported legacy Rea struct to %s\n", filename);
end

end

%% function defintions

function filename = prepDir(filename, fdir, fname, subfolder)
%PREPDIR adapt filename and create folder if it doesn't exist yet
    if ~isempty(filename)
        filename = fullfile(fdir, subfolder, strcat(fname,'.mat'));
        if ~exist(fullfile(fdir, subfolder),'dir')
            mkdir(fullfile(fdir, subfolder))
        end
    end
end

function [filename, output] = secondaryElectronYield(species, options)
%SECONDARYELECTRONYIELD generate SE yield structure
% =========================================================================
% Generate a structure containing the energy resolved secondary electron
% yields of the different ion species impinging on the target.
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
%                   '+material/se_yields/<gas><target>.mat' where <gas> and
%                   <target> are the element symbols of the working gas and
%                   target material respectively. For lagacy output, the
%                   prefix 'gamma_' is added to the default filename.
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
% TODO : implement
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
end

%%

warning('Not implemented yet. Using "create_Gamma.m".');
filename = '';
output = struct();

cd pre-cal/Secondary_e_yield/
[~, output] = create_Gamma(species, '');
cd  ../../

if ~isempty(options.Filename)
    pth = fileparts(options.Filename);
    if ~exist(pth, 'dir')
        mkdir(pth)
    end
    gamma = output;
    save(options.Filename, "gamma");
    filename = options.Filename;
end

end

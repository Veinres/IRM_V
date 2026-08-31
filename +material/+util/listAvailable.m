function avail = listAvailable(material_type)
%LISTAVAILABLE list available target materials or refill gases
% =========================================================================
% Produce a cell array of available target materials or refill gases
% ARGUMENTS ---------------------------------------------------------------
%
%   material_type    (char), 'target' or 'gas'
%
% RETURN ------------------------------------------------------------------
%
%   avail   (cell of char arrays), available materials
%
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ NOTE ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This function requires Matlab 2019b or later.
% =========================================================================

%% Argument parsing and validation
arguments
    % positional arguments
    material_type   char {mustBeMember(material_type,{'target','gas'})}
end

%% NOTES: -----------------------------------------------------------------
% 
% -------------------------------------------------------------------------

% get contents of materials.gas package
sub_pkg = dir(fullfile('+material',strcat('+', material_type)));
% filter for folders with names starting with '+' and remove first
% character
dirs = {sub_pkg([sub_pkg.isdir]).name};
avail = cellfun(@(y) y(2:end), dirs(cellfun(@(x) x(1)=='+', dirs)), 'UniformOutput', false);

end
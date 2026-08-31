function reastr = stringReps(reactions, species, nrs, options)
%STRINGREPS produce the string representations of reactions
% =========================================================================
% Produces four strings per reaction:
% 1. the number of the reaction
% 2. the internal tag of the reaction
% 3. the reaction represented as an equation
% 4. and the type of the reaction
%
% See also material.util.equationRep
%
% ARGUMENTS ---------------------------------------------------------------
%
%   reactions   (struct), a reactions struct
%
%   species     (struct), a species struct that contains all species
%                   appearing in any of the reactions
%
%   nrs         (double, (:,1), optional), nrs of reactions to be included
%                   If the number of reactions in reactions is larger than
%                   the length of nrs, it is assumed that only the
%                   reactions corrsponding to the indexes in nrs should be
%                   kept. If no numbers are provided, all reactions are
%                   included.
%
% NAME-VALUE --------------------------------------------------------------
%
%   'ReaEqOpts' (cell), options to be pased to equationRep
%
% RETURN ------------------------------------------------------------------
%
%   reastr      (string (:,4)), plotted figure
%
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ NOTE ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This function requires Matlab 2019b or later.
% =========================================================================

%% NOTES: -----------------------------------------------------------------
% -------------------------------------------------------------------------

%% Argument parsing and validation
arguments
    reactions
    species
    nrs (:,1) double = 1:length(reactions)
    options.ReaEqOpts cell = {};
end

%%

if length(nrs) ~= length(reactions)
    reactions = reactions(nrs);
end

reastr = strings([length(nrs), 4]);

reastr(:,1) = arrayfun(@(nr) sprintf("%d", nr), nrs);
reastr(:,2) = arrayfun(@(rea) string(rea.tag), reactions);
reastr(:,3) = material.util.reactions.equationReps( ...
    {reactions.React}, {reactions.Prod}, species, options.ReaEqOpts{:});
reastr(:,4) = arrayfun(@(rea) string(strrep(rea.type,'_','')), reactions);

end

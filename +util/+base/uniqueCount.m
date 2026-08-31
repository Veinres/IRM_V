function [vals, counts, ia, ic] = uniqueCount(A, varargin)
%UTIL.BASE.UNIQUECOUNT get unique elements and number of occurance
% =========================================================================
% Identify the unique elements of a matrix A and additionally count the
% number of occurances for each unique element.
%
% Accepts the same arguments as the built-in unique function.
%
% See also: unique.m
%
% ARGUMENTS ---------------------------------------------------------------
%
%   A           set of interest
%
% Return ------------------------------------------------------------------
%
%   vals        unique values/elements
%
%   counts      number of occurances of each unique element
%
%   ia          indecies such that vals = A(ia)
%
%   ic          indecies such that A = vals(ic)
%
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ NOTE ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% =========================================================================

%% NOTES: -----------------------------------------------------------------
% -------------------------------------------------------------------------

[vals, ia, ic] = unique(A, varargin{:});
counts = zeros(size(vals));
for i = 1:length(ic)
    counts(ic(i)) = counts(ic(i)) + 1;
end

end

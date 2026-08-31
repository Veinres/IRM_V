function str = equationReps(reactants, products, species, options)
%EQUATIONREPS create a string representations of reaction as an equation
% =========================================================================
% Can also accept multiple reactions which need to be supplied as cell
% arraies of cellstr for both reactants and products.
%
% ARGUMENTS ---------------------------------------------------------------
%
%   reactants   (cell), the reactants (IRM names)
%
%   products    (cell), the products (IRM names)
%
% NAME-VALUE --------------------------------------------------------------
%
%   'Style'     (char), options to be pased to equationRep
%
%   'Reduce'    (logical), whether to replace repeated elements with number
%
% RETURN ------------------------------------------------------------------
%
%   str      (string), str representing reaction as an equation 
%
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ NOTE ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This function requires Matlab 2019b or later.
% =========================================================================

%% NOTES: -----------------------------------------------------------------
% -------------------------------------------------------------------------

%% Argument parsing and validation
arguments
    reactants cell
    products cell
    species {material.util.valid.mustBeValidSpeciesInfo} = []
    options.Style char {mustBeMember(options.Style, {'plain', 'latex', 'minimal'})} = 'plain'
    options.Reduce logical = false
end

%%
if iscellstr(reactants)
    reactants = {reactants};
end
if iscellstr(products)
    products = {products};
end

sep = ' -> ';
countsep = '';
addr = ' + ';
if strcmp(options.Style, 'latex')
    if ~isempty(species)
        reactants = cellfun(@(r) material.util.species.latexNames(species, r), reactants, 'UniformOutput',false);
        products = cellfun(@(p) material.util.species.latexNames(species, p), products, 'UniformOutput',false);
        sep = ' $\rightarrow$ ';
        countsep = '$\,$';
    else
        error("Cannot create LaTex style string without species information");
    end
elseif strcmp(options.Style, 'minimal')
    sep = ':';
    addr = ',';
end

str = strings([length(reactants),1]);
for i = 1:length(str)
    if options.Reduce
        [tmp, counts] = util.base.uniqueCount(reactants{i}, 'stable');
        for j = 1:length(counts)
            if counts(j) > 1
                tmp{j} = sprintf('%d %s', counts(j), tmp{j});
            end
        end
        reactants{i} = tmp;
        [tmp, counts] = util.base.uniqueCount(products{i}, 'stable');
        for j = 1:length(counts)
            if counts(j) > 1
                tmp{j} = sprintf('%d%s%s', counts(j), countsep, tmp{j});
            end
        end
        products{i} = tmp;
    end
    str(i) = util.str.reaction(reactants{i}, products{i}, sep, addr);
end

end

function str = reaction(reactants, products, separator, adder)
%REACTION create a reaction string from products and reactants
if ~exist('separator', 'var') || isempty(separator)
    separator = ' -> ';
end
if ~exist('adder', 'var') || isempty(adder)
    adder = ' + ';
end
str = string(append( ...
    join(reactants, adder), ...
    separator, ...
    join(products, adder) ...
    ));

end

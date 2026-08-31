function [latex] = latexSpeciesNames(species, names)

latex = cellfun(@(name) species.List{species.s.(name)}, names, 'UniformOutput', false);

end

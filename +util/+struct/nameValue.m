function [namevalue] = nameValue(s)
    namevalue = arrayfun(@(x) ...
        reshape(vertcat(fieldnames(x).', struct2cell(x).'), [],1), ...
        s, 'UniformOutput', false);
    if isscalar(namevalue)
        namevalue = namevalue{1};
    end
end

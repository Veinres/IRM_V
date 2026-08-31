function [C] = toIndex(A)
%TOINDEX convert a mask to an index mask
    if islogical(A)
        C = find(A);
    else
        C = A;
    end
end

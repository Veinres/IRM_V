function [C] = toLogical(A, sz)
%TOLOGICAL convert a mask to a logical mask
    if islogical(A)
        C = A;
    else
        C = false(sz);
        C(A) = true;
    end
end

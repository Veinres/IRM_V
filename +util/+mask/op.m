function [C] = op(A, B, operation, setOrder)
%OP apply a set operation on two masks that can be logical or index based
    if ~exist('setOrder', 'var') || isempty(setOrder)
        setOrder = 'sorted';
    end
    A = util.mask.toIndex(A);
    B = util.mask.toIndex(B);
    C = operation(A, B, setOrder);
end

function mustBeSameSize(value, c)
%MUSTBESAMESIZE checks if the supplied arrays have the same size
    if any(size(value) ~= size(c))
        eidType = 'mustBeSameSize:notSameSize';
        msgType = 'Inputs must have the same size.';
        throwAsCaller(MException(eidType,msgType))
    end
end

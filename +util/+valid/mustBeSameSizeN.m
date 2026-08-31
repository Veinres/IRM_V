function mustBeSameSizeN(value, c, n)
%MUSTBESAMESIZE checks if the supplied arrays have the same size
    if any(size(value,n) ~= size(c,n))
        eidType = 'mustBeSameSizeN:notSameSizeN';
        msgType = sprintf('Inputs must have matching lengths along dimension %d.', n);
        throwAsCaller(MException(eidType,msgType))
    end
end

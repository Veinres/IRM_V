function repeatedArgs = distribute(args)
%DISTRIBUTE distribute the input arguments
%
% Example:
%   args{1} = {'a','b','c','d'}
%   args{2} = {[1],[2],[3],[4]}
% ->repeatedArgs = {'a',[1],'b',[2],'c',[3],'d',[4]}

arguments (Repeating)
    args (:,1) cell
end

nargs = length(args);
if nargs < 1
    repeatedArgs = {};
    return;
end

len = length(args{1});
rlen = len*nargs;
repeatedArgs = cell([rlen,1]);
for i = 1:length(args)
    if length(args{i}) ~= len
        error('util:base:distribute:incompatibleSize', ...
            "Inputs must have same length.");
    end
    repeatedArgs(i:nargs:rlen) = args{i};
end

end

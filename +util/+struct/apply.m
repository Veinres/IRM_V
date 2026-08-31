function [S1] = apply(S2, diff, rmv)
%APPLY apply a struct difference to a structure
% =========================================================================
% Recursively apply a struct difference deltaS to a structure S2.
% For example, if:
%
%   deltaS = S1 - S2 = util.struct.diff(S1,S2)
%
% The original struct S1 can be recovered by applying the deltaS to S2:
%
%   S1 = S2 + deltaS = util.struct.apply(S2, deltaS)
%
% The order of the field in the struct is ignored.
%
% ARGUMENTS ---------------------------------------------------------------
%
%   S2          (struct, (1,1)), substrahend
%
%   diff        (struct, (1,1)), difference
%
%   rmv         (struct, (1,1)), structure containing fields which should
%                   be removed (fields of S2 that do not exist in S1) 
%
% RETURN ------------------------------------------------------------------
%
%   S1          (struct, (1,1)), minuend
%
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ NOTE ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This function requires Matlab 2019b or later.
% =========================================================================

%% NOTES: -----------------------------------------------------------------
% -------------------------------------------------------------------------

%% Argument validation
arguments
    S2 struct {mustBeScalarOrEmpty}
    diff struct {mustBeScalarOrEmpty}
    rmv struct {mustBeScalarOrEmpty} = struct()
end

%% Start recursion
[S1] = apply_r(S2, diff, rmv);

end

%% Function definitions

function [S1] = apply_r(S2, diff, rmv)
%APPLY_R recursively apply a struct diff

    S1 = S2;
    flds = fields(diff);

    for i = 1:length(flds)
        if isstruct(diff.(flds{i}))
            if ~isfield(rmv, flds{i})
                rmv.(flds{i}) = struct();
            end
            tmp = apply_r(S2.(flds{i}), diff.(flds{i}), rmv.(flds{i}));
            S1.(flds{i}) = tmp;
        elseif isempty(diff.(flds{i})) && isfield(rmv, flds{i})
            S1 = rmfield(S1, flds{i});
        else
            S1.(flds{i}) = diff.(flds{i});
        end
    end
end
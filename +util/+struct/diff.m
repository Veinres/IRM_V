function [diff, rmv] = diff(S1, S2)
%DIFF Compute the difference of two structs
% =========================================================================
% Recursively compute the difference deltaS of two structs S1 and S2, such
% that:
%
%   deltaS = S1 - S2 = util.struct.diff(S1,S2)
%
% The original struct S1 can be recovered by applying the deltaS to S2:
%
%   S1 = S2 + deltaS = util.struct.apply(S2, deltaS)
%
% The order of the field in the struct is ignored. Only recurses into
% fields that are themselves scalar structs.
%
% ARGUMENTS ---------------------------------------------------------------
%
%   S1          (struct, (1,1)), minuend
%
%   S2          (struct, (1,1)), substrahend
%
% RETURN ------------------------------------------------------------------
%
%   diff        (struct, (1,1)), difference
%
%   rmv         (struct, (1,1)), structure containing fields which should
%                   be removed (fields of S2 that do not exist in S1) 
%
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ NOTE ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This function requires Matlab 2019b or later.
% =========================================================================

%% NOTES: -----------------------------------------------------------------
% -------------------------------------------------------------------------

%% Argument validation
arguments
    S1 struct {mustBeScalarOrEmpty}
    S2 struct {mustBeScalarOrEmpty}
end

%% Start recursion
[diff, rmv] = diff_r(S1, S2);

end

%% Function definitions

function [diff, rmv] = diff_r(S1, S2)
%DIFF_R recursively compute the difference of two structs

    rmv = struct();
    diff = struct();
    flds = union(fields(S1), fields(S2));
    for i = 1:length(flds)
        if isfield(S1, flds{i})
            if isfield(S2, flds{i})
                if ~strcmp(class(S1.(flds{i})), class(S2.(flds{i})))
                    diff.(flds{i}) = S1.(flds{i});
                else
                    if isstruct(S1.(flds{i})) && isscalar(S1.(flds{i}))
                        [tmp_diff, tmp_rmv] = diff_r(S1.(flds{i}), S2.(flds{i}));
                        if ~isempty(fields(tmp_diff))
                            diff.(flds{i}) = tmp_diff;
                            rmv.(flds{i}) = tmp_rmv;
                        end
                    elseif ~isequal(S1.(flds{i}), S2.(flds{i}))
                        diff.(flds{i}) = S1.(flds{i});
                    end
                end
            else
                diff.(flds{i}) = S1.(flds{i});
            end
        else
            diff.(flds{i}) = [];
            rmv.(flds{i}) = [];
        end
    end
end

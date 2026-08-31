function [n_call, exec_time] = callCount(options)
%callCount keep track of numbers of calls and execution time
% =========================================================================
% This is a convenience wrapper for util.ode.callCounter . For more
% information, see util.ode.callCounter .
%
% NAME-VALUE --------------------------------------------------------------
%
%   'Action'      (char, default='update'), action to perform:
%                   - 'update'  : update and output counts
%                                 (also initializes)
%                   - 'init'    : initialize (usually not required,
%                                 since 'update' will also initalize)
%                   - 'get'     : output only (must be initialized)
%                   - 'clear'   : clear
%                                 (-> will again require initialization)
%
% RETURN ------------------------------------------------------------------
%
%   n_calls     (integer), number of calls to util.ode.callCounter(2)
%                   since initialization
%
%   exec_time   (integer), time since first call to
%                   util.ode.callCounter(2) in seconds after
%                   initialization
%
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ NOTE ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% In performance sensitive situations, use util.ode.callCounter instead.
% =========================================================================

arguments
    options.Action char {mustBeMember(options.Action, ...
        {'clear','init','update','get'})} = '';
end

switch options.Action
    case 'clear'
        action_ = -1;
    case 'init'
        action_ =  1;
    case 'get'
        action_ =  0;
    otherwise % 'update'
        action_ =  2;
end
[n_call, exec_time] = util.ode.callCounter(action_);

end

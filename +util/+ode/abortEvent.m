function [value, isterminal, direction] = abortEvent(t, y, n_max_calls, max_exec_time)
%ABORTEVENT ode termination event based on evaluation count and time
% =========================================================================
% A terminal event for the use with matlab ode integrators that allows to
% terminate early based on specified maximum of function evaluations and/or
% a maxium execution time. For this event to work properly, the
% callCounter needs to be cleared before integration and the integrand has
% to call util.ode.callCounter or its wrapper, util.ode.callCount, at
% each evaluation.
% 
% It is recommended to use util.ode.callCounter in the integrand to avoid
% the additional function call and argument validation overhead of
% util.ode.callCount (Especially if the integrand is computationally
% inexpensive).
%
% ARGUMENTS ---------------------------------------------------------------
%
%   t           (double, ignored), independnet variable
%   y           (double array, ignored), dependent variable
%
%   n_max_calls (integer), maximum number of integrand evaluations after
%                   which integration should be aborted
%
%   max_exec_time (double), maximum execution time in seconds after
%                   which integration should be aborted
%
% RETURN ------------------------------------------------------------------
%
%   value       (double), event signal (0.0 or 1.0).
%                   (Event occurs when value crosses 0.0)
%
%   isterminal  (logical), always true. (c.f. doc ODE Event)
%
%   direction   (integer), always 0. (c.f. doc ODE Event)
%
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ NOTE ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% C.f. https://www.mathworks.com/help/matlab/math/ode-event-location.html
% =========================================================================

    [n_calls, exec_time] = util.ode.callCounter(0);
    abort = (n_calls > n_max_calls) || (exec_time > max_exec_time);
    if abort
        if n_calls > n_max_calls
            warning('util:ode:abortEvent:numberOfCalls', ...
                "Failure at t=%e. Maximum number of integrand evaluations exceeded.", t);
        end
        if exec_time > max_exec_time
            warning('util:ode:abortEvent:executionTime', ...
                "Failure at t=%e. Maximum execution time exceeded.", t);
        end
    end
    value = double(~abort);
    isterminal = true;
    direction = 0;
end

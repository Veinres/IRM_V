function [n_calls, exec_time] = callCounter(action)
%callCounter keep track of numbers of calls and execution time
% =========================================================================
% Use persitent variables to keep track of the numbers of calls made to the
% integrand as well as the execution time. The purpose of this is to enable
% terminating the integration early based on a maximum number of integrand
% evaluations or a maximum execution time (See util.ode.abortEvent ).
%
% For convenience, a more readable wrapper is also implemented
% (See util.ode.callCount ).
%
% ARGUMENTS ---------------------------------------------------------------
%
%   action      (integer), action to perform:
%                   -  2 : update and output counts (initializes)
%                   -  1 : initialize (usually not required,
%                          since update will also initalize)
%                   -  0 : output only (must be initialized)
%                   - -1 : clear (-> will again require initialization)
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
% This is a global counter. Only one instance can be used at the same time.
% =========================================================================

persistent n_calls_ start_time_;

n_calls = 0;
exec_time = 0.;

if action == 1 % initialize
    n_calls_ = 0;
    start_time_ = tic();
elseif action == -1 % clear
    n_calls_ = [];
    start_time_ = [];
elseif action == 0 % output only
    n_calls = n_calls_;
    exec_time = toc(start_time_);
else % == 2 % update
    if isempty(n_calls_)
        n_calls_ = 1;
    else
        n_calls_ = n_calls_ + 1;
    end
    if isempty(start_time_)
        start_time_ = tic();
    end
    n_calls = n_calls_;
    exec_time = toc(start_time_);
end

end


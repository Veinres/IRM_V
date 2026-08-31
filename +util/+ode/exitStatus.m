function [exit_status] = exitStatus(t_end, t_target, options)
%UTIL.ODE.EXITSTATUS get simulation exit status
% =========================================================================
% Extract or reset the simulation exit status.
%
% ARGUMENTS ---------------------------------------------------------------
%
%   t_end       (double), simulation end time
%
%   t_target    (double), target simulation end time
%
% NAME-VALUE --------------------------------------------------------------
%
%   'Reset'     (logical, default=false), whether to reset the exit_state
%                   Reset is required before each simulation run.
%
%   'Warnings'  (char, default=''), whether to disable/enable warnings that
%                   are caught by util.ode.exitStatus
%                   - 'on' : toggle on warnings and backtrace
%                   - 'off': toggle off warnings and backtrace
%                   - ''   : leave as is
%
% RETURN ------------------------------------------------------------------
%
%   exit_status (char), see source code for possible statues
%                   Possible exit states:
%                   - 'success' (no warning or error)
%                   - 'unknown' (no information available)
%                   - 'failure:limit:stepsize' (from ode integrator)
%                   - 'failure:limit:numberOfCalls' (from terminal event)
%                   - 'failure:limit:executionTime' (from terminal event)
%                   - 'failure:errorThrown' (from try catch)
%
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ NOTE ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This function requires Matlab 2019b or later.
% =========================================================================

arguments
    t_end double = 0.
    t_target double = 0.
    options.Reset logical = false
    options.Warnings char {mustBeMember(options.Warnings, ...
                                {'on','off',''})} = ''
end

% warnids = configureDictionary('string','string'); % requires 2023b
warnids = dictionary(); % FIXME should switch to configureDirctionary at some point
warnids('util:ode:abortEvent:numberOfCalls') = 'failure:limit:numberOfCalls';
warnids('util:ode:abortEvent:executionTime') = 'failure:limit:executionTime';
warnids('irm:integrationError') = 'failure:errorThrown';
warnids('MATLAB:ode15s:IntegrationTolNotMet') = 'failure:limit:stepSize';

switch options.Warnings
    case 'on'
        wids = warnids.keys;
        for i_w = 1:length(wids)
            warning('on', wids{i_w});
        end
        warning('on', 'backtrace');
    case 'off'
        wids = warnids.keys;
        for i_w = 1:length(wids)
            warning('off', wids{i_w});
        end
        warning('off', 'backtrace');
    otherwise
        % leave as is
end

if options.Reset
    lastwarn('','');
    exit_status = [];
    return;
end

[~, warnId] = lastwarn();

% exit_status = warnids.lookup(warnId, "FallbackValue", ''); % requires 2023b
if isempty(warnId)
    exit_status{1} = '';
elseif ismember(warnId, warnids.keys) % FIXME switch to R2023b version
    exit_status = warnids(warnId);
else
    error('Unknown warning (ID=%s)', warnId);
end

if isempty(exit_status{1})
    if t_end > 0. && t_target > 0.
        if t_end/t_target > 0.99
            exit_status = 'success';
        else
            exit_status = 'failure';
        end
    else
        exit_status = 'unknown';
    end
end

if options.Reset
    lastwarn('','');
    return;
end

end

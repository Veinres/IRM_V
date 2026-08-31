function [ode_solver, selected] = selectSolver(solver)
%SELECTSOLVER return function handle to ODE solver given its name
% =========================================================================
% ARGUMENTS ---------------------------------------------------------------
%
%   'solver'    (char, default='ode15s'), name of ode solver
%                   available are:
%                   case 'ode45'
%                   case 'ode23'
%                   case 'ode113'
%                   case 'ode78'
%                   case 'ode89'
%                   case 'ode15s'
%                   case 'ode23s'
%                   case 'ode23t'
%                   case 'ode23tb'
%                   case 'ode15i'
%
% RETURN ------------------------------------------------------------------
%
%   ode_solver  (function_handle), handle to chosen ode solver
%
%   selected    (char), name of selected ode solver
%
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ NOTE ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% =========================================================================

arguments
    solver char = 'ode15s';
end

selected = solver;

switch solver
    case 'ode45'
        ode_solver = @ode45;
    case 'ode23'
        ode_solver = @ode23;
    case 'ode113'
        ode_solver = @ode113;
    case 'ode78'
        ode_solver = @ode78;
    case 'ode89'
        ode_solver = @ode89;
    case 'ode15s'
        ode_solver = @ode15s;
    case 'ode23s'
        ode_solver = @odeode23s45;
    case 'ode23t'
        ode_solver = @ode23t;
    case 'ode23tb'
        ode_solver = @ode23tb;
    case 'ode15i'
        ode_solver = @ode15i;
    otherwise
        warning('Invalid ODE solver choice. Using ode15s instead.');
        ode_solver = @ode15s;
        selected = 'ode15s';
end

end

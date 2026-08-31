function [xap, alpha, fxap] = backtrack(f, grad_fx, x, p, alpha, c, tau)
%BACKTRACK - perform a Armijo backtracking line search
% =========================================================================
% Perform a Armijo backtracking line search on a closed domain (x_i in
% [0,1])
% ARGUMENTS ---------------------------------------------------------------
%
%   f           (function_handle), scalar function (field)
%
%   grad_fx     ((:,1), double), gradient of function at point x
%
%   x           ((:,1), double), current point in argument space
%
%   p           ((:,1), double), descent direction
%
%   alpha       (double), initial (maximal) step size
%
%   c           (double, ]0,1[), acceptance criterion
%
%   tau         (double, ]0,1[), shrinking factor
%
% RETURN ------------------------------------------------------------------
%
%   alpha       (double), used step size
%
%   xap         ((:,1), double), next point in argument space (x+alpha*p)
%
%   faxp        (double), value of function at xap (f(x+alpha*p))
%
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ NOTE ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% =========================================================================

%% NOTES: -----------------------------------------------------------------

% -------------------------------------------------------------------------
    
    m = dot(grad_fx,p);
    
    lbound = 0*x;
    ubound = lbound + 1;
    
    fx = f(x);
    fxap = fx;
    n = 0;
    max_iter = 20;
    xap = x;
    
    while fx - fxap < -c*alpha*m && n < max_iter
        alpha = tau*alpha;
        xap = max(min(x + alpha*p,ubound),lbound);
        fxap = f(xap);
        n = n + 1;
    end
end
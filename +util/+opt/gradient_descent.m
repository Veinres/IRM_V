function [x_min, f_min, err, n] = gradient_descent(f, x0, tol, max_iter, grad_f)
%GRADIENT_DESCENT - perform a gradient descent
% =========================================================================
% Perform a gradient descent using Armijo backtracking on a closed domain
% (x_i in [0,1]), e.g. variables have to be normalised).
% ARGUMENTS ---------------------------------------------------------------
%
%   f           (function_handle), scalar function (field)
%
%   x0          ((:,1), double), starting point in argument space
%
%   tol         (double, ]0,1[), target tolerance
%
%   max_iter    (integer), maximum number of iterations
%
% RETURN ------------------------------------------------------------------
%
%   x_min       ((:,1), double), point in argument space of local minimum
%
%   f_min       (double), local minimum of function
%
%   err         (double), euclidean norm of the last displacement
%
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ NOTE ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% =========================================================================

%% NOTES: -----------------------------------------------------------------

% -------------------------------------------------------------------------

    tau = 0.5;
    c = 0.5;
    alpha = 0.5;
    
    if exist('grad_f', 'var') && isa(grad_f,'function_handle')
        grad = @(x_, dx_) grad_f(x_);
    else
        grad = @(x_, dx_) util.opt.num_gradient(f, x_, dx_);
    end
    
    x = x0;
    x_old = x0 + 2*tol;
    err = sum(abs(x - x_old));
    err_old = err;
    n = 0;
    while  ( err > tol || err_old > tol ) && n < max_iter
        x_old = x;
        err_old = err;
        
        g = grad(x, err*tau);
        % if on the domain border, set components pointing out of the
        % domain to zero
        p = -g.*(1-1*(abs(x-1)<tol).*(sign(g)<0)-1*(abs(x)<tol).*(sign(g)>0)); % FIXME
        p = p/norm(p);
        x = util.opt.backtrack(f, g, x, p, alpha, c, tau);
        err = norm(x_old - x);
        n = n + 1;
    end
    x_min = x;
    f_min = f(x);
end

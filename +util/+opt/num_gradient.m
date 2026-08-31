function grad = num_gradient(f, x, alpha)
%NUM_GRADIENT - numerically calculate gradient
% =========================================================================
% Calculate the gradient of an arbitrary scalar field numerically by
% looking at the function value at the centers of the faces of a hyper-cube
% with side length alpha centered in x.
% ARGUMENTS ---------------------------------------------------------------
%
%   f           (function_handle), scalar function (field)
%
%   x0          ((:,1), double), starting point in argument space
%
%   alpha       (double), initial step size
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
%   err         (double), sum (l1) norm of the last displacement
%
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ NOTE ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Results in 2*length(x) calls to f and should thus be considered
% expensive.
% =========================================================================

%% NOTES: -----------------------------------------------------------------

% -------------------------------------------------------------------------

    grad = zeros(size(x));
    for i = 1:length(grad)
        xp = x; xn = x;
        xp(i) = xp(i) + alpha/2;
        xn(i) = xn(i) - alpha/2;
        grad(i) = (f(xp)-f(xn))/alpha;
    end
end

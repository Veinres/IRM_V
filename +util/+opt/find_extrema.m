function [xfx] = find_extrema(f, max_pts, max_iter, grad_f, min_prom, min_dist)
% Find all local extrema of a C1 function with domain [0,1] using the
% "Roller-Coaster" algorithm. Doesn't guarantee finding extrema which are
% separated by less than 1/max_pts.
% 1. Start at 0 (or 1). Find out if max or min
% NOTE: runtime is proportional to number of local extrema

xfx = NaN(max_pts,2);
dx = 1/10/max_pts;
tol = max(dx/20,1e-6);

if exist('grad_f', 'var') && isa(grad_f, 'function_handle')
    grad = grad_f;
else
    grad = @(x_) util.opt.num_gradient(f,x_,dx);
end
if ~exist('min_prom', 'var') % FIXME
    min_prom = 0;
end
if ~exist('min_dist', 'var') % FIXME
    min_dist = 0;
end

x = 1;
i = 1;
xfx(i,1) = 1;
xfx(i,2) = f(x);
g = grad(x);
sgn = 1;
if g < 0
    sgn = -sgn;
end
fun = @(x_) sgn*f(x_);

while abs(x) > dx/2 && i < max_pts
    % 1. find max_pts extrema (case with explicit gradient)
    if exist('grad_f', 'var') && isa(grad_f, 'function_handle')
        grad_fun = @(x_) sgn*grad(x_);
        while abs(x) > dx/2 && i < max_pts % The algorithm is moving from 1 to 0
            i = i + 1;
            % -dx/2 to nudge it away from extremum
            [x,fx] = util.opt.gradient_descent(fun, x - dx/2, 1e-6, max_iter, grad_fun);
            if xfx(i-1,1)-x > max(min_dist,dx) && abs(2*(fx-xfx(i-1,2))/(fx-xfx(i-1,2))) > min_prom
                xfx(i,1) = x;
                xfx(i,2) = sgn*fx;
            else
                disp('reject');
                i = i - 1;
            end
            sgn = -sgn;
            fun = @(x_) sgn*f(x_);
            grad_fun = @(x_) sgn*grad(x_);
        end
    % 1. find max_pts extrema (case with numerical gradient)
    else
        while abs(x) > dx/2 && i < max_pts % The algorithm is moving from 1 to 0
            i = i + 1;
            % -dx/2 to nudge it away from extremum
            [x,fx] = util.opt.gradient_descent(fun, x - dx/2, tol, max_iter);
            if xfx(i-1,1)-x > max(min_dist,dx) && abs(2*(fx-xfx(i-1,2))/(fx-xfx(i-1,2))) > min_prom
                xfx(i,1) = x;
                xfx(i,2) = sgn*fx;
            else
                i = i - 1;
            end
            sgn = -sgn;
            fun = @(x_) sgn*f(x_);
        end
    end
    % 2. check points, erase if necessary and continue if not enough points
    %   Erase a point 2 and 3 if:
    %       - if both point have less than the specified prominence
    %       compared to point 1
    %       - if the distance between point 3 and 2, and 2 and 1,
    %       is smaller than the specified minimum distance
    for j = 3:max_pts
        if ( abs(2*(xfx(j-1,2)-xfx(j,2))/(xfx(j-1,2)+xfx(j,2))) < min_prom && ...
                abs(2*(xfx(j-2,2)-xfx(j,2))/(xfx(j-2,2)+xfx(j,2))) < min_prom ) || ...
           ( xfx(j-1,1)-xfx(j,1) < min_dist && xfx(j-2,1)-xfx(j-1,1) < min_dist ) 
            xfx(j,:) = NaN;
            xfx(j-1,:) = NaN;
        end
    end
    xfx = sortrows(xfx);
    i = sum(~isnan(xfx(:,1)));
    if xfx(i,2) > xfx(i-1,2)
        sgn = 1; % next is extremum is a minimum
    else
        sgn = -1; % next is extremum is a maximum
    end
end

xfx = xfx(1:i,:); % throw away NaN points

end
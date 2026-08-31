function [x_] = roundTo(x, v, options)
%ROUNDTO round to closest in selection
% round values in x to closest value in v
    arguments
        x double {mustBeVector}
        v (1,:) double {mustBeVector}
        options.Direction char {mustBeMember(options.Direction,{'up', 'down', 'closest'})} = 'closest'
        options.Multiples logical = false
    end

    [~, imx] = max(size(x));
    if imx == 2
        % transpose input
        x = x.';
    end

    if options.Multiples
        % Simply create spans of all options to cover the entire possible
        % range
        % This can be incredibly inefficient!!!
        % TODO: solve this using division instead
        mv = max(abs(v));
        maxval = max(x) + 2*mv;
        minval = min(x) - 2*mv;
        v_ = [];
        for i=1:length(v)
            v_ = [v_, v(i):-v(i):minval, v(i):v(i):maxval];
        end
        v = reshape(unique(v_), 1, []);
    end

    switch options.Direction
        case 'up'
            tmp = v-x;
            tmp(tmp<0) = Inf;
        case 'down'
            tmp = x-v;
            tmp(tmp<0) = Inf;
        otherwise % 'closest'
            tmp = abs(x-v);
    end
    [dv,I] = min(tmp, [], 2);
    x_(:) = v(I);
    x_(isinf(dv)) = NaN;

    if imx == 2
        % transpose output to match input shape
        x_ = x_.';
    end
end


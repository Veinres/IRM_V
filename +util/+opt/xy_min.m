function [x_min, y_min] = xy_min(x, y, f, n_min)
arguments
    x   (:,:) double
    y   (:,:) double
    f   function_handle
    n_min double = 1;
end

xq{1} = unique(x);
xq{2} = unique(y);

x_min{1} = NaN(n_min*length(xq{1}),3);
x_min{2} = NaN(n_min*length(xq{2}),3);
for i_var = 1:2
    start_ind = 1;
    for i = 1:length(xq{i_var})
        if i_var == 1
            z = @(x) f(xq{i_var}(i),x);
        else
            z = @(x) f(x,xq{i_var}(i));
        end
        xfx = util.opt.find_extrema(z, 2*(n_min)+1, 100, [], 0.1, 0.05);
        if xfx(2,2) > xfx(1,2)
            xfx = xfx(1:2:end,:);
        else
            xfx = xfx(2:2:end,:);
        end
        if i_var == 1
            x_min{i_var}(start_ind:start_ind+size(xfx,1)-1,1) = xq{i_var}(i);
            x_min{i_var}(start_ind:start_ind+size(xfx,1)-1,2) = xfx(:,1); 
        else
            x_min{i_var}(start_ind:start_ind+size(xfx,1)-1,2) = xq{i_var}(i);
            x_min{i_var}(start_ind:start_ind+size(xfx,1)-1,1) = xfx(:,1); 
        end
        x_min{i_var}(start_ind:start_ind+size(xfx,1)-1,3) = xfx(:,2);
        start_ind = start_ind + size(xfx,1);
    end
end

y_min = x_min{2}(~isnan(x_min{2}(:,1)),:);
x_min = x_min{1}(~isnan(x_min{1}(:,1)),:);

end

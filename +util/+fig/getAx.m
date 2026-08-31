function [fig, ax] = getAx(figOrAx)
%GETAX get the figure and axes handles associated with an graphics object

if isa(figOrAx, 'matlab.graphics.axis.Axes')
    ax = figOrAx;
    % axes(ax); % NOTE : this is a very time consuming operation
    parent = ax.Parent;
    while ~isa(parent, 'matlab.ui.Figure') && parent.isprop('Parent')
        parent = parent.Parent;
    end
    fig = parent; % NOTE : this is not guaranteed to be a figure
elseif isa(figOrAx, 'matlab.ui.Figure')
    fig = figOrAx;
    if nargout > 1
        figure(fig); % NOTE : this is a very time consuming operation
        ax = gca();
    end
else
    fig = figure();
    if nargout > 1
        ax = gca();
    end
end

end

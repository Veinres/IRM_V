% UNUSED
function [ax, fig] = axFromFigOrAx(figOrAx)
%AXFROMFIGORAX 
    ax = [];
    if isempty(figOrAx)
        fig = figure();
    elseif isa(figOrAx, 'matlab.graphics.axis.Axes')
        ax = figOrAx;
    elseif isa(figOrAx, 'matlab.ui.Figure')
        fig = figure(figOrAx);
    else
        fig = figure();
    end
    if isempty(ax)
        ax = fig.CurrentAxes;
    end
end

%formats the current figure to the desired format
function ans=FormatFig()

%h=gcf; %Get handle to current figure
set(gcf,'Units','points')
%ha=gca; %Get handle to current axis
set(gca, 'Units','points','FontName','TradeGothic','FontSize',14,'LineWidth',...
        0.5,'TickLength',[0.0200 0.0500],'PlotBoxAspectRatio',[1.5 1 1])
hline=get(gca,'Children');
set(hline,'LineWidth',1)
xh=get(gca,'XLabel'); yh=get(gca,'YLabel');leg=legend; 
set(xh,'FontName','TradeGothic','FontSize',14, 'VerticalAlignment','top')
set(yh,'FontName','TradeGothic','FontSize',14);%, 'VerticalAlignment','bottom')
set(leg,'FontName','TradeGothic','FontSize',14);
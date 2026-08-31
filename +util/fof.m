function fof(path_to_results)
%fof format open figures

%% Parameters

axes_font_size = 18;
legend_font_size = 16;

if exist('path_to_results','var')
    lbl = util.label_from_savelocation(path_to_results);
else
    lbl = '';
end

%% Reformat figures

% Collect all currently open figures
fhs = findall(0, 'Type', 'figure');

for i = 1:numel(fhs)
    % extract graphics types and data
    types = cell(1,numel(fhs(i).CurrentAxes.Children));
    xs = types;
    ys = types;
    xlims = zeros(2,length(types));
    ylims = xlims;
    
    linestyles = {'-','--','-.',':'};
    i_style = 1;
    
    for j=1:numel(fhs(i).CurrentAxes.Children)
        types{j} = fhs(i).CurrentAxes.Children(j).Type;
        if ~strcmp(types{j},'text')
            xs{j} = fhs(i).CurrentAxes.Children(j).XData;
            xlims(:,j) = [min(xs{j}), max(xs{j})];
            ys{j} = fhs(i).CurrentAxes.Children(j).YData;
            ylims(:,j) = [min(ys{j}), max(ys{j})];
        end
        if strcmp(types{j},'line') && ~(contains(fhs(i).Name,'new') || contains(fhs(i).Name,'hist'))
            if i_style > length(linestyles); i_style=1; end
            fhs(i).CurrentAxes.Children(j).LineStyle = linestyles{i_style};
            i_style = i_style + 1;
        end
    end
    for j=1:numel(fhs(i).CurrentAxes.Children)
        if strcmp(types{j},'patch') % don't care about patches
            if j > 1
                xlims(:,j) = xlims(:,j-1);
                ylims(:,j) = ylims(:,j-1);
            else
                xlims(:,j) = xlims(:,j+1);
                ylims(:,j) = ylims(:,j+1);
            end
        end
    end
        
    if ~any(cellfun(@(type) strcmp(type,'contour'),types))
        
        if contains(fhs(i).Name,'current') || contains(fhs(i).Name,'properties') % FIXME: lazy hack
            fhs(i).CurrentAxes.XLim = [0,100];
            if contains(fhs(i).Name,'fit')
                figure(fhs(i));
                yyaxis left;
                y_lim = ylim();
                ylim([0,y_lim(2)]);
                yyaxis right;
                y_lim = ylim();
                ylim([y_lim(1),0]);
            end
        elseif contains(fhs(i).CurrentAxes.XLabel.String,'$t$')
            fhs(i).CurrentAxes.XLim = [0,150]; % FIXME: lazy hack
            %fhs(i).CurrentAxes.XLim = [min(xlims(1,:)),max(xlims(2,:))];
        end
        if ~(contains(fhs(i).Name,'current') || contains(fhs(i).Name,'properties'))
            while max(ylims(2,:)) > fhs(i).CurrentAxes.YLim(2)
                fhs(i).CurrentAxes.YLim(2) = fhs(i).CurrentAxes.YLim(2)*2;
            end
        end
    end
    
    fhs(i).CurrentAxes.FontSize = 16;
    
    if ~isempty(fhs(i).CurrentAxes.Legend)
        fhs(i).CurrentAxes.Legend.FontSize = 14;
        fhs(i).CurrentAxes.Legend.Box = 'on';
%         if strcmp(fhs(i).Name,'Current fit')
%             fhs(i).CurrentAxes.Legend.Location = 'best';
%         else
%             fhs(i).CurrentAxes.Legend.Location = 'northeast';
%         end
        if any(strcmp(fhs(i).CurrentAxes.Legend.String,'data1'))
            fhs(i).CurrentAxes.Legend.String = fhs(i).CurrentAxes.Legend.String(1:end-1);
        end
        fhs(i).CurrentAxes.Legend.Location = 'east';
        if contains(fhs(i).Name,'Ions')
            fhs(i).CurrentAxes.Legend.Orientation = 'horizontal';
            fhs(i).CurrentAxes.Legend.Location = 'northwest';
        end
    end
    
if ~isempty(lbl)
    if ~isempty(fhs(i).CurrentAxes.Legend) && ~strcmp(lbl,'A') && ~strcmp(lbl,'I')...
            && ~strcmp(lbl,'a) I') && ~strcmp(lbl,'a) A') && ~strcmp(lbl,'a)') && ~strcmp(lbl,'(a)')
        fhs(i).CurrentAxes.Legend.Visible = 'off';
    end
    
    if any(cellfun(@(type) strcmp(type,'contour'),types))
        text(fhs(i).CurrentAxes,0.90,0.925,lbl,'Units','normalized','Color',[1,1,1]);
    else
        text(fhs(i).CurrentAxes,0.90,0.925,lbl,'Units','normalized','Color',[0,0,0]);
        %text(fhs(i).CurrentAxes,0.05,0.925,lbl,'Units','normalized');
    end
end

end

end
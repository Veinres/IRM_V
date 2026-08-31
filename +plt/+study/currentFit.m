function currentFit(summary, inputs, outputs, options)
%CURRENTFIT plot the current fits for each scan in a study

arguments
    summary table
    inputs cell
    outputs cell
    options.TileLayout (1,2) double {mustBeInteger} = [4,3]
    options.Title = ''
    options.PlotArgs cell = {}
    options.PlotLabel char {mustBeMember(options.PlotLabel, ...
        {'Id', 'id', 'Nr', 'nr', '', 'none'})} = 'Id'
end

n_disch = height(summary);

plots_per_figure = prod(options.TileLayout);
nfigs = ceil(n_disch/plots_per_figure);

for i = 1:nfigs
    fig = figure;
    tl = tiledlayout(fig, options.TileLayout(1), options.TileLayout(2));
    for j = 1:plots_per_figure
        ind = (i-1)*plots_per_figure + j;
        if ind > n_disch; break; end
        tmp_fig = plt.scan.currentFit(summary(ind,:), ...
            inputs{ind}, outputs{ind}, options.PlotArgs{:});
        ax2 = gca;
        if ~isempty(options.PlotLabel)
            switch lower(options.PlotLabel)
                case 'id'
                    ax2.Title.String = strrep(summary.id(ind), '_', '\_');
                case 'nr'
                    ax2.Title.String = sprintf('%d', ind);
            end
        end
        if j > 1
            legend('off');
        end
        ax2.Parent = tl;
        ax2.Layout.Tile = j;
        close(tmp_fig);
    end
    if ~isempty(options.Title)
        if isa(options.Title, 'matlab.graphics.layout.Text')
            tl.Title = options.Title;
        elseif strcmp(options.Title, 'auto')
            tl.Title.String = sprintf("%d - %d", (i-1)*plots_per_figure + 1, min(i*plots_per_figure, n_disch));
        else
            tl.Title.String = options.Title;
        end
    end
    util.fig.maximise(fig);
end

end

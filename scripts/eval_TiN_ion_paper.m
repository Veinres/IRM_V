%% define discharges

reload = false;

if ~exist("scans", 'var') || reload

results_folder = 'results';
grid = 'custom';

scans = [];
scans(end+1).name = 'TiN_i08_0.0sccm_2'; % ArTi : ArTi % 1
scans(end).label = '1';
scans(end+1).name = 'TiN_i08_0.0sccm_2_ArN2Ti'; % ArTi : ArN2Ti % 2
scans(end).label = '1';

scans(end+1).name = 'TiN_i08_2.5sccm_3_ArTi'; % ArN2Ti : ArTi % 3
scans(end).label = '2';
scans(end+1).name = 'TiN_i08_2.5sccm_3_ArN2Ti_noN2'; % ArN2Ti : ArN2Ti w/o N2 % 4
scans(end).label = '2';
scans(end+1).name = 'TiN_i08_2.5sccm_3_ArN2Ti'; % ArN2Ti : ArN2Ti % 5
scans(end).label = '2';

scans(end+1).name = 'TiN_ip02_20.0sccm_5_ArN2Ti'; % N2Ti : ArN2Ti % 6
scans(end).label = '4';
scans(end+1).name = 'TiN_ip02_20.0sccm_5'; % N2Ti : N2Ti % 7
scans(end).label = '4';

scans(end+1).name = 'TiN_i08_20.0sccm_7'; % ArN2Ti : ArN2Ti % 8
scans(end).label = '5';

scans(end+1).name = 'TiN_i08_10.0sccm_11'; % ArN2Ti : ArN2Ti % 9
scans(end).label = '3';

%% load discharge results

for i_s = 1:length(scans)
    scans(i_s).file = dir(fullfile(results_folder, scans(i_s).name, strcat('**/',grid,'/*.mat')));
    scans(i_s).data = load(fullfile(scans(i_s).file.folder, scans(i_s).file.name));
    nrs = [scans(i_s).data.summary.nr.free, scans(i_s).data.summary.nr.cnst];
    nans = isnan(nrs);
    nrs(nans) = 1;
    [scans(i_s).outputs, scans(i_s).inputs] = ...
        rslt.scan.runs( ...
            scans(i_s).data.output, ...
            scans(i_s).data.input, ...
            scans(i_s).data.metadata, ...
            "nrs", nrs);
    for i = 1:2
        if nans(i); continue; end
        scans(i_s).outputs{i} = {};
        scans(i_s).inputs{i} = {};
    end
    scans(i_s).free.output = scans(i_s).outputs{nrs(1)};
    scans(i_s).free.input = scans(i_s).inputs{nrs(1)};
    scans(i_s).cnst.output = scans(i_s).outputs{nrs(1)};
    scans(i_s).cnst.input = scans(i_s).inputs{nrs(1)};
end

end

%% plotting experimental CV

% see exp/src/script/eval_TiN_ionmeter.m

%% prep for plotting

Spe = scans(5).data.input.input.Spe;
s = Spe.s;
ps = unique(Spe.PSpecies, 'stable');

line_styles = {'-','--',':','-.'};
n_ls = length(line_styles);
species_colors = orderedcolors("gem12");
n_sc = size(species_colors,1);

species_line_props = struct();
for i = 1:length(Spe.Names)
    species_line_props.(Spe.Names{i}).Color = species_colors(1+mod(i-1,n_sc),:);
    species_line_props.(Spe.Names{i}).LineStyle = line_styles{1+mod(find(strcmp(ps,Spe.PSpecies{i}))-1,n_sc)};
    if contains(Spe.Names{i}, 'N2')
        species_line_props.(Spe.Names{i}).Marker = 'o';
        species_line_props.(Spe.Names{i}).MarkerSize = 5;
        species_line_props.(Spe.Names{i}).MarkerIndices = 10:40:1000;
    end
end
warning('off','MATLAB:handle_graphics:Line:MarkerIndexOutOfRange');

output_folder = 'output/TiN-paper';

if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

%% current contributions and fit

figname = 'currents';
for i_s = [1,5,9,7]
    fit = scans(i_s).cnst;
    sc = species_colors(1+mod(cellfun(@(x) s.(x)-1, fit.input.Names),n_sc),:);
    gls = line_styles(1+mod(cellfun(@(x) find(strcmp(ps, x)), unique(fit.input.Spe.PSpecies,'stable'))-1,n_ls));
    fig = plt.run.currents(fit.output, fit.input, "Exp", false, "SpeciesLineProp", species_line_props, "Normalisation", "IRM");
    ax = fig.CurrentAxes;
    xlim(ax, [0,110]);
    % ylim(ax, [0,12]);
    % ylim(ax, [0,2]);
    legend(ax, 'Location', 'northwest');
    filename = sprintf('%s_%s', figname, scans(i_s).label);
    % exportgraphics(fig, fullfile(output_folder, strcat(filename, '.eps')), 'Resolution', 300);
    % exportgraphics(fig, fullfile(output_folder, strcat(filename, '.png')), 'Resolution', 300);
end

%% ion densities

figname = 'ions';
for i_s = [1,5,9,7]
    fit = scans(i_s).cnst;
    msk = fit.input.Spe.Q ~= 0 & ~strcmp(fit.input.Spe.PSpecies, 'e');
    fig = plt.run.densities(fit.output, fit.input, "Mask", msk, "SpeciesLineProp", species_line_props);
    ax = fig.CurrentAxes;
    xlim(ax, [0,300]);
    ylim(ax, [1e+10,1e+21]);
    l = legend(ax,'Location', 'southwest');
    pos = l.Position;
    pos(1) = pos(1) + 0.05;
    l.Position = pos;
    filename = sprintf('%s_%s', figname, scans(i_s).label);
    exportgraphics(fig, fullfile(output_folder, strcat(filename, '.eps')), 'Resolution', 300);
    exportgraphics(fig, fullfile(output_folder, strcat(filename, '.png')), 'Resolution', 300);
end

%% total neutral densities

figname = 'neutrals';
for i_s = [1,5,9,7]
    fit = scans(i_s).cnst;
    fig = figure();
    hold on;
    for i_ps = 1:length(ps)
        msk = strcmp(fit.input.Spe.PSpecies, ps{i_ps}) & fit.input.Spe.Q == 0;
        masses = unique(fit.input.Spe.M(msk));
        for i_m = 1:length(masses)
            sub_msk = msk & fit.input.Spe.M == masses(i_m);
            dens = sum(fit.output.n(:,sub_msk),2);
            rep_id = find(sub_msk, 1, 'first');
            rep_name = fit.input.Spe.Names{rep_id};
            line_props = util.struct.nameValue(species_line_props.(rep_name));
            plot(fit.output.t*1e+6, dens, line_props{:}, 'DisplayName', fit.input.Spe.Names{rep_id});
        end
    end
    ylabel('$n$ [$\rm m^{-3}$]');
    xlabel('$t$ [$\rm\mu s$]');
    ax = fig.CurrentAxes;
    xlim(ax, [0,300]);
    set(ax, 'yScale', 'log');
    ylim(ax, [1e+10,1e+21]);
    l = legend(ax,'Location', 'southwest');
    pos = l.Position;
    pos(1) = pos(1) + 0.05;
    l.Position = pos;
    filename = sprintf('%s_%s', figname, scans(i_s).label);
    exportgraphics(fig, fullfile(output_folder, strcat(filename, '.eps')), 'Resolution', 300);
    exportgraphics(fig, fullfile(output_folder, strcat(filename, '.png')), 'Resolution', 300);
end

%% plotting FOM maps

figname = 'fom';
for i_s = [1,5,9,7]
    fig = plt.scan.util.map(scans(i_s).data.results, scans(i_s).data.summary, scans(i_s).data.metadata, 'MarkFree', false);
    filename = sprintf('%s_%s', figname, scans(i_s).label);
    exportgraphics(fig, fullfile(output_folder, strcat(filename, '.eps')), 'Resolution', 300);
    exportgraphics(fig, fullfile(output_folder, strcat(filename, '.png')), 'Resolution', 300);
end

%% plotting electron properties

% figname = 'electrons';
% for i_s = [1,5,9,7]
%     fit = scans(i_s).cnst;
%     fig = plt.run.electrons(fit.output, fit.input);
%     xlim([0,300]);
%     filename = sprintf('%s_%s', figname, scans(i_s).label);
%     exportgraphics(fig, fullfile(output_folder, strcat(filename, '.eps')), 'Resolution', 300);
%     exportgraphics(fig, fullfile(output_folder, strcat(filename, '.png')), 'Resolution', 300);
% end

%% plotting electorn properties (together)

figname = 'n_ec';
fig = figure();
hold on;
for i_s = [1,5,9,7]
    fit = scans(i_s).cnst;
    plot(fit.output.t*1e+6, fit.output.n(:,1), 'DisplayName', scans(i_s).label);
end
legend('Location', 'northeast');
set(gca, 'yScale', 'log');
ylim([1e+15,1e+20]);
xlim([0,300]);
ylabel('$n_{\rm e,cold}$ [$\rm m^{-3}$]');
xlabel('$t$ [$\rm\mu s$]');
filename = sprintf('%s', figname);
exportgraphics(fig, fullfile(output_folder, strcat(filename, '.eps')), 'Resolution', 300);
exportgraphics(fig, fullfile(output_folder, strcat(filename, '.png')), 'Resolution', 300);

figname = 'n_eh';
fig = figure();
hold on;
for i_s = [1,5,9,7]
    fit = scans(i_s).cnst;
    plot(fit.output.t*1e+6, fit.output.n(:,2), 'DisplayName', scans(i_s).label);
end
legend('Location', 'northeast');
set(gca, 'yScale', 'log');
ylim([1e+15,1e+20]);
xlim([0,300]);
ylabel('$n_{\rm e,hot}$ [$\rm m^{-3}$]');
xlabel('$t$ [$\rm\mu s$]');
filename = sprintf('%s', figname);
exportgraphics(fig, fullfile(output_folder, strcat(filename, '.eps')), 'Resolution', 300);
exportgraphics(fig, fullfile(output_folder, strcat(filename, '.png')), 'Resolution', 300);

figname = 'T_ec';
fig = figure();
hold on;
for i_s = [1,5,9,7]
    fit = scans(i_s).cnst;
    plot(fit.output.t*1e+6, fit.output.T_ec, 'DisplayName', scans(i_s).label);
end
legend('Location', 'northeast');
% set(gca, 'yScale', 'log');
% ylim([1e+15,1e+20]);
xlim([0,300]);
ylabel('$T_{\rm e,cold}$ [$\rm eV$]');
xlabel('$t$ [$\rm\mu s$]');
filename = sprintf('%s', figname);
exportgraphics(fig, fullfile(output_folder, strcat(filename, '.eps')), 'Resolution', 300);
exportgraphics(fig, fullfile(output_folder, strcat(filename, '.png')), 'Resolution', 300);

figname = 'T_eh';
fig = figure();
hold on;
for i_s = [1,5,9,7]
    fit = scans(i_s).cnst;
    plot(fit.output.t*1e+6, fit.output.T_eh, 'DisplayName', scans(i_s).label);
end
legend('Location', 'northeast');
% set(gca, 'yScale', 'log');
% ylim([100,200]);
xlim([0,300]);
ylabel('$T_{\rm e,hot}$ [$\rm eV$]');
xlabel('$t$ [$\rm\mu s$]');
filename = sprintf('%s', figname);
exportgraphics(fig, fullfile(output_folder, strcat(filename, '.eps')), 'Resolution', 300);
exportgraphics(fig, fullfile(output_folder, strcat(filename, '.png')), 'Resolution', 300);

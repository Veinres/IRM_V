%% define discharges

results_folder = 'results';
grid = 'custom';

discharges = [];
discharges(end+1).name = 'TiN_i08_0.0sccm_2'; % ArTi : ArTi % 1
discharges(end+1).name = 'TiN_i08_0.0sccm_2_ArN2Ti'; % ArTi : ArN2Ti % 2

discharges(end+1).name = 'TiN_i08_2.5sccm_3_ArTi'; % ArN2Ti : ArTi % 3
discharges(end+1).name = 'TiN_i08_2.5sccm_3_ArN2Ti_noN2'; % ArN2Ti : ArN2Ti w/o N2 % 4
discharges(end+1).name = 'TiN_i08_2.5sccm_3_ArN2Ti'; % ArN2Ti : ArN2Ti % 5

discharges(end+1).name = 'TiN_ip02_20.0sccm_5_ArN2Ti'; % N2Ti : ArN2Ti % 6
discharges(end+1).name = 'TiN_ip02_20.0sccm_5'; % N2Ti : N2Ti % 7

discharges(end+1).name = 'TiN_i08_20.0sccm_7'; % ArN2Ti : ArN2Ti % 8

discharges(end+1).name = 'TiN_i08_10.0sccm_11'; % ArN2Ti : ArN2Ti % 9

discharges(end+1).name = 'TiN_i08-2_10.0sccm_12'; % ArN2Ti : ArN2Ti % 10

%% load discharge results

for i_d = 1:length(discharges)
    discharges(i_d).file = dir(fullfile(results_folder, discharges(i_d).name, strcat('**/',grid,'/*.mat')));
    discharges(i_d).data = load(fullfile(discharges(i_d).file.folder, discharges(i_d).file.name));
    nrs = [discharges(i_d).data.summary.nr.free, discharges(i_d).data.summary.nr.cnst];
    nans = isnan(nrs);
    nrs(nans) = 1;
    [discharges(i_d).outputs, discharges(i_d).inputs] = ...
        rslt.scan.runs( ...
            discharges(i_d).data.output, ...
            discharges(i_d).data.input, ...
            discharges(i_d).data.metadata, ...
            "nrs", nrs);
    for i = 1:2
        if nans(i); continue; end
        discharges(i_d).outputs{i} = {};
        discharges(i_d).inputs{i} = {};
    end
    discharges(i_d).free.output = discharges(i_d).outputs{nrs(1)};
    discharges(i_d).free.input = discharges(i_d).inputs{nrs(1)};
    discharges(i_d).cnst.output = discharges(i_d).outputs{nrs(1)};
    discharges(i_d).cnst.input = discharges(i_d).inputs{nrs(1)};
end

%% plotting

i_d = 1;
data = discharges(i_d).data;
name = discharges(i_d).name;
free = discharges(i_d).free;
cnst = discharges(i_d).cnst;

% current fit
plt.scan.currentFit(data.summary, data.input, data.output);
title(strrep(name, '_', '\_'));

% FOM map
plt.scan.util.map(data.results, data.summary, data.metadata);
title(strrep(name, '_', '\_'));

% var 
% plt.run.currents(cnst.output, cnst.input, "Exp", true);
plt.run.electrons(cnst.output, cnst.input);
plt.run.quasiNeutrality(cnst.output, cnst.input);
% plt.run.powerBalance(cnst.output, cnst.input, "LogAbs", true);
% 
% plt.run.densities(cnst.output, cnst.input, ...
%         "Mask", free.input.Spe.Q == 0  & (~contains(free.input.Spe.Names, 'N2v') | contains(free.input.Spe.Names, 'N2v1')) & ~ismember(free.input.Spe.Names, {'NH','NW'}));
% plt.run.densities(cnst.output, cnst.input, ...
%         "Mask", free.input.Spe.Q ~= 0);

%%
% 
for i_d = 8 %[1,2,5,7,8,9] %8
    data = discharges(i_d).data;
    name = discharges(i_d).name;
    free = discharges(i_d).free;
    cnst = discharges(i_d).cnst;
    plt.scan.currentFit(data.summary, data.input, data.output);
    title(strrep(name, '_', '\_'));
    plt.scan.util.map(data.results, data.summary, data.metadata);
    title(strrep(name, '_', '\_'));
    plt.run.currents(free.output, cnst.input);
    title(strrep(name, '_', '\_'));
    plt.run.densities(free.output, cnst.input, ...
        "Mask", ismember(free.input.Spe.PSpecies, 'N2'));
    title(strrep(name, '_', '\_'));
    plt.run.species.rates(free.output, free.input, "NS", "SplitRea", true, "PlotTotal", true);
    title(strrep(name, '_', '\_'));
end
% 
% %%
% 
% % plt.run.graph.plotIntegrated(free.output, free.input);
% plt.run.species.reactions(free.output, free.input, "Ni", "LogAbs", false);
% plt.run.species.powerBalance(cnst.output, cnst.input, "Arm3P2", "Population","cold");

%% paper plots

cases = [1,5,9,8,7,10]; % todo: remove 10

fig = figure;
tl = tiledlayout(fig,2,1);
ax = nexttile(tl);
hold on;
for i = 1:length(cases)
    i_d = cases(i);
    t = discharges(i_d).cnst.input.disch.T;
    U = discharges(i_d).cnst.input.disch.U;
    tmp = split(discharges(i_d).name, '_');
    N2_flow = sscanf(tmp{3}(1:end-4), '%f');
    plot(t, -U, DisplayName=sprintf('%3.1f sccm N\x0024_2\x0024', N2_flow));
end
xlim([-10,110]);
ylim([-25,600]);
legend('Location','northoutside', 'NumColumns',3);
ax = nexttile(tl);
hold on;
for i = 1:length(cases)
    i_d = cases(i);
    t = discharges(i_d).cnst.input.disch.T;
    I = discharges(i_d).cnst.input.disch.I;
    tmp = split(discharges(i_d).name, '_');
    N2_flow = sscanf(tmp{3}(1:end-4), '%f');
    plot(t, I, DisplayName=sprintf('%3.1f sccm N\x0024_2\x0024', N2_flow));
end
xlim([-10,110]);
ylim([0,12]);
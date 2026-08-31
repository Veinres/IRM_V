util.fig.setDefaultStyle();

%% load results
folder = 'results/TiN_i08_0.0sccm_2/TiN-impl/custom/';
subfolder = 'TiN-ion-sfcb_flux/run_Pfit1';
flux.output = load(fullfile(folder,subfolder,'Output.mat'));
flux.input = load(fullfile(folder,subfolder,'Input.mat'));
flux.analysed = load(fullfile(folder,subfolder,'Analysed.mat'));
all = load(fullfile(folder, 'TiN-ion-sfcb.mat'));

%% plot input
ID = flux.input.disch.I;
UD = flux.input.disch.U;
t = flux.input.disch.T;

% inds(1) = find(UD<0,1,'first') - 10;
% inds(2) = find(UD<0,1,'last') + 2;
% UD(1:inds(1)) = NaN;
% UD(inds(2):end) = NaN;

ss = 10;
c = colororder();

xlims = [-20,120];
inds(1) = find(t>=xlims(1),1,'first');
inds(2) = find(t<=xlims(2),1,'last');
msk = inds(1):ss:inds(2);

figure;
hold on;
yyaxis left;
plot(t(msk), ID(msk));
ylabel('$I_\mathrm{D}$ [A]');
ylim([0,6]);
yyaxis right;
plot(t(msk), UD(msk));
ylabel('$U_\mathrm{D}$ [V]');
set(gca, 'YDir', 'reverse')
ylim([-500,0]);
xlim(xlims);
xticks(-20:20:120);
xlabel('$t$ [$\mathrm{\mu s}$]');

yyaxis left;
text(35,2.9,0,'$p_\mathrm{Ar}=0.5\,\mathrm{Pa}$');
text(35,2.2,0,'$F_\mathrm{flux,Ti}=15\%$');

%% plot fit

ID = flux.input.disch.I;
t = flux.input.disch.T;

ss = 10;
c = colororder();

xlims = [-25,125];
inds(1) = find(t>=xlims(1),1,'first');
inds(2) = find(t<=xlims(2),1,'last');
msk = inds(1):ss:inds(2);

I_IRM = sum(best.cnst.I + best.cnst.I_se, 2);
t_IRM = best.cnst.t*1e+6;
% I_IRM(1) = 0;
% I_IRM = I_IRM([1,3:300]);
% t_IRM = t_IRM([1,3:300]);


figure;
hold on;
plot(t(msk), ID(msk));
plot(t_IRM, I_IRM);
xlim([-20,120]);
xlabel('$t$ [$\mathrm{\mu s}$]');
ylabel('$I_\mathrm{D}$ [A]');
legend({'$I_\mathrm{D}$','$I_\mathrm{IRM}$'}, 'Box','on', 'Location', 'south');

%% plot map

results = all.results;
summary = all.summary;
metadata = all.metadata;

% fflux = all.results.F_flx(:);
% fom = all.results.fom(:);
% beta = all.results.beta_t_p(:);
% f = all.results.f(:);

% figure;
% hold on;
% surf(beta, f, fom, 'EdgeColor', 'none');
v2.range = [0,0.4];
v2.nlvls = 9;
v2.var = 'F_flx';
v2.label = '$F_\mathrm{flux}$';
[fig, cm] = plt.scan.util.map(results, summary, metadata, 'V2', v2);


%% plot output

t = flux.output.t*1e+6;
n = flux.output.n;
I = flux.output.I;
I_se = sum(flux.output.I_se, 2);

% figure;
% plot(t, n);
% set(gca, 'yscale', 'log');
% xlim([1,120]);
% ylim([1e+15,1e+20]);
% xlabel('$t$ [$\mathrm{\mu s}$]');
% ylabel('$n$ [m$^{-3}$]');

inds = [6,7,11,12];

figure;
hold on;
plot(t, [I(:,inds),I_se]);
xlim([-20,120]);
xlabel('$t$ [$\mathrm{\mu s}$]');
ylabel('$I$ [A]');
legend({'Ar$^+$','Ar$^{2+}$','Ti$^+$','Ti$^{2+}$', '2$^\mathrm{nd}$-ary e$^-$'}, 'Box', 'on')


% collect consistent_current maps

files = dir(fullfile('results/scc/results/dev/d1b41eb518b20ac499717bb86c1fc13d6b9d022f/custom_cc*/ArCu/ArCu_HiPSTER_20A.mat'));
subfolders = cellfun(@(filename) extract(filename, '/custom_cc' + wildcardPattern + '/'),  {files.folder}, UniformOutput=false);
ccfact = cellfun(@(subfolder) sscanf(subfolder{1}, '/custom_cc%f/'), subfolders);
results = arrayfun(@(file) load(fullfile(file.folder, file.name)), files);

fig = figure;
tl = tiledlayout(fig, 'flow');
for i_ccf = 1:length(ccfact)
    ax = nexttile(tl);
    plt.scan.map(results(i_ccf).results, results(i_ccf).summary, results(i_ccf).metadata, 'Axes', ax);
    title(sprintf('\x0024 f_\\mathrm{IRM\\,Current}=%d\x005C%%\x0024', 100*ccfact(i_ccf)), 'Interpreter', 'latex');
end

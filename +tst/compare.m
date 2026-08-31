reslut_folder = "+tst/results/";

clear results;
results.before.folder = fullfile(reslut_folder, "64353178d1e421d1e42f96c7c15f5cc649887a90"); % This is before the change
results.interm.folder = fullfile(reslut_folder, "test/power-eq/f215f409c4f3dc3ce27fedc62cba4f31ae15897b/"); % This is an attempt to modify "before" to match after and thus find all differences
results.after.folder = fullfile(reslut_folder, "impl/TiN-IRM/75ea692c1249b67e2c9adf5e8b7482c66821c4fa/"); % This is after the change

% file = "fast/ArCu/ArCu/original/ArCu_HiPSTER_20A.mat";
% file = "fast/ArTi/disch_Prague_ArTi.mat";
file = "fast/ArC/LiU_ArC.mat";
% file = "fast/ArMo/ArHeMo_Erwan.mat";
% file = "fast/ArN2Ti/TiN-ion-sfcb.mat";
% file = "fast/HeMo/ArHeMo_Erwan/HeMo_700.mat";
% file = "fast/N2Ti/TiN-ion-sfcb.mat";

% TODO : make dicovery of files automatic so that one only needs to specify
% the folders/versions to comapre

%%
states = fields(results);
ns = length(states);
for i_s = 1:ns
    results.(states{i_s}).file = fullfile(results.(states{i_s}).folder, file);
    results.(states{i_s}).data = load(results.(states{i_s}).file);
end

%%
nrs = results.(states{i_s}).data.summary.nr.free(1);
if length(nrs) > 50
    gcp; % start parpool if you want to recreate many runs
end

%%
for i_s = 1:ns
    [results.(states{i_s}).outputs, results.(states{i_s}).inputs] = ...
        rslt.scan.runs( ...
            results.(states{i_s}).data.output, ...
            results.(states{i_s}).data.input, ...
            results.(states{i_s}).data.metadata, ...
            "nrs", nrs);
    results.(states{i_s}).best.output = results.(states{i_s}).outputs{nrs(1)};
    results.(states{i_s}).best.input = results.(states{i_s}).inputs{nrs(1)};
end

%% electron densities and temperatures

for i_s = 1:ns% 
% for i_s = 1:ns
%     plt.run.species.powerBalance( ...
%         results.(states{i_s}).best.output, ...
%         results.(states{i_s}).best.input, ...
%         "Cu", ...
%         "LogAbs", true);
%     title(states{i_s});
% end
    plt.run.electrons( ...
        results.(states{i_s}).best.output, ...
        results.(states{i_s}).best.input);
    title(states{i_s});
end

%% power balance

for i_s = 1:ns
    plt.run.powerBalance( ...
        results.(states{i_s}).best.output, ...
        results.(states{i_s}).best.input, ...
        "LogAbs", true);
    title(states{i_s});
end

%% power balance logarithmic

for i_s = 1:ns
    plt.run.powerBalance( ...
        results.(states{i_s}).best.output, ...
        results.(states{i_s}).best.input, ...
        "LogAbs", false);
    title(states{i_s});
end

%% 
% 
% for i_s = 1:ns
%     plt.run.species.powerBalance( ...
%         results.(states{i_s}).best.output, ...
%         results.(states{i_s}).best.input, ...
%         "Cu", ...
%         "LogAbs", true);
%     title(states{i_s});
% end

%% FOM maps

for i_s = 1:ns
    plt.scan.util.map( ...
        results.(states{i_s}).data.results, ...
        results.(states{i_s}).data.summary, ...
        results.(states{i_s}).data.metadata);
    title(states{i_s});
end

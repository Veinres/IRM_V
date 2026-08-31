% Regenerate the material data for each of the currently implemented materials

by_revision = true;     % output to a revision folder
export_legacy = true;   % copy Spe, Rea, and Precal to legacy folders

disch_types = {};
% Comment out discharge types to skip
disch_types{end+1} = {{'Ar'}, {'Ti'}};
disch_types{end+1} = {{'Ar'}, {'C'}};
disch_types{end+1} = {{'Ar'}, {'Cu'}};
disch_types{end+1} = {{'Ar'}, {'W'}};
disch_types{end+1} = {{'Ar'}, {'Al'}};
disch_types{end+1} = {{'Ar'}, {'Zr'}};
% disch_types{end+1} = {{'Ar'}, {'Mo'}}; % not implemented
% disch_types{end+1} = {{'He'}, {'Mo'}}; % not implemented
disch_types{end+1} = {{'Ar', 'N2'}, {'Ti'}};
disch_types{end+1} = {{'N2'}, {'Ti'}};

% Setup
subfolder = 'materials';
if by_revision
    [rev, branch] = util.git.head();
    subfolder = fullfile('materials',branch,rev);
end

%%

for i_dt = 1:length(disch_types)
    material.setup(disch_types{i_dt}{1}, disch_types{i_dt}{2}, ...
        'Filename', fullfile('+tst', subfolder, ...
        strcat(strcat(disch_types{i_dt}{1}{:}), disch_types{i_dt}{2},'.mat')), ...
        'ExportLegacy', export_legacy);
end

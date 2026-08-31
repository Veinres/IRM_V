% Display todo-list and list of notes.

todolist = cell([0,0]);
notelist = cell([0,0]);

%% add explicit todos and notes here

% notes
notelist{end+1} = 'For reorder_reactions, create a hash function for reactions and sort according to it';
notelist{end+1} = 'Current is no-zero at the beginning -> to high Ar+ density?';

% todos
todolist{end+1} = 'Rename material package (name collision with built in matlab function)';
todolist{end+1} = 'Fix cv plot in scan overview (add fits, and correct xlims)';
todolist{end+1} = 'Implement seed density modification';
todolist{end+1} = 'N2 partial pressure -> RSD';
todolist{end+1} = 'N2 kickout';
todolist{end+1} = 'Fix analyse_qcm, analyse.cv.pulse etc.';
todolist{end+1} = 'Export TiN waveforms with small current in beginning';
todolist{end+1} = 'Fix analyse_qcm, analyse.cv.pulse etc.';
todolist{end+1} = 'Deprecate some of the scripts';
todolist{end+1} = 'Implement e density deduction from current';
todolist{end+1} = 'Termination criterion from current';

%% displaying notes and grepping

% display explicit notes and todos
fprintf('\n');
fprintf( ...
'ToDo-List:-----------------------------------------------------------------\n');
for i_todo = 1:length(todolist)
    fprintf('%i) %s\n',i_todo,todolist{i_todo});
end
fprintf('\n');
fprintf( ...
'Notes:---------------------------------------------------------------------\n');
for i_note = 1:length(notelist)
    fprintf('%i) %s\n',i_note,notelist{i_note});
end
% dynamically search for code tags and display them
fprintf('\n');
util.dev.tags;
fprintf( ...
'---------------------------------------------------------------------------\n');

% cleaning up
clear todolist notelist i_todo i_note; % being explicit because scripts work on global workspace

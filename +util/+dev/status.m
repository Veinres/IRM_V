[~, cmdout] = system('git status -bs');
cmdout = splitlines(cmdout);

fprintf('\n');
fprintf( ...
'GIT-Status-----------------------------------------------------------------\n');
fprintf("%s\n\n", cmdout{1}(4:end));
fprintf( ...
'GIT-Files------------------------------------------------------------------\n');
fprintf("%s\n", cmdout{2:end});
fprintf( ...
'---------------------------------------------------------------------------\n');
clear cmdout;

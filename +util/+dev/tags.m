if strcmp(computer(), 'GLNXA64')
fprintf( ...
'Code-Tags------------------------------------------------------------------\n');

    ctags = {'todo', 'fixme', 'note', 'bug'}; % not capitalised so they don't show up in search
    if exist('customtags', 'var')
        ctags = horzcat(ctags, customtags);
    end
    if exist('devaliases', 'var')
        alltags = horzcat(ctags, devaliases); % also include mentions of developers in search
    end
    filetypes = {'.m', '.md'};
    filetypesstr = join(cellfun(@(x) sprintf("--include=*%s", x), filetypes));
    tagstr = string(join(upper(alltags),"|"));

    fprintf('Scanning for code tags and developer mentions...\n');
    [~] = system(sprintf('grep -Iirn %s -E ''%s'' > +util/+dev/grep_tmp_.txt', filetypesstr, tagstr));

%% Code tags

    filepaths = cell([length(ctags),1]);
    linenumbers = cell([length(ctags),1]);
    matchedlines = cell([length(ctags),1]);

    for i = 1:length(ctags)
        fprintf('Collecting occurances of ''%s''...', upper(ctags{i}));
        [~, lines] = system(sprintf('cat +util/+dev/grep_tmp_.txt | grep -I %s', upper(ctags{i})));
        lines = splitlines(lines);
        if isempty(lines{end}); lines = lines(1:end-1); end % each line is terminated with a new line, so the last one cell is empty
        fprintf(' found %d\n', length(lines));
        [files_and_lines, exts] = cellfun(@(l) split(l, strcat(filetypes, ':')), lines, ...
            'UniformOUtput', false);
        filepaths{i} = cellfun(@(file, ext) strcat(file{1}, ext{1}(1:end-1)), files_and_lines, exts, 'UniformOUtput', false);
        [num, rest] = cellfun(@(file) extractNumAndLine(file{2}), files_and_lines, 'UniformOUtput', false);
        linenumbers{i} = cell2mat(num);
        matchedlines{i} = rest;
    end
    codetags = table('Size', [sum(cellfun(@length, linenumbers)), 4], ...
        'VariableNames',{'Tag', 'File', 'LineNumber', 'Line'}, ...
        'VariableTypes', {'string', 'string', 'int64', 'string'});
    start_ind = 1; end_ind = 0;
    for i = 1:length(ctags)
        end_ind = start_ind + length(linenumbers{i}) - 1 ;
        codetags.Tag(start_ind:end_ind) = string(upper(ctags{i}));
        codetags.File(start_ind:end_ind) = string(filepaths{i});
        codetags.LineNumber(start_ind:end_ind) = linenumbers{i};
        codetags.Line(start_ind:end_ind) = string(matchedlines{i});
        start_ind = end_ind + 1;
    end
    % disp(codetags);
fprintf( ...
['A table named ''codetags'' containing the found tags has been added to the\n' ...
' workspace\n']);

%% Developer mentions
if exist('devaliases', 'var')
fprintf( ...
'Dev-Mentions---------------------------------------------------------------\n');

    filepaths = cell([length(devaliases),1]);
    linenumbers = cell([length(devaliases),1]);
    matchedlines = cell([length(devaliases),1]);

    for i = 1:length(devaliases)
        fprintf('Collecting occurances of ''%s''...', upper(devaliases{i}));
        [~, lines] = system(sprintf('cat +util/+dev/grep_tmp_.txt | grep -iI %s', upper(devaliases{i})));
        lines = splitlines(lines);
        if isempty(lines{end}); lines = lines(1:end-1); end % each line is terminated with a new line, so the last one cell is empty
        fprintf(' found %d\n', length(lines));
        [files_and_lines, exts] = cellfun(@(l) split(l, strcat(filetypes, ':')), lines, ...
            'UniformOUtput', false);
        filepaths{i} = cellfun(@(file, ext) strcat(file{1}, ext{1}(1:end-1)), files_and_lines, exts, 'UniformOUtput', false);
        [num, rest] = cellfun(@(file) extractNumAndLine(file{2}), files_and_lines, 'UniformOUtput', false);
        linenumbers{i} = cell2mat(num);
        matchedlines{i} = rest;
    end
    devmentions = table('Size', [sum(cellfun(@length, linenumbers)), 4], ...
        'VariableNames',{'Alias', 'File', 'LineNumber', 'Line'}, ...
        'VariableTypes', {'string', 'string', 'int64', 'string'});
    start_ind = 1; end_ind = 0;
    for i = 1:length(devaliases)
        end_ind = start_ind + length(linenumbers{i}) - 1 ;
        devmentions.Alias(start_ind:end_ind) = string(upper(devaliases{i}));
        devmentions.File(start_ind:end_ind) = string(filepaths{i});
        devmentions.LineNumber(start_ind:end_ind) = linenumbers{i};
        devmentions.Line(start_ind:end_ind) = string(matchedlines{i});
        start_ind = end_ind + 1;
    end
    % disp(codetags);
fprintf( ...
['A table named ''devmentions'' containing the found mentions has been added\n' ...
' to the workspace\n']);

end
clear filetypes filetypesstr tagstr lines files_and_lines files_and_counts ...
    exts i num rest ind linenumbers matchedlines filepaths ctags alltags end_ind start_ind

end

%%

function [num, rest] = extractNumAndLine(mline)
    num = -1;
    rest = '';
    for i = 1:length(mline)
        if mline(i) == ':'; break; end
    end
    if i < length(mline)
        num = sscanf(mline(1:i-1),'%d');
        rest = mline(i+1:end);
    end
end
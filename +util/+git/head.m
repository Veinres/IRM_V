function [rev, branch] = head(path)
%HEAD fetch the current revision (commit id)
% =========================================================================
% Get git id of the git HEAD. Also return the name of the current branch
%
% ARGUMENTS ---------------------------------------------------------------
%
%   path        (string, directory, default='.'), directory in which
%                   repository is located
%
% RETURN ------------------------------------------------------------------
%
%   id          (char), git commit id of HEAD
%                   empty if current directory is not a git repository
%
%   branch      (char), name of current branch
%                   empty if detached HEAD
%
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ NOTE ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% =========================================================================

%% NOTES: -----------------------------------------------------------------
% -------------------------------------------------------------------------

%% Argument validation
arguments
    path string = ""
end

%% Fetching HEAD info

    rev = '';
    branch = '';

    if isfolder(fullfile(path,'.git')) && isfile(fullfile(path,'.git','HEAD'))
        head = readlines(fullfile(path,'.git','HEAD'));
        head = split(head(1), ' ');
        if strcmp(head(1), "ref:")
            head = head{end};
            branch = split(head, '/');
            branch = strrep(fullfile(branch{3:end}), '\', '/');
            if isfile(fullfile(path,'.git',head))
                head = readlines(fullfile(path,'.git',head));
                rev = head(1);
            end
        else
            rev = head(1);
            branch = ''; % detached head
        end
        rev = char(rev);
    end
end

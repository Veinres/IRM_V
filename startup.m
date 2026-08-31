%% configuration

% Add your username to the list if you want to see the dev notes on startup
devs = {'joel', 'jofif'};

%% standard startup code
fprintf('\n');
fprintf( ...
'>>Start-Up-----------------------------------------------------------------\n');
fprintf('\n');
fprintf('Adding scripts folder to path.\n');
addpath('scripts');
fprintf('Setting default figure style.\n');
util.fig.setDefaultStyle();

%% custom startup code
% NOTE: Please add your custom startup code here (example given below)
% but use a guard to make sure the code is only run for you

if isCurrentUser({'joel', 'jofif'})
    devaliases = strcat('@',{'joel','jf'});
end

if isCurrentUser({'johnathan.doe'})
    devaliases = strcat('@',{'johnathan','john','jd'});
end

%% dev notes

if ~exist('devaliases', 'var')
    devaliases = {};
end
if isCurrentUser(devs)
    util.dev.status; % display information in the git status
    util.dev.notes; % display the dev notes (todo list, mentions, and code tags)
end
clear devaliases;

%% clean up
clear devs;
fprintf('\n');
fprintf( ...
'Done---------------------------------------------------------------------<<\n');
fprintf('\n');

%% function implementations

function run = isCurrentUser(devs)
    % compares the names listed in the 'devs' variable with the current
    % user as specified in the environment variables of the OS
    run = any(cellfun(@(dev) any(strcmp(getenv({'USER','USERNAME'}), dev)), devs));
    % 'USER' for nix systems
    % 'USERNAME' for windows
end
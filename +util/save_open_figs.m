function save_open_figs(user,subfolder,plot_format,save_figs)
%SAVE_OPEN_FIGS save all currently open figures
% =========================================================================
% Save all open figures in a specified location and various formats.
%
% ARGUMENTS ---------------------------------------------------------------
%
%   user        (string), (determines results subfolder)
%                   plots are placed in 'results/<user>/<subfolder>/figs/'
%
%   subfolder   (string), (determines results subfolder)
%                   plots are placed in 'results/<user>/<subfolder>/figs/'
%
%   plot_format (cellstr, optional, default={'png'}), output formats
%                   available formats are:
%                       - 'jpg', 'jpeg'
%                       - 'png'
%                       - 'tif', 'tiff'
%                       - 'pdf'
%                       - 'emf'
%                       - 'eps'
%
%   save_figs   (boolean, optional, default=true), whether to save to .fig
%
% RETURN ------------------------------------------------------------------
%
%   None
%
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ NOTE ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This function requires Matlab 2019b or later.
% =========================================================================

%% NOTES: -----------------------------------------------------------------

% -------------------------------------------------------------------------

%% Argument parsing and validation
arguments
    % required positional arguments
    user        char = 'default'
    subfolder   char = 'all_plots'
    % optional positional arguments
    plot_format = {'png'} % {mustBeTextExt} FIXME
    save_figs   logical = true
end

plot_format = cellstr(plot_format);

%% Saving all open figures
possible_formats = {'jpg', 'jpeg',...
                    'png',...
                    'tif', 'tiff',...
                    'pdf',...
                    'emf',...
                    'eps'};

% Collect all currently open figures
fig_handles = findall(0, 'Type', 'figure'); 

% create folder
if ~isempty(subfolder)
    directory = fullfile('results', user, subfolder, 'figs');
    if ~exist(directory, 'dir')
        mkdir(directory)
    end
else
    directory = fullfile(user, 'figs');
    if ~exist(directory, 'dir')
        mkdir(directory)
    end
end
% save figures as .fig and any other specified format
for i = 1:numel(fig_handles)
    fp = strrep(fig_handles(i).Name, ' ', '_');
    fp = strrep(fp, ':', '-');
    if strcmp(fp,'')
        fp = sprintf('fig%i',i);
    end
    if save_figs
        fn = fullfile(directory, strcat(fp, '.fig'));
        if exist(fn,'file')
            fn = fullfile(directory, strcat(fp, sprintf('_%i',i), '.fig'));
            if exist(fn,'file')
                fn = fullfile(directory, strcat(fp, sprintf('_%i_',i), datestr(now,'yyyy-MM-dd_hhmm'), '.fig'));
            end
        end
        savefig(fig_handles(i), fn);
    end
    for j=1:length(plot_format)
        if any(strcmp(plot_format{j}, possible_formats))
            fn = fullfile(directory, strcat(fp, '.', plot_format{j}));
            if exist(fn,'file')
                fn = fullfile(directory, strcat(fp, sprintf('_%i',i), '.', plot_format{j}));
                if exist(fn,'file')
                    fn = fullfile(directory, strcat(fp, sprintf('_%i_',i), datestr(now,'yyyy-MM-dd_hhmm'), '.', plot_format{j}));
                end
            end
            exportgraphics(fig_handles(i), fn);
        end
    end
end

end
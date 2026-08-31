function [summary, metadata, results, inputs, outputs, best] = load(foldername, options)
%LOAD load the results of all parameter scans in a folder
% =========================================================================
% Load the collected results from individual runs of each parameter scans
% of a study. The results need to be collected first using e.g.
% rslt.scan.collect .
%
% See also: rslt.scan.collect, rslt.study.collect
%
% ARGUMENTS ---------------------------------------------------------------
%
%   foldername  (string, folder), path to results of parameter scan
%
% NAME-VALUE --------------------------------------------------------------
%
%   'SaveLocation'  (string, optional, default=''), save location
%                       Location where collected results will be saved.
%                       The location needs to be a valid and existing.
%                       If the save location string ends in '.mat', all
%                       variables will be saved in the specified .mat-file.
%                       If the save location is a folder, the variables
%                       will be saved in separate .mat-files instead.
%
%   'Collect'       (logical, optional, default=false), first collect
%                       results (WIP)
%
%   'ReplaceId'     (logical, optional, default=false), replace ids with
%                       filename
%
% RETURN ------------------------------------------------------------------
%
%   summary         (table), summary for all parameter scans (*)
%
%   metadata        (table), metadata for all parameter scans (*)
%
%   results         (cell), results for all parameters scans (*)
%
%   inputs          (cell), input for all parameters scans (*)
%
%   outputs         (cell), output for all parameters scans (*)
%
%   best            (cell), full output for best fitting para. scans(*)
%
% (*) : See rslt.scan.collect for details about these structures/tables
%
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ NOTE ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% This function requires Matlab 2019b or later.
% =========================================================================

%% NOTES: -----------------------------------------------------------------
% -------------------------------------------------------------------------

%% Argument parsing and validation
arguments
    foldername char {mustBeFolder}
    options.ReplaceId logical = false
    options.SaveLocation char = ''
end

%% Fetch .mat-file names

files = dir(foldername);
mfiles = files(~[files.isdir]); % filter out folders
mfiles = mfiles(cellfun(@(name) strcmp(name(end-3:end), '.mat'), ...
    {mfiles.name})); % only keep .mat files

%% Import summary and join
summary = rslt.study.summarise(foldername, ...
    "ReplaceId", options.ReplaceId);

%% Import metadata and join
ndisch = height(summary);

metadata = cell([0,0]);
results = cell([0,0]);
inputs = cell([0,0]);
outputs = cell([0,0]);
best = cell([0,0]);
for i = 1:ndisch
    pth = fullfile(summary.resultfile(i));
    tmp = load(pth);
    if isfield(tmp, 'metadata')
        metadata{i} = tmp.metadata;
    end
    if isfield(tmp, 'results')
        results{i} = tmp.results;
    end
    if isfield(tmp, 'inputs')
        inputs{i} = tmp.inputs;
    end
    if isfield(tmp, 'outputs')
        outputs{i} = tmp.outputs;
    end
    if isfield(tmp, 'best')
        best{i} = tmp.best;
    end
end

if ~isempty(options.SaveLocation)
    vars = {'summary', 'metadata', 'results', 'inputs', 'outputs'};
    if strcmp(options.SaveLocation(end-3:end), '.mat')
        save(options.SaveLocation, vars{:});
    elseif isfolder(options.SaveLocation)
        for i = 1:length(vars)
            save(fullfile(options.SaveLocation, strcat(vars{i}, '.mat')), vars{i});
        end
    else
        warning("Invalid save location: must be existing folder or .mat-file. No data saved.");
    end
end

end

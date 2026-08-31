function [summary, metadata, results, inputs, outputs] = summarise(foldername, options)
%SUMMARISE collect summaries of multiple scans 
% =========================================================================
% Collect the summaries from individual runs of all parameter scans of a
% study.
%
% See also : rslt.scan.collect, rslt.study.collect
%
% ARGUMENTS ---------------------------------------------------------------
%
%   foldername  (string, folder), path to results of parameter scan
%
% NAME-VALUE --------------------------------------------------------------
%
%   'ReplaceId'     (logical, optional, default=false), replace ids with
%                       filename
%
%   'SaveLocation'  (string, optional, default=''), save location
%                       Location where collected results will be saved.
%                       Collected results are not saved if empty.
%
% RETURN ------------------------------------------------------------------
%
%   summary         (table), summary for all parameter scans (*)
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
summary = table();
for i = 2:length(mfiles)
    pth = fullfile(mfiles(i).folder, mfiles(i).name);
    tmp = load(pth, 'summary');
    if isfield(tmp, 'summary')
        tmpsmry = tmp.summary;
        if options.ReplaceId
            tmpsmry.id = string(mfiles(i).name(1:end-4));
        else
            tmpsmry.id = string(tmpsmry.id);
        end
        tmpsmry.resultfile = string(pth);
        summary = vertcat(summary, tmpsmry);
    end
end

%% Save
if ~isempty(options.SaveLocation)
    save(options.SaveLocation, 'summary', '-mat')
end

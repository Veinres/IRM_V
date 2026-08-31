function [summary, metadata, results, inputs, outputs, best] = collect(foldername, options)
%COLLECT collect the results of all parameter scans in a folder
% =========================================================================
% Collect the results from individual runs of each parameter scans of a
% study.
%
% See also : rslt.scan.collect , rslt.study.summarise 
%
% ARGUMENTS ---------------------------------------------------------------
%
%   foldername      (string, folder), path to folder containing the
%                       parameter scans
%
% NAME-VALUE --------------------------------------------------------------
%
%   'SaveLocation'  (string, default='./'), save location
%                       Location where collected results will be saved.
%                       The results will be saved in a .mat file with the
%                       same name as the folder containing the simulation
%                       output.
%
%   'IdUpdate'      (char, default=''), scheme to update Ids
%                       Possible options are:
%                       - ''/'none'  : don't update
%                       - 'filename' : use filename to create Id
%
%   'Constraint'    (function handle, default=[]), fitting constraint
%                       Can be used to apply custom constraints when
%                       fitting. Takes the results table and input struct
%                       as input and must produce either a list of indecies
%                       of the accepted
%                       runs or a logical array of length <n_runs>.
%                       Example:
%                           foo = @(res, in) ...
%                               abs(res.F_flux - in.disch.F_flux) < 0.05
%                       For a list of available fields, consult the
%                       description of the return values in
%                       rslt.scan.collect .
%                       By default the example above will be used.
%
% RETURN ------------------------------------------------------------------
%
%   summary         (table), summary for each parameter scans (*)
%
%   metadata        (table), metadata for each parameter scans (*)
%
%   results         (cell), results for each parameters scans (*)
%
%   inputs          (cell), input for each parameters scans (*)
%
%   outputs         (cell), output for each parameters scans (*)
%
%   best            (cell), best for each paramaters scans (*)
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
    options.SaveLocation char = './'
    options.IdUpdate char {mustBeMember(options.IdUpdate, {'','none','filename'})} = ''
    options.Constraint = []
    options.Verbose logical = false
end

%% Fetch directory names and collect if folder contains results
folders = dir(foldername);
folders = folders([folders.isdir]);

for i = 1:length(folders)
    path_to_results = fullfile(foldername, folders(i).name);
    contained_folders = dir(path_to_results);
    contained_folders = contained_folders([contained_folders.isdir]);
    is_result_folder = contains({contained_folders.name}, 'run_Pfit');
    if any(is_result_folder) && sum(is_result_folder) >= 4
        result_folders = contained_folders(is_result_folder);
        if ~isfolder(options.SaveLocation)
            mkdir(options.SaveLocation)
        end
        switch options.IdUpdate
            case 'filename'
                identifier = folders(i).name;
            otherwise % {'', 'none'}
                identifier = '';
        end
        try
            in = load(fullfile(result_folders(1).folder,result_folders(1).name, 'Input.mat'));
            if isa(options.Constraint, 'function_handle')
                constraint_function = @(res) options.Constraint(res, in);
            else
                constraint_function = @(res) abs(res.F_flx - in.disch.F_flux) < 0.05;
            end
        catch
            warning('rslt:study:collect:constraintError', ...
                "An error occured while setting the constraint function. Running unconstraint.")
            constraint_function = [];
        end
        if options.Verbose
            if ~isempty(identifier)
                name = identifier;
            else
                name = fullfile(path_to_results);
            end
            fprintf("Collecting <%s>", name);
        end
        rslt.scan.collect(fullfile(path_to_results), ...
            "SaveLocation", fullfile(options.SaveLocation, strcat(folders(i).name, '.mat')), ...
            "Id", identifier, ...
            "Constraint", constraint_function);
        if options.Verbose
            fprintf("Done");
        end
    end
end

%% Load and return collected results
[summary, metadata, results, inputs, outputs, best] = rslt.study.load(options.SaveLocation);

end
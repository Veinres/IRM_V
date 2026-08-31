classdef (Abstract) ParameterScan < handle
% TODOC

%% Properties
properties %(Access = protected)
    index

    index_limit
    parameters
    results_path

    ids
    parameter_values
    results
    paths

    options = struct(...
        'OverwriteResults',false,...
        'ShowWarnings',false...
        );
end % properties

methods (Abstract, Access=protected)
%% Iterator

    index = iter(obj)
end % methods

methods
%% Constructor

    function obj = ParameterScan(parameters, results_path, index_limit)
        arguments
            parameters (:,1) ps.Parameter
            results_path char
            index_limit {mustBeInteger, mustBePositive}
        end
        obj.index = 0;
        obj.index_limit = index_limit;
        obj.parameters = parameters;
        obj.results_path = results_path;

        obj.ids = 1:index_limit;
        obj.parameter_values = zeros(length(obj.parameters), index_limit);
        obj.results = cell(index_limit,1);
        obj.paths = cell(index_limit,1);
    end
        
%% Iterating and accesing parameters

    function [parameters, id, index] = next(obj)
        obj.iter();
        [parameters, id, index] = current(obj);
    end

    function [parameters, id, index] = current(obj)
        % PS not started
        if obj.index < 0
            if obj.options.ShowWarnings
                warning('Parameter Scan not started yet.');
            end
            parameters = zeros(0);
            id = 0;
            index = 0;
        % PS running
        elseif obj.index < obj.index_limit
            parameters = obj.parameter_values(:,obj.index);
            id = obj.ids(obj.index);
            index = obj.index;
        % PS terminated
        else
            if obj.options.ShowWarnings
                warning('Parameter Scan already terminated.');
            end
            parameters = zeros(0);
            id = 0;
            index = 0;
        end
    end
        
%% Saving / Exporting Results

    function save(obj, results, input, output, index)
        obj.save_results(results, index);
        obj.export_data(results, input, output, index);
    end
    function save_results(obj, results, index)
        arguments
            obj ps.ParameterScan
            results struct
            index {mustBeInteger, mustBePositive} = obj.index
        end
        obj.results{index} = results;
    end
    function export_data(obj, results, index, output, input)
        arguments
            obj ps.ParameterScan
            results struct              % used in save command
            index {mustBeInteger, mustBePositive} = obj.index
            output struct = struct([])  % used in save command
            input struct = struct([])   % used in save command
        end
        results_folder = fullfile(obj.results_path,sprintf('%i',index));
        if ~exist(results_folder, 'dir')
            mkdir(results_folder);
        elseif ~obj.options.OverwriteResults
            results_folder = fullfile(obj.results_path, ...
                                strcat(sprintf('%i',index),...
                                datestr(now,'yyyy-MM-dd_hhmm')));
            mkdir(results_folder);
        end
        obj.paths{index} = results_folder;
        save('results', fullfile(results_folder,'results.mat'));
        if ~isempty(output)
            save('output', fullfile(results_folder,'output.mat'));
        end
        if ~isempty(input)
            save('input', fullfile(results_folder,'input.mat'));
        end
    end
%% Settings

    function overwrite(obj, overwrite)
        arguments
            obj ps.ParameterScan
            overwrite char {mustBeMember(overwrite,{'toggle','on','true','off','false'})} = 'off'
        end
        switch overwrite
            case 'toggle'
                obj.options.OverwriteResults = ~obj.OverwriteResults;
            case {'on','true'}
                obj.options.OverwriteResults = true;
            case {'off','false'}
                obj.options.OverwriteResults = false;
            otherwise
                obj.options.OverwriteResults = false;
        end
    end
    
    function warnings(obj, warnings)
        arguments
            obj ps.ParameterScan
            warnings char {mustBeMember(warnings,{'toggle','on','true','off','false'})} = 'off'
        end
        switch warnings
            case 'toggle'
                obj.options.ShowWarnings = ~obj.ShowWarnings;
            case {'on','true'}
                obj.options.ShowWarnings = true;
            case {'off','false'}
                obj.options.ShowWarnings = false;
            otherwise
                obj.options.ShowWarnings = false;
        end
    end
    
end % methods

end % classdef
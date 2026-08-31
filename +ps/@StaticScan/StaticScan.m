classdef StaticScan < ps.ParameterScan
    % TODOC
    methods (Access=protected)
        % Iterator
        function index = iter(obj)
            index = obj.index + 1;
            obj.index = index;
        end
    end  
    methods
        % Constructor
        function obj = StaticScan(parameters, results_path, parameter_values)
            arguments
                parameters (:,1) ps.Parameter
                results_path char
                parameter_values (:,:) double {mustBeEqualDim(parameter_values,parameters,1)}
            end
            obj@ps.ParameterScan(parameters, results_path, size(parameter_values,2));
            obj.parameter_values(:,:) = parameter_values(:,:); % using (:,:) because obj.parameter_values will already be allocated at this point
        end
        % PCT / Batch creation
        function objs = split(obj, n_workers, batch_size)
            arguments
                obj ps.StaticScan
                n_workers double {mustBeInteger, mustBePositive} = 1
                batch_size uint32 {mustBeInteger, mustBePositive} = 0
            end
            % 1. either split it into exactly n batches where n is the number of
            % workers (default behaviour)
            % or
            % 2. split it into >n smaller batches. Hand workers new batches once
            % their finished with their batch. (when supplying an explicit batch size)
            if batch_size > 0
                n_batches = max(idivide(obj.index_limit, batch_size), n_workers);
            else
                n_batches = n_workers;
            end
            % NOTE : -> always n_batches >= n_workers -> always batch_size >= 1
            batch_size = idivide(obj.index_limit, n_batches);
            remainder = obj.index_limit - n_batches*batch_size;
            batches_per_worker = idivide(n_batches, n_workers);
            % construct batches
            objs = cell(n_workers, batches_per_worker);
            start_index = 1;
            for i_batch = 1:n_batches
                end_index = start_index + batch_size - 1;
                if i_batch <= remainder
                    % make batch one larger to accomodate remaining tasks
                    end_index = end_index + 1;
                end
                [i_worker, i_worker_batch] = ind2sub([n_workers, batches_per_worker], i_batch);
                objs{i_worker, i_worker_batch} = ps.StaticScan(obj.parameters, obj.results_path,...
                                                    obj.parameter_values(:,start_index:end_index));
                objs{i_worker, i_worker_batch}.ids = obj.ids(start_index:end_index);
                start_index = end_index + 1;
            end
            % export batches
            objs = [objs{:,:}];
        end
        function reassemble(obj, objs)
            arguments
                obj ps.StaticScan
                objs (:,:) ps.StaticScan
            end
            n_batches = numel(objs);
            for i_batch = 1:n_batches
                % NOTE : it is assumed, that ids are contiguous
                start_index = find(obj.ids==objs(i_batch).ids(1),1,'first');
                end_index = find(obj.ids==objs(i_batch).ids(end),1,'first');
                
                obj.results(start_index:end_index) = objs(i_batch).results;
                obj.paths(start_index:end_index) = objs(i_batch).paths;
            end
            obj.index = obj.index_limit + 1; % show that this scan is done
        end
    end
end

function mustBeEqualDim(a,b,dim)
    if ~isequal(size(a,dim),size(b,dim))
        eid = 'Size:notEqual';
        msg = sprintf('Size of along dimension %i of first input must equal size of second input along dimension %i.', dim, dim);
        throwAsCaller(MException(eid,msg))
    end
end